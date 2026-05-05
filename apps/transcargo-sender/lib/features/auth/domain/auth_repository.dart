import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.id, required this.role, required this.phone});
  final String id;
  final String role;
  final String phone;

  factory AuthUser.fromJson(Map<String, dynamic> j) =>
      AuthUser(id: j['id'] as String, role: j['role'] as String, phone: j['phone'] as String);

  @override
  List<Object?> get props => [id, role, phone];
}

abstract class AuthRepository {
  Future<void> requestOtp({required String phone, required String role});
  Future<AuthUser> verifyOtp({required String phone, required String otp, required String role});
  Future<AuthUser?> currentUser();
  Future<void> signOut();
}
