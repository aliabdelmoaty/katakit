import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/entities/sale_entity.dart';
import '../../../core/usecases/sale_usecases.dart';

// Events
abstract class SalesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSales extends SalesEvent {
  final String batchId;

  LoadSales(this.batchId);

  @override
  List<Object?> get props => [batchId];
}

class AddSale extends SalesEvent {
  final SaleEntity sale;

  AddSale(this.sale);

  @override
  List<Object?> get props => [sale];
}

class UpdateSale extends SalesEvent {
  final SaleEntity sale;

  UpdateSale(this.sale);

  @override
  List<Object?> get props => [sale];
}

class DeleteSale extends SalesEvent {
  final String id;
  final String batchId;

  DeleteSale(this.id, this.batchId);

  @override
  List<Object?> get props => [id, batchId];
}

// States
abstract class SalesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<SaleEntity> sales;
  final int totalSoldCount;
  final double totalSalesAmount;

  SalesLoaded(this.sales, this.totalSoldCount, this.totalSalesAmount);

  @override
  List<Object?> get props => [sales, totalSoldCount, totalSalesAmount];
}

class SalesError extends SalesState {
  final String message;

  SalesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SalesCubit extends Cubit<SalesState> {
  final GetSalesUseCase getSalesUseCase;
  final AddSaleUseCase addSaleUseCase;
  final UpdateSaleUseCase updateSaleUseCase;
  final DeleteSaleUseCase deleteSaleUseCase;
  final GetTotalSoldCountUseCase getTotalSoldCountUseCase;
  final GetTotalSalesAmountUseCase getTotalSalesAmountUseCase;

  SalesCubit({
    required this.getSalesUseCase,
    required this.addSaleUseCase,
    required this.updateSaleUseCase,
    required this.deleteSaleUseCase,
    required this.getTotalSoldCountUseCase,
    required this.getTotalSalesAmountUseCase,
  }) : super(SalesInitial());

  Future<void> loadSales(String batchId) async {
    emit(SalesLoading());
    try {
      final sales = await getSalesUseCase(batchId);
      final totalSoldCount = await getTotalSoldCountUseCase(batchId);
      final totalSalesAmount = await getTotalSalesAmountUseCase(batchId);
      emit(SalesLoaded(sales, totalSoldCount, totalSalesAmount));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> addSale(SaleEntity sale) async {
    try {
      await addSaleUseCase(sale);
      await loadSales(sale.batchId);
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> updateSale(SaleEntity sale) async {
    try {
      await updateSaleUseCase(sale);
      await loadSales(sale.batchId);
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> deleteSale(String id, String batchId) async {
    try {
      await deleteSaleUseCase(id);
      await loadSales(batchId);
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
}
