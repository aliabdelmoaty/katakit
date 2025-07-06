import 'package:hive_flutter/hive_flutter.dart';
import '../entities/addition_entity.dart';

abstract class IAdditionRepository {
  Future<List<AdditionEntity>> getAdditionsByBatchId(String batchId);
  Future<void> addAddition(AdditionEntity addition);
  Future<void> updateAddition(AdditionEntity addition);
  Future<void> deleteAddition(String id);
  Future<double> getTotalAdditionsCost(String batchId);
}

class AdditionRepository implements IAdditionRepository {
  static const String _boxName = 'additions';

  @override
  Future<List<AdditionEntity>> getAdditionsByBatchId(String batchId) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    return box.values.where((addition) => addition.batchId == batchId).toList();
  }

  @override
  Future<void> addAddition(AdditionEntity addition) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    await box.add(addition);
  }

  @override
  Future<void> updateAddition(AdditionEntity addition) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    final index = box.values.toList().indexWhere((a) => a.id == addition.id);
    if (index != -1) {
      await box.putAt(index, addition);
    }
  }

  @override
  Future<void> deleteAddition(String id) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    final index = box.values.toList().indexWhere((a) => a.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  @override
  Future<double> getTotalAdditionsCost(String batchId) async {
    final additions = await getAdditionsByBatchId(batchId);
    return additions.fold<double>(0.0, (sum, addition) => sum + addition.cost);
  }
}
