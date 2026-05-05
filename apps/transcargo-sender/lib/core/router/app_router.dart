import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/cargo/presentation/pages/cargo_create_page.dart';
import '../../features/cargo/presentation/pages/cargo_history_page.dart';
import '../../features/home/presentation/sender_shell.dart';

class AppRouter {
  static GoRouter create(AuthBloc auth) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(auth.stream),
      redirect: (context, state) {
        final loggedIn = auth.state is AuthAuthenticated;
        final loggingIn = state.matchedLocation == '/login';
        if (!loggedIn) return loggingIn ? null : '/login';
        if (loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(
          path: '/',
          builder: (_, __) => const SenderShell(),
          routes: [
            GoRoute(path: 'create', builder: (_, __) => const CargoCreatePage()),
            GoRoute(path: 'history', builder: (_, __) => const CargoHistoryPage()),
          ],
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Sahifa topilmadi: ${state.uri}')),
      ),
    );
  }
}

/// Adapter so go_router refreshes when AuthBloc emits new states.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() { _sub.cancel(); super.dispose(); }
}
