import 'dart:async';
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
  final _ctrl = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get stream => _ctrl.stream;

  @override
  Future<AuthUser?> currentUser() async {
    final raw = await storage.read(key: _kUserKey);
    if (raw == null) return null;
    final m = json.decode(raw) as Map<String, dynamic>;
    return AuthUser(id: m['id'], role: m['role'], phone: m['phone']);
  }

  @override
  Future<void> requestOtp({required String phone, required String role}) =>
      remote.requestOtp(phone: phone, role: role);

  @override
  Future<AuthUser> verifyOtp({required String phone, required String otp, required String role}) async {
    final r = await remote.verifyOtp(phone: phone, otp: otp, role: role);
    await storage.write(key: kAccessTokenKey, value: r['accessToken'] as String);
    await storage.write(key: kRefreshTokenKey, value: r['refreshToken'] as String);
    final u = r['user'] as Map<String, dynamic>;
    final user = AuthUser(id: u['id'], role: u['role'], phone: u['phone']);
    await storage.write(key: _kUserKey, value: json.encode(u));
    _ctrl.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await storage.deleteAll();
    _ctrl.add(null);
  }
}
