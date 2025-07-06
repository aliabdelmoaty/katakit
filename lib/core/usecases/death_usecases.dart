import '../entities/death_entity.dart';
import '../repositories/death_repository.dart';

class GetDeathsUseCase {
  final IDeathRepository repository;

  GetDeathsUseCase(this.repository);

  Future<List<DeathEntity>> call(String batchId) async {
    return await repository.getDeathsByBatchId(batchId);
  }
}

class AddDeathUseCase {
  final IDeathRepository repository;

  AddDeathUseCase(this.repository);

  Future<void> call(DeathEntity death) async {
    await repository.addDeath(death);
  }
}

class UpdateDeathUseCase {
  final IDeathRepository repository;

  UpdateDeathUseCase(this.repository);

  Future<void> call(DeathEntity death) async {
    await repository.updateDeath(death);
  }
}

class DeleteDeathUseCase {
  final IDeathRepository repository;

  DeleteDeathUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteDeath(id);
  }
}

class GetTotalDeathsCountUseCase {
  final IDeathRepository repository;

  GetTotalDeathsCountUseCase(this.repository);

  Future<int> call(String batchId) async {
    return await repository.getTotalDeathsCount(batchId);
  }
}
