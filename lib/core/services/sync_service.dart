import 'dart:async';
import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'sync_queue.dart';
import 'connection_service.dart';
import '../di/service_locator.dart';
import '../entities/batch_entity.dart';
import '../entities/addition_entity.dart';
import '../entities/death_entity.dart';
import '../entities/sale_entity.dart';

enum SyncStatus { synced, syncing, offline, error }

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SyncQueueService _queueService = SyncQueueService();
  final _statusController = StreamController<SyncStatus>.broadcast();
  final _userNoticeController = StreamController<String>.broadcast();
  Timer? _periodicSync;

  Stream<SyncStatus> get syncStatusStream => _statusController.stream;
  Stream<String> get userNoticeStream => _userNoticeController.stream;

  void startSync({Duration interval = const Duration(minutes: 5)}) {
    _periodicSync?.cancel();
    _periodicSync = Timer.periodic(interval, (_) => processQueue());
    ConnectionService().onStatusChange.listen((connected) {
      if (connected) processQueue();
    });
  }

  Future<void> queueChange(SyncQueueItem item) async {
    await _queueService.addToQueue(item);
    dev.log('Queued change: ${item.type} ${item.entityType}', name: 'sync');
    processQueue();
  }

  Future<void> processQueue() async {
    dev.log('Sync process started', name: 'sync');
    _userNoticeController.add('بدء عملية المزامنة...');
    final batches = await Hive.openBox<BatchEntity>('batches');
    dev.log(
      'Hive batches: \\n${batches.values.map((b) => b.toString()).join('\n')}',
      name: 'sync',
    );
    final additions = await Hive.openBox<AdditionEntity>('additions');
    dev.log(
      'Hive additions: \\n${additions.values.map((a) => a.toString()).join('\n')}',
      name: 'sync',
    );
    final deaths = await Hive.openBox<DeathEntity>('deaths');
    dev.log(
      'Hive deaths: \\n${deaths.values.map((d) => d.toString()).join('\n')}',
      name: 'sync',
    );
    final sales = await Hive.openBox<SaleEntity>('sales');
    dev.log(
      'Hive sales: \\n${sales.values.map((s) => s.toString()).join('\n')}',
      name: 'sync',
    );
    final queue = await _queueService.getQueue();
    dev.log('Sync queue length: \\n${queue.length}', name: 'sync');
    dev.log(
      'Sync queue items: \\n${queue.map((q) => q.toString()).join('\n')}',
      name: 'sync',
    );
    final connected = await ConnectionService().isConnected;
    dev.log('Connection status: $connected', name: 'sync');
    if (!connected) {
      _statusController.add(SyncStatus.offline);
      dev.log('Sync skipped: offline', name: 'sync');
      _userNoticeController.add(
        'لا يوجد اتصال بالإنترنت. سيتم المزامنة لاحقًا.',
      );
      return;
    }
    _statusController.add(SyncStatus.syncing);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    for (final entityType in ['batches', 'additions', 'deaths', 'sales']) {
      try {
        final client = Supabase.instance.client;
        final response = await client
            .from(entityType)
            .select()
            .eq('userId', userId ?? '')
            .limit(10);
        dev.log('Supabase [$entityType]: \\n$response', name: 'sync');
      } catch (e) {
        dev.log('Supabase [$entityType] fetch error: $e', name: 'sync');
      }
    }
    for (final item in queue) {
      try {
        final client = Supabase.instance.client;
        final table = _getTableName(item.entityType);
        dev.log(
          'Processing item: ${item.type} ${item.entityType} id=${item.data['id']}',
          name: 'sync',
        );
        if (item.type == 'add' || item.type == 'edit') {
          final response =
              await client
                  .from(table)
                  .select()
                  .eq('id', item.data['id'])
                  .eq('userId', userId ?? '')
                  .maybeSingle();
          dev.log('Supabase response: $response', name: 'sync');
          if (response == null) {
            await client.from(table).upsert(item.data);
            dev.log(
              'Upserted (not found in Supabase): ${item.type} ${item.entityType}',
              name: 'sync',
            );
            final verify =
                await client
                    .from(table)
                    .select()
                    .eq('id', item.data['id'])
                    .eq('userId', userId ?? '')
                    .maybeSingle();
            dev.log('Verified upserted data: $verify', name: 'sync');
            _userNoticeController.add(
              'تمت إضافة/تعديل ${item.entityType} بنجاح إلى السحابة.',
            );
            await _queueService.removeFromQueue(item.id);
            dev.log('Removed from queue: ${item.id}', name: 'sync');
          } else {
            final localUpdatedAt = DateTime.parse(item.data['updatedat'] ?? '');
            final remoteUpdatedAt =
                DateTime.tryParse(response['updatedat'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            dev.log(
              'localUpdatedAt=$localUpdatedAt, remoteUpdatedAt=$remoteUpdatedAt',
              name: 'sync',
            );
            if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
              await client.from(table).upsert(item.data);
              dev.log(
                'Upserted (local newer): ${item.type} ${item.entityType}',
                name: 'sync',
              );
              final verify =
                  await client
                      .from(table)
                      .select()
                      .eq('id', item.data['id'])
                      .eq('userId', userId ?? '')
                      .maybeSingle();
              dev.log('Verified upserted data: $verify', name: 'sync');
              _userNoticeController.add(
                'تمت مزامنة ${item.entityType} (الأحدث محليًا) بنجاح.',
              );
              await _queueService.removeFromQueue(item.id);
              dev.log('Removed from queue: ${item.id}', name: 'sync');
            } else {
              await _updateLocalFromSupabase(item.entityType, response, userId);
              dev.log(
                'Updated local from Supabase (Supabase newer): ${item.type} ${item.entityType}',
                name: 'sync',
              );
              _userNoticeController.add(
                'تم تحديث بيانات ${item.entityType} من السحابة بسبب وجود نسخة أحدث.',
              );
              await _queueService.removeFromQueue(item.id);
              dev.log('Removed from queue: ${item.id}', name: 'sync');
            }
          }
        } else if (item.type == 'delete') {
          await client
              .from(table)
              .delete()
              .eq('id', item.data['id'])
              .eq('userId', userId ?? '');
          dev.log(
            'Deleted from Supabase: ${item.entityType} id=${item.data['id']}',
            name: 'sync',
          );
          _userNoticeController.add('تم حذف ${item.entityType} من السحابة.');
          await _queueService.removeFromQueue(item.id);
          dev.log('Removed from queue: ${item.id}', name: 'sync');
        }
      } catch (e, st) {
        _statusController.add(SyncStatus.error);
        dev.log('Sync error: $e', name: 'sync', error: e, stackTrace: st);
        _userNoticeController.add('حدث خطأ أثناء المزامنة: $e');
        return;
      }
    }
    _statusController.add(SyncStatus.synced);
    dev.log('Sync complete', name: 'sync');
    _userNoticeController.add('اكتملت المزامنة بنجاح.');
  }

  Future<void> _updateLocalFromSupabase(
    String entityType,
    Map<String, dynamic> data,
    String? userId,
  ) async {
    if (userId == null) return;
    dev.log('Supabase data for conflict resolution: $data', name: 'sync');
    switch (entityType) {
      case 'batch':
        final box = await Hive.openBox<BatchEntity>('batches');
        if (data['userId'] == userId) {
          final entity = BatchEntity(
            id: data['id'] as String,
            name: data['name'] as String,
            date: DateTime.parse(data['date'] as String),
            supplier: data['supplier'] as String,
            chickCount: data['chickcount'] as int,
            chickBuyPrice: (data['chickbuyprice'] as num).toDouble(),
            note: data['note'] as String?,
            userId: data['userId'] as String,
            updatedAt: DateTime.parse(data['updatedat'] as String),
          );
          final index = box.values.toList().indexWhere(
            (b) => b.id == entity.id,
          );
          if (index != -1) {
            await box.putAt(index, entity);
          } else {
            await box.add(entity);
          }
          _userNoticeController.add(
            'تم تحديث بيانات الدفعة من السحابة بسبب وجود نسخة أحدث.',
          );
        }
        break;
      case 'addition':
        final box = await Hive.openBox<AdditionEntity>('additions');
        if (data['userId'] == userId) {
          final entity = AdditionEntity(
            id: data['id'] as String,
            batchId: data['batchid'] as String,
            name: data['name'] as String,
            cost: (data['cost'] as num).toDouble(),
            date: DateTime.parse(data['date'] as String),
            userId: data['userId'] as String,
            updatedAt: DateTime.parse(data['updatedat'] as String),
          );
          final index = box.values.toList().indexWhere(
            (a) => a.id == entity.id,
          );
          if (index != -1) {
            await box.putAt(index, entity);
          } else {
            await box.add(entity);
          }
          _userNoticeController.add(
            'تم تحديث بيانات المصروف من السحابة بسبب وجود نسخة أحدث.',
          );
        }
        break;
      case 'death':
        final box = await Hive.openBox<DeathEntity>('deaths');
        if (data['userId'] == userId) {
          final entity = DeathEntity(
            id: data['id'] as String,
            batchId: data['batchid'] as String,
            count: data['count'] as int,
            date: DateTime.parse(data['date'] as String),
            userId: data['userId'] as String,
            updatedAt: DateTime.parse(data['updatedat'] as String),
          );
          final index = box.values.toList().indexWhere(
            (d) => d.id == entity.id,
          );
          if (index != -1) {
            await box.putAt(index, entity);
          } else {
            await box.add(entity);
          }
          _userNoticeController.add(
            'تم تحديث بيانات الوفاة من السحابة بسبب وجود نسخة أحدث.',
          );
        }
        break;
      case 'sale':
        final box = await Hive.openBox<SaleEntity>('sales');
        if (data['userId'] == userId) {
          final entity = SaleEntity(
            id: data['id'] as String,
            batchId: data['batchid'] as String,
            buyerName: data['buyername'] as String,
            date: DateTime.parse(data['date'] as String),
            chickCount: data['chickcount'] as int,
            pricePerChick: (data['priceperchick'] as num).toDouble(),
            paidAmount: (data['paidamount'] as num).toDouble(),
            note: data['note'] as String?,
            userId: data['userId'] as String,
            updatedAt: DateTime.parse(data['updatedat'] as String),
          );
          final index = box.values.toList().indexWhere(
            (s) => s.id == entity.id,
          );
          if (index != -1) {
            await box.putAt(index, entity);
          } else {
            await box.add(entity);
          }
          _userNoticeController.add(
            'تم تحديث بيانات البيع من السحابة بسبب وجود نسخة أحدث.',
          );
        }
        break;
    }
  }

  String _getTableName(String entityType) {
    switch (entityType) {
      case 'batch':
        return 'batches';
      case 'addition':
        return 'additions';
      case 'death':
        return 'deaths';
      case 'sale':
        return 'sales';
      default:
        throw Exception('Unknown entityType: $entityType');
    }
  }

  void dispose() {
    _periodicSync?.cancel();
    _statusController.close();
    _userNoticeController.close();
  }
}
