import 'package:hive_flutter/hive_flutter.dart';
import '../entities/death_entity.dart';
import '../services/sync_service.dart';
import '../services/sync_queue.dart';
import '../services/connection_service.dart';
import 'dart:developer' as dev;

abstract class IDeathRepository {
  Future<List<DeathEntity>> getDeathsByBatchId(String batchId);
  Future<void> addDeath(DeathEntity death);
  Future<void> updateDeath(DeathEntity death);
  Future<void> deleteDeath(String id);
  Future<int> getTotalDeathsCount(String batchId);
}

class DeathRepository implements IDeathRepository {
  static const String _boxName = 'deaths';

  Future<bool> _isOnline() async => await ConnectionService().isConnected;

  @override
  Future<List<DeathEntity>> getDeathsByBatchId(String batchId) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    return box.values.where((death) => death.batchId == batchId).toList();
  }

  @override
  Future<void> addDeath(DeathEntity death) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    await box.add(death);
    await SyncService().queueChange(
      SyncQueueItem(
        id: death.id,
        type: 'add',
        entityType: 'death',
        data: deathToMap(death),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateDeath(DeathEntity death) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    final index = box.values.toList().indexWhere((d) => d.id == death.id);
    if (index != -1) {
      await box.putAt(index, death);
      await SyncService().queueChange(
        SyncQueueItem(
          id: death.id,
          type: 'edit',
          entityType: 'death',
          data: deathToMap(death),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> deleteDeath(String id) async {
    final box = await Hive.openBox<DeathEntity>(_boxName);
    final index = box.values.toList().indexWhere((d) => d.id == id);
    if (index != -1) {
      final death = box.getAt(index);
      await box.deleteAt(index);
      if (death != null) {
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
  }

  @override
  Future<int> getTotalDeathsCount(String batchId) async {
    final deaths = await getDeathsByBatchId(batchId);
    return deaths.fold<int>(0, (sum, death) => sum + death.count);
  }

  Map<String, dynamic> deathToMap(DeathEntity d) => {
    'id': d.id,
    'batchid': d.batchId,
    'count': d.count,
    'date': d.date.toIso8601String(),
    'userId': d.userId,
    'updatedat': d.updatedAt.toIso8601String(),
  };
}
