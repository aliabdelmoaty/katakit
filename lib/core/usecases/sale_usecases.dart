import '../entities/sale_entity.dart';
import '../repositories/sale_repository.dart';

class GetSalesUseCase {
  final ISaleRepository repository;

  GetSalesUseCase(this.repository);

  Future<List<SaleEntity>> call(String batchId) async {
    return await repository.getSalesByBatchId(batchId);
  }
}

class AddSaleUseCase {
  final ISaleRepository repository;

  AddSaleUseCase(this.repository);

  Future<void> call(SaleEntity sale) async {
    await repository.addSale(sale);
  }
}

class UpdateSaleUseCase {
  final ISaleRepository repository;

  UpdateSaleUseCase(this.repository);

  Future<void> call(SaleEntity sale) async {
    await repository.updateSale(sale);
  }
}

class DeleteSaleUseCase {
  final ISaleRepository repository;

  DeleteSaleUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteSale(id);
  }
}

class GetTotalSoldCountUseCase {
  final ISaleRepository repository;

  GetTotalSoldCountUseCase(this.repository);

  Future<int> call(String batchId) async {
    return await repository.getTotalSoldCount(batchId);
  }
}

class GetTotalSalesAmountUseCase {
  final ISaleRepository repository;

  GetTotalSalesAmountUseCase(this.repository);

  Future<double> call(String batchId) async {
    return await repository.getTotalSalesAmount(batchId);
  }
}
