import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/entities/addition_entity.dart';
import '../../../core/usecases/addition_usecases.dart';

// Events
abstract class AdditionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAdditions extends AdditionsEvent {
  final String batchId;

  LoadAdditions(this.batchId);

  @override
  List<Object?> get props => [batchId];
}

class AddAddition extends AdditionsEvent {
  final AdditionEntity addition;

  AddAddition(this.addition);

  @override
  List<Object?> get props => [addition];
}

class UpdateAddition extends AdditionsEvent {
  final AdditionEntity addition;

  UpdateAddition(this.addition);

  @override
  List<Object?> get props => [addition];
}

class DeleteAddition extends AdditionsEvent {
  final String id;
  final String batchId;

  DeleteAddition(this.id, this.batchId);

  @override
  List<Object?> get props => [id, batchId];
}

// States
abstract class AdditionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdditionsInitial extends AdditionsState {}

class AdditionsLoading extends AdditionsState {}

class AdditionsLoaded extends AdditionsState {
  final List<AdditionEntity> additions;
  final double totalCost;

  AdditionsLoaded(this.additions, this.totalCost);

  @override
  List<Object?> get props => [additions, totalCost];
}

class AdditionsError extends AdditionsState {
  final String message;

  AdditionsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AdditionsCubit extends Cubit<AdditionsState> {
  final GetAdditionsUseCase getAdditionsUseCase;
  final AddAdditionUseCase addAdditionUseCase;
  final UpdateAdditionUseCase updateAdditionUseCase;
  final DeleteAdditionUseCase deleteAdditionUseCase;
  final GetTotalAdditionsCostUseCase getTotalAdditionsCostUseCase;

  AdditionsCubit({
    required this.getAdditionsUseCase,
    required this.addAdditionUseCase,
    required this.updateAdditionUseCase,
    required this.deleteAdditionUseCase,
    required this.getTotalAdditionsCostUseCase,
  }) : super(AdditionsInitial());

  Future<void> loadAdditions(String batchId) async {
    emit(AdditionsLoading());
    try {
      final additions = await getAdditionsUseCase(batchId);
      final totalCost = await getTotalAdditionsCostUseCase(batchId);
      emit(AdditionsLoaded(additions, totalCost));
    } catch (e) {
      emit(AdditionsError(e.toString()));
    }
  }

  Future<void> addAddition(AdditionEntity addition) async {
    try {
      await addAdditionUseCase(addition);
      await loadAdditions(addition.batchId);
    } catch (e) {
      emit(AdditionsError(e.toString()));
    }
  }

  Future<void> updateAddition(AdditionEntity addition) async {
    try {
      await updateAdditionUseCase(addition);
      await loadAdditions(addition.batchId);
    } catch (e) {
      emit(AdditionsError(e.toString()));
    }
  }

  Future<void> deleteAddition(String id, String batchId) async {
    try {
      await deleteAdditionUseCase(id);
      await loadAdditions(batchId);
    } catch (e) {
      emit(AdditionsError(e.toString()));
    }
  }
}
