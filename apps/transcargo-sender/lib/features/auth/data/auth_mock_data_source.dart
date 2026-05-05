import 'auth_remote_data_source.dart';

/// In-memory mock for OTP-based auth. Accepts any phone, OTP must be `666666`.
class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<void> requestOtp({required String phone, required String role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (otp.length != 6) {
      throw Exception("Kod 6 xonali bo'lishi kerak");
    }
    return {
      'accessToken': 'mock.access.token.${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'mock.refresh.token',
      'user': {
        'id': '00000000-0000-0000-0000-000000000001',
        'phone': phone,
        'role': role,
      },
    };
  }
}
