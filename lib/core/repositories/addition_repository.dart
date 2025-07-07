import 'package:hive_flutter/hive_flutter.dart';
import '../entities/addition_entity.dart';
import '../services/sync_service.dart';
import '../services/sync_queue.dart';
import '../services/connection_service.dart';
import 'dart:developer' as dev;

abstract class IAdditionRepository {
  Future<List<AdditionEntity>> getAdditionsByBatchId(String batchId);
  Future<void> addAddition(AdditionEntity addition);
  Future<void> updateAddition(AdditionEntity addition);
  Future<void> deleteAddition(String id);
  Future<double> getTotalAdditionsCost(String batchId);
}

class AdditionRepository implements IAdditionRepository {
  static const String _boxName = 'additions';

  Future<bool> _isOnline() async => await ConnectionService().isConnected;

  @override
  Future<List<AdditionEntity>> getAdditionsByBatchId(String batchId) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    return box.values.where((addition) => addition.batchId == batchId).toList();
  }

  @override
  Future<void> addAddition(AdditionEntity addition) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    await box.add(addition);
    if (!await _isOnline()) {
      await SyncService().queueChange(
        SyncQueueItem(
          id: addition.id,
          type: 'add',
          entityType: 'addition',
          data: additionToMap(addition),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> updateAddition(AdditionEntity addition) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    final index = box.values.toList().indexWhere((a) => a.id == addition.id);
    if (index != -1) {
      await box.putAt(index, addition);
      if (!await _isOnline()) {
        await SyncService().queueChange(
          SyncQueueItem(
            id: addition.id,
            type: 'edit',
            entityType: 'addition',
            data: additionToMap(addition),
            createdAt: DateTime.now(),
          ),
        );
      }
    }
  }

  @override
  Future<void> deleteAddition(String id) async {
    final box = await Hive.openBox<AdditionEntity>(_boxName);
    final index = box.values.toList().indexWhere((a) => a.id == id);
    if (index != -1) {
      final addition = box.getAt(index);
      await box.deleteAt(index);
      if (addition != null && !await _isOnline()) {
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
  }

  @override
  Future<double> getTotalAdditionsCost(String batchId) async {
    final additions = await getAdditionsByBatchId(batchId);
    return additions.fold<double>(0.0, (sum, addition) => sum + addition.cost);
  }

  Map<String, dynamic> additionToMap(AdditionEntity a) => {
    'id': a.id,
    'batchId': a.batchId,
    'name': a.name,
    'cost': a.cost,
    'date': a.date.toIso8601String(),
    'userId': a.userId,
    'updatedAt': a.updatedAt.toIso8601String(),
  };
}
