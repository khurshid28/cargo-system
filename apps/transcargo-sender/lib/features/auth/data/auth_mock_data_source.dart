import 'auth_remote_data_source.dart';

/// In-memory mock for OTP-based auth. Accepts any phone, OTP must be `666666`.
class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<void> requestOtp({required String phone, required String role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // ignore: avoid_print
    print('[MOCK] OTP requested for $phone (role=$role) — use 666666');
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (otp != '666666') {
      throw Exception('Noto‘g‘ri OTP (mock rejimida 666666 ni ishlating)');
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
