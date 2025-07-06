import 'package:hive_flutter/hive_flutter.dart';
import '../entities/death_entity.dart';

abstract class IDeathRepository {
  Future<List<DeathEntity>> getDeathsByBatchId(String batchId);
  Future<void> addDeath(DeathEntity death);
  Future<void> updateDeath(DeathEntity death);
  Future<void> deleteDeath(String id);
  Future<int> getTotalDeathsCount(String batchId);
}

class DeathRepository implements IDeathRepository {
  static const String _boxName = 'deaths';

  @override
  Future<List<DeathEntity>> getDeathsByBatchId(String batchId) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    return box.values.where((death) => death.batchId == batchId).toList();
  }

  @override
  Future<void> addDeath(DeathEntity death) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    await box.add(death);
  }

  @override
  Future<void> updateDeath(DeathEntity death) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    final index = box.values.toList().indexWhere((d) => d.id == death.id);
    if (index != -1) {
      await box.putAt(index, death);
    }
  }

  @override
  Future<void> deleteDeath(String id) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    final index = box.values.toList().indexWhere((d) => d.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  @override
  Future<int> getTotalDeathsCount(String batchId) async {
    final deaths = await getDeathsByBatchId(batchId);
    return deaths.fold<int>(0, (sum, death) => sum + death.count);
  }
}
