import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.id, required this.role, required this.phone});
  final String id;
  final String role;
  final String phone;
  @override
  List<Object?> get props => [id, role, phone];
}

abstract class AuthRepository {
  Stream<AuthUser?> get stream;
  Future<AuthUser?> currentUser();
  Future<void> requestOtp({required String phone, required String role});
  Future<AuthUser> verifyOtp({required String phone, required String otp, required String role});
  Future<void> signOut();
}
