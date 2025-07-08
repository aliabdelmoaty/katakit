import 'package:hive_flutter/hive_flutter.dart';
import '../entities/batch_entity.dart';
import '../entities/addition_entity.dart';
import '../entities/death_entity.dart';
import '../entities/sale_entity.dart';
import '../services/sync_service.dart';
import '../services/sync_queue.dart';
import '../services/connection_service.dart';

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

    // --- Cascade Delete for related entities ---
    // Delete Additions
    final additionsBox = await Hive.openBox<AdditionEntity>('additions');
    final additionsToDelete = additionsBox.values.where((a) => a.batchId == id).toList();
    for (final addition in additionsToDelete) {
      final additionIndex = additionsBox.values.toList().indexWhere((a) => a.id == addition.id);
      if (additionIndex != -1) {
        await additionsBox.deleteAt(additionIndex);
        await SyncService().queueChange(
          SyncQueueItem(
            id: addition.id,
            type: 'delete',
            entityType: 'addition',
            data: {'id': addition.id},
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Delete Deaths
    final deathsBox = await Hive.openBox<DeathEntity>('deaths');
    final deathsToDelete = deathsBox.values.where((d) => d.batchId == id).toList();
    for (final death in deathsToDelete) {
      final deathIndex = deathsBox.values.toList().indexWhere((d) => d.id == death.id);
      if (deathIndex != -1) {
        await deathsBox.deleteAt(deathIndex);
        await SyncService().queueChange(
          SyncQueueItem(
            id: death.id,
            type: 'delete',
            entityType: 'death',
            data: {'id': death.id},
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Delete Sales
    final salesBox = await Hive.openBox<SaleEntity>('sales');
    final salesToDelete = salesBox.values.where((s) => s.batchId == id).toList();
    for (final sale in salesToDelete) {
      final saleIndex = salesBox.values.toList().indexWhere((s) => s.id == sale.id);
      if (saleIndex != -1) {
        await salesBox.deleteAt(saleIndex);
        await SyncService().queueChange(
          SyncQueueItem(
            id: sale.id,
            type: 'delete',
            entityType: 'sale',
            data: {'id': sale.id},
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    // --- End Cascade Delete ---
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
