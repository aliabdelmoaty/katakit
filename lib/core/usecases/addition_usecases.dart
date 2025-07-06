import '../entities/addition_entity.dart';
import '../repositories/addition_repository.dart';

class GetAdditionsUseCase {
  final IAdditionRepository repository;

  GetAdditionsUseCase(this.repository);

  Future<List<AdditionEntity>> call(String batchId) async {
    return await repository.getAdditionsByBatchId(batchId);
  }
}

class AddAdditionUseCase {
  final IAdditionRepository repository;

  AddAdditionUseCase(this.repository);

  Future<void> call(AdditionEntity addition) async {
    await repository.addAddition(addition);
  }
}

class UpdateAdditionUseCase {
  final IAdditionRepository repository;

  UpdateAdditionUseCase(this.repository);

  Future<void> call(AdditionEntity addition) async {
    await repository.updateAddition(addition);
  }
}

class DeleteAdditionUseCase {
  final IAdditionRepository repository;

  DeleteAdditionUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteAddition(id);
  }
}

class GetTotalAdditionsCostUseCase {
  final IAdditionRepository repository;

  GetTotalAdditionsCostUseCase(this.repository);

  Future<double> call(String batchId) async {
    return await repository.getTotalAdditionsCost(batchId);
  }
}
