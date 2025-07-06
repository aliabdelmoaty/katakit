import 'package:hive_flutter/hive_flutter.dart';
import '../entities/batch_entity.dart';

abstract class IBatchRepository {
  Future<List<BatchEntity>> getAllBatches();
  Future<BatchEntity?> getBatchById(String id);
  Future<void> addBatch(BatchEntity batch);
  Future<void> updateBatch(BatchEntity batch);
  Future<void> deleteBatch(String id);
}

class BatchRepository implements IBatchRepository {
  static const String _boxName = 'batches';

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
  }

  @override
  Future<void> updateBatch(BatchEntity batch) async {
    final box = await Hive.openBox<BatchEntity>(_boxName);
    final index = box.values.toList().indexWhere((b) => b.id == batch.id);
    if (index != -1) {
      await box.putAt(index, batch);
    }
  }

  @override
  Future<void> deleteBatch(String id) async {
    final box = await Hive.openBox<BatchEntity>(_boxName);
    final index = box.values.toList().indexWhere((b) => b.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }
}
