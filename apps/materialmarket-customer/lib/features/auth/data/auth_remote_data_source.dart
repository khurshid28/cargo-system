import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestOtp({required String phone, required String role});
  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp, required String role});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;
  @override
  Future<void> requestOtp({required String phone, required String role}) =>
      _dio.post('/auth/request-otp', data: {'phone': phone, 'role': role});
  @override
  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp, required String role}) async {
    final r = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp, 'role': role});
    return Map<String, dynamic>.from(r.data as Map);
  }
}

class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<void> requestOtp({required String phone, required String role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
  @override
  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp, required String role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (otp != '666666') throw Exception('Noto‘g‘ri OTP (mock: 666666)');
    return {
      'accessToken': 'mock.${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'mock.refresh',
      'user': {
        'id': '00000000-0000-0000-0000-0000000000c1',
        'phone': phone,
        'role': role,
      },
    };
  }
}
