import '../entities/batch_entity.dart';
import '../repositories/batch_repository.dart';
import '../models/batch_statistics.dart';
import '../repositories/addition_repository.dart';
import '../repositories/death_repository.dart';
import '../repositories/sale_repository.dart';

class GetBatchesUseCase {
  final IBatchRepository repository;

  GetBatchesUseCase(this.repository);

  Future<List<BatchEntity>> call() async {
    return await repository.getAllBatches();
  }
}

class AddBatchUseCase {
  final IBatchRepository repository;

  AddBatchUseCase(this.repository);

  Future<void> call(BatchEntity batch) async {
    await repository.addBatch(batch);
  }
}

class UpdateBatchUseCase {
  final IBatchRepository repository;

  UpdateBatchUseCase(this.repository);

  Future<void> call(BatchEntity batch) async {
    await repository.updateBatch(batch);
  }
}

class DeleteBatchUseCase {
  final IBatchRepository repository;

  DeleteBatchUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteBatch(id);
  }
}

class GetBatchStatisticsUseCase {
  final IBatchRepository batchRepository;
  final IAdditionRepository additionRepository;
  final IDeathRepository deathRepository;
  final ISaleRepository saleRepository;

  GetBatchStatisticsUseCase({
    required this.batchRepository,
    required this.additionRepository,
    required this.deathRepository,
    required this.saleRepository,
  });

  Future<BatchStatistics> call(String batchId) async {
    final batch = await batchRepository.getBatchById(batchId);
    if (batch == null) {
      throw Exception('Batch not found');
    }

    final totalAdditionsCost = await additionRepository.getTotalAdditionsCost(
      batchId,
    );
    final totalDeathsCount = await deathRepository.getTotalDeathsCount(batchId);
    final totalSoldCount = await saleRepository.getTotalSoldCount(batchId);
    final totalSalesAmount = await saleRepository.getTotalSalesAmount(batchId);

    final remainingCount = batch.chickCount - totalDeathsCount - totalSoldCount;
    final totalCost = batch.totalBuyPrice + totalAdditionsCost;
    final profitLoss = totalSalesAmount - totalCost;
    final actualCostPerChick =
        remainingCount > 0 ? totalCost / remainingCount : 0.0;

    return BatchStatistics(
      batchId: batchId,
      batchName: batch.name,
      totalChicks: batch.chickCount,
      deathsCount: totalDeathsCount,
      soldCount: totalSoldCount,
      remainingCount: remainingCount,
      totalBuyPrice: batch.totalBuyPrice,
      totalAdditionsCost: totalAdditionsCost,
      totalSalesAmount: totalSalesAmount,
      profitLoss: profitLoss,
      actualCostPerChick: actualCostPerChick,
    );
  }
}
