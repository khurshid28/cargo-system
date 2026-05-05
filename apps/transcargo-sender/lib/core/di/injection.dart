import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../env/app_env.dart';
import '../network/auth_interceptor.dart';
import '../../features/auth/data/auth_mock_data_source.dart';
import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cargo/data/cargo_mock_data_source.dart';
import '../../features/cargo/data/cargo_remote_data_source.dart';
import '../../features/cargo/data/cargo_repository_impl.dart';
import '../../features/cargo/domain/cargo_repository.dart';
import '../../features/cargo/presentation/bloc/cargo_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final useMock = AppEnv.useMock;
  if (kDebugMode) {
    // ignore: avoid_print
    print('[DI] USE_MOCK=$useMock  API_BASE_URL=${AppEnv.apiBaseUrl}');
  }

  // External
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // Dio (still registered even in mock mode — repos can choose).
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.addAll([
      AuthInterceptor(sl<FlutterSecureStorage>()),
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        error: true,
      ),
    ]);
    return dio;
  });

  // Auth feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => useMock ? AuthMockDataSource() : AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      storage: sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));

  // Cargo feature
  sl.registerLazySingleton<CargoRemoteDataSource>(
    () => useMock ? CargoMockDataSource() : CargoRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CargoRepository>(
    () => CargoRepositoryImpl(sl<CargoRemoteDataSource>()),
  );
  sl.registerFactory<CargoBloc>(() => CargoBloc(sl<CargoRepository>()));
}
