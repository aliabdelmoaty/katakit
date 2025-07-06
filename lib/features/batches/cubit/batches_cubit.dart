import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/entities/batch_entity.dart';
import '../../../core/usecases/batch_usecases.dart';

// Events
abstract class BatchesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBatches extends BatchesEvent {}

class AddBatch extends BatchesEvent {
  final BatchEntity batch;

  AddBatch(this.batch);

  @override
  List<Object?> get props => [batch];
}

class UpdateBatch extends BatchesEvent {
  final BatchEntity batch;

  UpdateBatch(this.batch);

  @override
  List<Object?> get props => [batch];
}

class DeleteBatch extends BatchesEvent {
  final String id;

  DeleteBatch(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class BatchesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BatchesInitial extends BatchesState {}

class BatchesLoading extends BatchesState {}

class BatchesLoaded extends BatchesState {
  final List<BatchEntity> batches;

  BatchesLoaded(this.batches);

  @override
  List<Object?> get props => [batches];
}

class BatchesError extends BatchesState {
  final String message;

  BatchesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class BatchesCubit extends Cubit<BatchesState> {
  final GetBatchesUseCase getBatchesUseCase;
  final AddBatchUseCase addBatchUseCase;
  final UpdateBatchUseCase updateBatchUseCase;
  final DeleteBatchUseCase deleteBatchUseCase;

  BatchesCubit({
    required this.getBatchesUseCase,
    required this.addBatchUseCase,
    required this.updateBatchUseCase,
    required this.deleteBatchUseCase,
  }) : super(BatchesInitial());

  Future<void> loadBatches() async {
    emit(BatchesLoading());
    try {
      final batches = await getBatchesUseCase();
      emit(BatchesLoaded(batches));
    } catch (e) {
      emit(BatchesError(e.toString()));
    }
  }

  Future<void> addBatch(BatchEntity batch) async {
    try {
      await addBatchUseCase(batch);
      await loadBatches();
    } catch (e) {
      emit(BatchesError(e.toString()));
    }
  }

  Future<void> updateBatch(BatchEntity batch) async {
    try {
      await updateBatchUseCase(batch);
      await loadBatches();
    } catch (e) {
      emit(BatchesError(e.toString()));
    }
  }

  Future<void> deleteBatch(String id) async {
    try {
      await deleteBatchUseCase(id);
      await loadBatches();
    } catch (e) {
      emit(BatchesError(e.toString()));
    }
  }
}
