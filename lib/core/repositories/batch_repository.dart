import 'package:hive_flutter/hive_flutter.dart';
import '../entities/batch_entity.dart';
import '../services/sync_service.dart';
import '../services/sync_queue.dart';
import '../services/connection_service.dart';
import 'dart:developer' as dev;

abstract class IBatchRepository {
  Future<List<BatchEntity>> getAllBatches();
  Future<BatchEntity?> getBatchById(String id);
  Future<void> addBatch(BatchEntity batch);
  Future<void> updateBatch(BatchEntity batch);
  Future<void> deleteBatch(String id);
}

class BatchRepository implements IBatchRepository {
  static const String _boxName = 'batches';

  Future<bool> _isOnline() async => await ConnectionService().isConnected;

  @override
  Future<List<BatchEntity>> getAllBatches() async {
    final box = await Hive.openBox<BatchEntity>(_boxName);
    return box.values.toList();
  }

  @override
  Future<BatchEntity?> getBatchById(String id) async {
    final box = await Hive.openBox<BatchEntity>(_boxName);
    return box.values.firstWhere((batch) => batch.id == id);
  }

  @override
  Future<void> addBatch(BatchEntity batch) async {
    final box = await Hive.openBox<BatchEntity>(_boxName);
    await box.add(batch);
    await SyncService().queueChange(
      SyncQueueItem(
        id: batch.id,
        type: 'add',
        entityType: 'batch',
        data: batchToMap(batch),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateBatch(BatchEntity batch) async {
    final box = await Hive.openBox<BatchEntity>(_boxName);
    final index = box.values.toList().indexWhere((b) => b.id == batch.id);
    if (index != -1) {
      await box.putAt(index, batch);
      await SyncService().queueChange(
        SyncQueueItem(
          id: batch.id,
          type: 'edit',
          entityType: 'batch',
          data: batchToMap(batch),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> deleteBatch(String id) async {
    final box = await Hive.openBox<BatchEntity>(_boxName);
    final index = box.values.toList().indexWhere((b) => b.id == id);
    if (index != -1) {
      final batch = box.getAt(index);
      await box.deleteAt(index);
      if (batch != null) {
        await SyncService().queueChange(
          SyncQueueItem(
            id: batch.id,
            type: 'delete',
            entityType: 'batch',
            data: {'id': batch.id},
            createdAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Map<String, dynamic> batchToMap(BatchEntity b) => {
    'id': b.id,
    'name': b.name,
    'date': b.date.toIso8601String(),
    'supplier': b.supplier,
    'chickcount': b.chickCount,
    'chickbuyprice': b.chickBuyPrice,
    'note': b.note,
    'userId': b.userId,
    'updatedat': b.updatedAt.toIso8601String(),
  };
}
