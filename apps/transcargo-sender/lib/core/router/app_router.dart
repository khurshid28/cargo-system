import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/cargo/presentation/pages/cargo_create_page.dart';
import '../../features/cargo/presentation/pages/cargo_history_page.dart';
import '../../features/home/presentation/sender_shell.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../store/profile_store.dart';

class AppRouter {
  static GoRouter create(AuthBloc auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _MultiListenable([
        GoRouterRefreshStream(auth.stream),
        ProfileStore.instance.fullName,
      ]),
      redirect: (context, state) {
        final s = auth.state;
        final loc = state.matchedLocation;

        // While auth is being checked → stay on splash
        if (s is AuthInitial) {
          return loc == '/splash' ? null : '/splash';
        }

        final loggedIn = s is AuthAuthenticated;
        final onSplash = loc == '/splash';
        final onLogin = loc == '/login';
        final onRegister = loc == '/register';
        final profileComplete =
            ProfileStore.instance.fullName.value.trim().isNotEmpty;

        if (!loggedIn) {
          if (onLogin || onRegister) return null;
          return '/login';
        }
        // Authenticated but profile not yet filled → force registration
        if (!profileComplete) {
          return onRegister ? null : '/register';
        }
        // Authenticated & profile complete
        if (onSplash || onLogin || onRegister) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
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

/// Combines multiple Listenables into one for [GoRouter.refreshListenable].
class _MultiListenable extends ChangeNotifier {
  _MultiListenable(this._sources) {
    for (final l in _sources) {
      l.addListener(notifyListeners);
    }
  }
  final List<Listenable> _sources;
  @override
  void dispose() {
    for (final l in _sources) {
      l.removeListener(notifyListeners);
    }
    super.dispose();
  }
}
