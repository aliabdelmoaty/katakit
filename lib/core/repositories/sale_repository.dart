import 'package:hive_flutter/hive_flutter.dart';
import '../entities/sale_entity.dart';
import '../services/sync_service.dart';
import '../services/sync_queue.dart';
import '../services/connection_service.dart';

abstract class ISaleRepository {
  Future<List<SaleEntity>> getSalesByBatchId(String batchId);
  Future<void> addSale(SaleEntity sale);
  Future<void> updateSale(SaleEntity sale);
  Future<void> deleteSale(String id);
  Future<int> getTotalSoldCount(String batchId);
  Future<double> getTotalSalesAmount(String batchId);
}

class SaleRepository implements ISaleRepository {
  static const String _boxName = 'sales';

  Future<bool> _isOnline() async => await ConnectionService().isConnected;

  @override
  Future<List<SaleEntity>> getSalesByBatchId(String batchId) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    return box.values.where((sale) => sale.batchId == batchId).toList();
  }

  @override
  Future<void> addSale(SaleEntity sale) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    await box.add(sale);
    await SyncService().queueChange(
      SyncQueueItem(
        id: sale.id,
        type: 'add',
        entityType: 'sale',
        data: saleToMap(sale),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateSale(SaleEntity sale) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    final index = box.values.toList().indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      await box.putAt(index, sale);
      await SyncService().queueChange(
        SyncQueueItem(
          id: sale.id,
          type: 'edit',
          entityType: 'sale',
          data: saleToMap(sale),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    final index = box.values.toList().indexWhere((s) => s.id == id);
    if (index != -1) {
      final sale = box.getAt(index);
      await box.deleteAt(index);
      if (sale != null) {
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
  }

  @override
  Future<int> getTotalSoldCount(String batchId) async {
    final sales = await getSalesByBatchId(batchId);
    return sales.fold<int>(0, (sum, sale) => sum + sale.chickCount);
  }

  @override
  Future<double> getTotalSalesAmount(String batchId) async {
    final sales = await getSalesByBatchId(batchId);
    return sales.fold<double>(0.0, (sum, sale) => sum + sale.paidAmount);
  }

  Map<String, dynamic> saleToMap(SaleEntity s) => {
    'id': s.id,
    'batchid': s.batchId,
    'buyername': s.buyerName,
    'date': s.date.toIso8601String(),
    'chickcount': s.chickCount,
    'priceperchick': s.pricePerChick,
    'paidamount': s.paidAmount,
    'note': s.note,
    'userId': s.userId,
    'updatedat': s.updatedAt.toIso8601String(),
  };
}
