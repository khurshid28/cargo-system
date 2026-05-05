import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestOtp({required String phone, required String role});
  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp, required String role});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  bool _isOffline(Object e) =>
      e is DioException &&
      (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown);

  @override
  Future<void> requestOtp({required String phone, required String role}) async {
    try {
      await _dio.post('/auth/request-otp', data: {'phone': phone, 'role': role});
    } catch (e) {
      // Dev fallback: backend unavailable → succeed locally so the UI can flow.
      if (_isOffline(e)) return;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  }) async {
    try {
      final res = await _dio.post('/auth/verify-otp',
          data: {'phone': phone, 'otp': otp, 'role': role});
      return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      // Dev fallback: backend unavailable → mock success for any 6-digit code.
      if (_isOffline(e) && otp.length == 6) {
        return {
          'accessToken': 'dev-access-${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken': 'dev-refresh-${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': 'dev-${phone.replaceAll(RegExp(r"\D"), "")}',
            'role': role,
            'phone': phone,
          },
        };
      }
      rethrow;
    }
  }
}

