import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/driver_shell.dart';

class AppRouter {
  static GoRouter create(AuthBloc auth) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(auth.stream),
      redirect: (ctx, state) {
        final logged = auth.state is AuthAuthenticated;
        final goingLogin = state.matchedLocation == '/login';
        if (!logged && !goingLogin) return '/login';
        if (logged && goingLogin) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/', builder: (_, __) => const DriverShell()),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
