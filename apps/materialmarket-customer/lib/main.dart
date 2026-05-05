import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await configureDependencies();
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested())),
      ],
      child: Builder(builder: (ctx) {
        final auth = ctx.read<AuthBloc>();
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'MaterialMarket',
          theme: AppTheme.light,
          routerConfig: buildRouter(auth),
        );
      }),
    );
  }
}
