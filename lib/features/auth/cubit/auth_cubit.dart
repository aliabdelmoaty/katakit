import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/auth_repository.dart';
import 'package:hive/hive.dart';

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String? email;
  final String? name;
  Authenticated({required this.userId, this.email, this.name});
  @override
  List<Object?> get props => [userId, email, name];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await authRepository.login(email, password);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(
        Authenticated(userId: user.id, email: user.email, name: user.name),
      ),
    );
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    final result = await authRepository.register(email, password, name);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(
        Authenticated(userId: user.id, email: user.email, name: user.name),
      ),
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
    await Future.wait([
      Hive.deleteBoxFromDisk('batches'),
      Hive.deleteBoxFromDisk('additions'),
      Hive.deleteBoxFromDisk('deaths'),
      Hive.deleteBoxFromDisk('sales'),
    ]);
    emit(Unauthenticated());
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    final result = await authRepository.forgotPassword(email);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> checkSession() async {
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(userId: user.id, email: user.email, name: user.name));
    } else {
      emit(Unauthenticated());
    }
  }
}
