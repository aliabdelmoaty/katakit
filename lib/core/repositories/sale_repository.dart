import 'package:hive_flutter/hive_flutter.dart';
import '../entities/sale_entity.dart';

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

  @override
  Future<List<SaleEntity>> getSalesByBatchId(String batchId) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    return box.values.where((sale) => sale.batchId == batchId).toList();
  }

  @override
  Future<void> addSale(SaleEntity sale) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    await box.add(sale);
  }

  @override
  Future<void> updateSale(SaleEntity sale) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    final index = box.values.toList().indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      await box.putAt(index, sale);
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    final box = await Hive.openBox<SaleEntity>(_boxName);
    final index = box.values.toList().indexWhere((s) => s.id == id);
    if (index != -1) {
      await box.deleteAt(index);
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
}
