import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static bool get useMock => (dotenv.maybeGet('USE_MOCK') ?? 'true').toLowerCase() == 'true';
  static String get apiBaseUrl => dotenv.maybeGet('API_BASE_URL') ?? 'http://10.0.2.2:3001/api';
  static String get wsUrl => dotenv.maybeGet('WS_URL') ?? 'http://10.0.2.2:3001';
}
