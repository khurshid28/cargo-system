import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_shell.dart';

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._bloc) {
    _sub = _bloc.stream.listen((_) => notifyListeners());
  }
  final AuthBloc _bloc;
  late final dynamic _sub;
  @override
  void dispose() {
    (_sub as dynamic).cancel();
    super.dispose();
  }
}

GoRouter buildRouter(AuthBloc auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthNotifier(auth),
    redirect: (ctx, state) {
      final s = auth.state;
      final loggedIn = s is AuthAuthenticated;
      final atLogin = state.matchedLocation == '/login';
      if (s is AuthInitial || s is AuthLoading) return null;
      if (!loggedIn && !atLogin) return '/login';
      if (loggedIn && atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/', builder: (_, __) => const HomeShell()),
    ],
  );
}
