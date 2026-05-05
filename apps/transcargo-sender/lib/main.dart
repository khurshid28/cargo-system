import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/store/profile_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Load env (mock vs real toggle, API base URL, etc.)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env missing — defaults will apply.
  }

  await Hive.initFlutter();
  await configureDependencies();
  await ProfileStore.instance.load();

  runApp(const TransCargoSenderApp());
  FlutterNativeSplash.remove();
}

class TransCargoSenderApp extends StatelessWidget {
  const TransCargoSenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested())),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final router = AppRouter.create(context.read<AuthBloc>());
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TransCargo — Sender',
            theme: AppTheme.light,
            routerConfig: router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('uz'), Locale('ru')],
          );
        },
      ),
    );
  }
}
