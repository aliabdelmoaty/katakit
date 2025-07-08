import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/auth_error_messages.dart';

class UserModel {
  final String id;
  final String? email;
  final String? name;
  UserModel({required this.id, this.email, this.name});
}

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Either<String, UserModel>> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return Left('user_not_found');
      return Right(
        UserModel(
          id: user.id,
          email: user.email,
          name: user.userMetadata?['name'],
        ),
      );
    } catch (e) {
      // Try to extract code from SupabaseException
      if (e is AuthException && e.statusCode != null) {
        return Left(e.statusCode!);
      } else if (e is AuthException) {
        // Try to parse code from message
        final match = RegExp(r'code: (\w+)').firstMatch(e.message);
        if (match != null) {
          return Left(match.group(1)!);
        }
      }
      // fallback: try to parse error string
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      final user = response.user;
      if (user == null) return Left('user_not_found');
      return Right(
        UserModel(
          id: user.id,
          email: user.email,
          name: user.userMetadata?['name'],
        ),
      );
    } catch (e) {
      if (e is AuthException && e.statusCode != null) {
        return Left(e.statusCode!);
      } else if (e is AuthException) {
        final match = RegExp(r'code: (\w+)').firstMatch(e.message);
        if (match != null) {
          return Left(match.group(1)!);
        }
      }
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> logout() async {
    try {
      // Sign out with global scope to ensure complete logout from all sessions
      await _client.auth.signOut(scope: SignOutScope.global);
      return Right(null);
    } catch (e) {
      return Left('خطأ في تسجيل الخروج: ${e.toString()}');
    }
  }

  Future<Either<String, void>> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return Right(null);
    } catch (e) {
      if (e is AuthException && e.statusCode != null) {
        return Left(e.statusCode!);
      } else if (e is AuthException) {
        final match = RegExp(r'code: (\w+)').firstMatch(e.message);
        if (match != null) {
          return Left(match.group(1)!);
        }
      }
      return Left(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['name'],
    );
  }

  Future<Either<String, void>> sendOtpToEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> verifyOtp(String email, String otp) async {
    try {
      await _client.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// Either implementation (بدائية)
class Left<L, R> {
  final L value;
  Left(this.value);
  void fold(Function(L l) left, Function(R r) right) => left(value);
}

class Right<L, R> {
  final R value;
  Right(this.value);
  void fold(Function(L l) left, Function(R r) right) => right(value);
}

typedef Either<L, R> = dynamic; // فقط للواجهة
