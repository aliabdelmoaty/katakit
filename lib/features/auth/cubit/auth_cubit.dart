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

class OtpSent extends AuthState {
  final String email;
  OtpSent(this.email);
  @override
  List<Object?> get props => [email];
}

class OtpVerified extends AuthState {
  final String email;
  OtpVerified(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordResetSuccess extends AuthState {}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> login(
    String email,
    String password, {
    void Function(String userId)? onLoginSuccess,
  }) async {
    emit(AuthLoading());
    final result = await authRepository.login(email, password);
    result.fold((failure) => emit(AuthError(failure)), (user) {
      emit(Authenticated(userId: user.id, email: user.email, name: user.name));
      if (onLoginSuccess != null) onLoginSuccess(user.id);
    });
  }

  Future<void> register(
    String email,
    String password,
    String name, {
    void Function(String userId)? onRegisterSuccess,
  }) async {
    emit(AuthLoading());
    final result = await authRepository.register(email, password, name);
    result.fold((failure) => emit(AuthError(failure)), (user) {
      emit(Authenticated(userId: user.id, email: user.email, name: user.name));
      if (onRegisterSuccess != null) onRegisterSuccess(user.id);
    });
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

  Future<void> sendOtpToEmail(String email) async {
    emit(AuthLoading());
    final result = await authRepository.sendOtpToEmail(email);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(OtpSent(email)),
    );
  }

  Future<void> verifyOtp(String email, String otp) async {
    emit(AuthLoading());
    final result = await authRepository.verifyOtp(email, otp);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(OtpVerified(email)),
    );
  }

  Future<void> resetPassword(String newPassword) async {
    emit(AuthLoading());
    final result = await authRepository.updatePassword(newPassword);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(PasswordResetSuccess()),
    );
  }
}
