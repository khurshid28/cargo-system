import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/store/profile_store.dart';
import '../../domain/auth_repository.dart';

// ---- Events ----
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}
class AuthCheckRequested extends AuthEvent { const AuthCheckRequested(); }
class AuthOtpRequested extends AuthEvent {
  const AuthOtpRequested({required this.phone, required this.role});
  final String phone; final String role;
  @override List<Object?> get props => [phone, role];
}
class AuthOtpVerified extends AuthEvent {
  const AuthOtpVerified({required this.phone, required this.otp, required this.role});
  final String phone; final String otp; final String role;
  @override List<Object?> get props => [phone, otp, role];
}
class AuthSignOutRequested extends AuthEvent { const AuthSignOutRequested(); }

// ---- States ----
abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}
class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthOtpSent extends AuthState {
  const AuthOtpSent({required this.phone, required this.role});
  final String phone; final String role;
  @override List<Object?> get props => [phone, role];
}
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
  @override List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

// ---- Bloc ----
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpVerified>(_onOtpVerified);
    on<AuthSignOutRequested>(_onSignOut);
  }
  final AuthRepository _repo;

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    final results = await Future.wait([
      _repo.currentUser(),
      Future<void>.delayed(const Duration(milliseconds: 1400)),
    ]);
    final user = results.first as AuthUser?;
    if (user != null) await ProfileStore.instance.save(phone: user.phone);
    emit(user == null ? const AuthUnauthenticated() : AuthAuthenticated(user));
  }

  Future<void> _onOtpRequested(AuthOtpRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _repo.requestOtp(phone: e.phone, role: e.role);
      emit(AuthOtpSent(phone: e.phone, role: e.role));
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onOtpVerified(AuthOtpVerified e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.verifyOtp(phone: e.phone, otp: e.otp, role: e.role);
      await ProfileStore.instance.save(phone: user.phone);
      emit(AuthAuthenticated(user));
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested e, Emitter<AuthState> emit) async {
    await _repo.signOut();
    await ProfileStore.instance.clear();
    emit(const AuthUnauthenticated());
  }
}
