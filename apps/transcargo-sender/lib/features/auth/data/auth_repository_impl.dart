import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/auth_interceptor.dart';
import '../domain/auth_repository.dart';
import 'auth_remote_data_source.dart';

const _kUserKey = 'user_json';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remote, required this.storage});
  final AuthRemoteDataSource remote;
  final FlutterSecureStorage storage;

  @override
  Future<void> requestOtp({required String phone, required String role}) =>
      remote.requestOtp(phone: phone, role: role);

  @override
  Future<AuthUser> verifyOtp({required String phone, required String otp, required String role}) async {
    final res = await remote.verifyOtp(phone: phone, otp: otp, role: role);
    await storage.write(key: kAccessTokenKey, value: res['accessToken'] as String);
    await storage.write(key: kRefreshTokenKey, value: res['refreshToken'] as String);
    final userMap = Map<String, dynamic>.from(res['user'] as Map);
    await storage.write(key: _kUserKey, value: jsonEncode(userMap));
    return AuthUser.fromJson(userMap);
  }

  @override
  Future<AuthUser?> currentUser() async {
    final raw = await storage.read(key: _kUserKey);
    if (raw == null) return null;
    return AuthUser.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  @override
  Future<void> signOut() async {
    await storage.delete(key: kAccessTokenKey);
    await storage.delete(key: kRefreshTokenKey);
    await storage.delete(key: _kUserKey);
  }
}
