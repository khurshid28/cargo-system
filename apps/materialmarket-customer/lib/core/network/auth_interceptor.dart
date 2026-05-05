import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const kAccessTokenKey = 'access_token';
const kRefreshTokenKey = 'refresh_token';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  final FlutterSecureStorage _storage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final t = await _storage.read(key: kAccessTokenKey);
    if (t != null && t.isNotEmpty) options.headers['Authorization'] = 'Bearer $t';
    handler.next(options);
  }
}
