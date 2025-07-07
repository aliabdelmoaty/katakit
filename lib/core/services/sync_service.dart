import 'dart:async';
import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'sync_queue.dart';
import 'connection_service.dart';

enum SyncStatus { synced, syncing, offline, error }

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SyncQueueService _queueService = SyncQueueService();
  final _statusController = StreamController<SyncStatus>.broadcast();
  Timer? _periodicSync;

  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

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
    final connected = await ConnectionService().isConnected;
    if (!connected) {
      _statusController.add(SyncStatus.offline);
      dev.log('Sync skipped: offline', name: 'sync');
      return;
    }
    _statusController.add(SyncStatus.syncing);
    final queue = await _queueService.getQueue();
    for (final item in queue) {
      try {
        final client = Supabase.instance.client;
        final table = _getTableName(item.entityType);
        if (item.type == 'add' || item.type == 'edit') {
          // جلب العنصر من Supabase
          final response =
              await client
                  .from(table)
                  .select()
                  .eq('id', item.data['id'])
                  .maybeSingle();
          if (response == null) {
            // العنصر غير موجود في Supabase، نفذ upsert
            await client.from(table).upsert(item.data);
            dev.log(
              'Upserted (not found in Supabase): ${item.type} ${item.entityType}',
              name: 'sync',
            );
            await _queueService.removeFromQueue(item.id);
          } else {
            // قارن updatedAt
            final localUpdatedAt = DateTime.parse(item.data['updatedAt']);
            final remoteUpdatedAt =
                DateTime.tryParse(response['updatedAt'] ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
              // المحلي أحدث، نفذ upsert
              await client.from(table).upsert(item.data);
              dev.log(
                'Upserted (local newer): ${item.type} ${item.entityType}',
                name: 'sync',
              );
              await _queueService.removeFromQueue(item.id);
            } else {
              // Supabase أحدث، تجاهل التعديل المحلي
              dev.log(
                'Skipped upsert (Supabase newer): ${item.type} ${item.entityType}',
                name: 'sync',
              );
              await _queueService.removeFromQueue(item.id);
              // يمكن هنا تحديث البيانات المحلية من Supabase إذا رغبت
            }
          }
        } else if (item.type == 'delete') {
          await client.from(table).delete().eq('id', item.data['id']);
          await _queueService.removeFromQueue(item.id);
          dev.log('Synced: ${item.type} ${item.entityType}', name: 'sync');
        }
      } catch (e) {
        _statusController.add(SyncStatus.error);
        dev.log('Sync error: $e', name: 'sync', error: e);
        return;
      }
    }
    _statusController.add(SyncStatus.synced);
    dev.log('Sync complete', name: 'sync');
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
  }
}
