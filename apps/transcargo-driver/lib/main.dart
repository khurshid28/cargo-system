/// TransCargo Driver app — clean architecture (auth, jobs, online toggle).
/// Mock/real toggle via .env (USE_MOCK).
library transcargo_driver;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await Hive.initFlutter();
  await configureDependencies();

  runApp(const DriverApp());
  FlutterNativeSplash.remove();
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested())),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, _) {
          final router = AppRouter.create(context.read<AuthBloc>());
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TransCargo Driver',
            theme: AppTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
