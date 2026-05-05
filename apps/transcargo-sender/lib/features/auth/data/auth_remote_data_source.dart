import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestOtp({required String phone, required String role});
  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp, required String role});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<void> requestOtp({required String phone, required String role}) async {
    await _dio.post('/auth/request-otp', data: {'phone': phone, 'role': role});
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  }) async {
    final res = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp, 'role': role});
    return Map<String, dynamic>.from(res.data as Map);
  }
}
