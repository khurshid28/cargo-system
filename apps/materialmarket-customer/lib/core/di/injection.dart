import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../env/app_env.dart';
import '../network/auth_interceptor.dart';
import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cart/data/cart_store.dart';
import '../../features/catalog/data/catalog_remote_data_source.dart';
import '../../features/orders/data/orders_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final useMock = AppEnv.useMock;
  if (kDebugMode) {
    // ignore: avoid_print
    print('[DI] USE_MOCK=$useMock  API=${AppEnv.apiBaseUrl}');
  }

  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  sl.registerLazySingleton<Dio>(() {
    final d = Dio(BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    d.interceptors.addAll([
      AuthInterceptor(sl<FlutterSecureStorage>()),
      PrettyDioLogger(requestBody: true, responseBody: true, error: true),
    ]);
    return d;
  });

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => useMock ? AuthMockDataSource() : AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl<AuthRemoteDataSource>(), storage: sl<FlutterSecureStorage>()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));

  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => useMock ? CatalogMockDataSource() : CatalogRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => useMock ? OrdersMockDataSource() : OrdersRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<CartStore>(() => CartStore());
}
