import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/entities/death_entity.dart';
import '../../../core/usecases/death_usecases.dart';

// Events
abstract class DeathsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDeaths extends DeathsEvent {
  final String batchId;

  LoadDeaths(this.batchId);

  @override
  List<Object?> get props => [batchId];
}

class AddDeath extends DeathsEvent {
  final DeathEntity death;

  AddDeath(this.death);

  @override
  List<Object?> get props => [death];
}

class UpdateDeath extends DeathsEvent {
  final DeathEntity death;

  UpdateDeath(this.death);

  @override
  List<Object?> get props => [death];
}

class DeleteDeath extends DeathsEvent {
  final String id;
  final String batchId;

  DeleteDeath(this.id, this.batchId);

  @override
  List<Object?> get props => [id, batchId];
}

// States
abstract class DeathsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeathsInitial extends DeathsState {}

class DeathsLoading extends DeathsState {}

class DeathsLoaded extends DeathsState {
  final List<DeathEntity> deaths;
  final int totalDeathsCount;

  DeathsLoaded(this.deaths, this.totalDeathsCount);

  @override
  List<Object?> get props => [deaths, totalDeathsCount];
}

class DeathsError extends DeathsState {
  final String message;

  DeathsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DeathsCubit extends Cubit<DeathsState> {
  final GetDeathsUseCase getDeathsUseCase;
  final AddDeathUseCase addDeathUseCase;
  final UpdateDeathUseCase updateDeathUseCase;
  final DeleteDeathUseCase deleteDeathUseCase;
  final GetTotalDeathsCountUseCase getTotalDeathsCountUseCase;

  DeathsCubit({
    required this.getDeathsUseCase,
    required this.addDeathUseCase,
    required this.updateDeathUseCase,
    required this.deleteDeathUseCase,
    required this.getTotalDeathsCountUseCase,
  }) : super(DeathsInitial());

  Future<void> loadDeaths(String batchId) async {
    emit(DeathsLoading());
    try {
      final deaths = await getDeathsUseCase(batchId);
      final totalDeathsCount = await getTotalDeathsCountUseCase(batchId);
      emit(DeathsLoaded(deaths, totalDeathsCount));
    } catch (e) {
      emit(DeathsError(e.toString()));
    }
  }

  Future<void> addDeath(DeathEntity death) async {
    try {
      await addDeathUseCase(death);
      await loadDeaths(death.batchId);
    } catch (e) {
      emit(DeathsError(e.toString()));
    }
  }

  Future<void> updateDeath(DeathEntity death) async {
    try {
      await updateDeathUseCase(death);
      await loadDeaths(death.batchId);
    } catch (e) {
      emit(DeathsError(e.toString()));
    }
  }

  Future<void> deleteDeath(String id, String batchId) async {
    try {
      await deleteDeathUseCase(id);
      await loadDeaths(batchId);
    } catch (e) {
      emit(DeathsError(e.toString()));
    }
  }
}
