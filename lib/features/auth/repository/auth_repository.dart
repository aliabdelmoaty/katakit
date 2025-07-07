import 'package:supabase_flutter/supabase_flutter.dart';

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
      if (user == null) return Left('لم يتم العثور على المستخدم');
      return Right(
        UserModel(
          id: user.id,
          email: user.email,
          name: user.userMetadata?['name'],
        ),
      );
    } catch (e) {
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
      if (user == null) return Left('لم يتم إنشاء المستخدم');
      return Right(UserModel(id: user.id, email: user.email, name: name));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<Either<String, void>> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return Right(null);
    } catch (e) {
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
