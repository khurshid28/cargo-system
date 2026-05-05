import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent { const AuthCheckRequested(); }
class AuthOtpRequested extends AuthEvent {
  const AuthOtpRequested({required this.phone, required this.role});
  final String phone;
  final String role;
  @override
  List<Object?> get props => [phone, role];
}
class AuthOtpVerified extends AuthEvent {
  const AuthOtpVerified({required this.phone, required this.otp, required this.role});
  final String phone;
  final String otp;
  final String role;
  @override
  List<Object?> get props => [phone, otp, role];
}
class AuthSignOutRequested extends AuthEvent { const AuthSignOutRequested(); }

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }
class AuthOtpSent extends AuthState { const AuthOtpSent(); }
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthInitial()) {
    on<AuthCheckRequested>((e, emit) async {
      final u = await _repo.currentUser();
      emit(u != null ? AuthAuthenticated(u) : const AuthUnauthenticated());
    });
    on<AuthOtpRequested>((e, emit) async {
      emit(const AuthLoading());
      try {
        await _repo.requestOtp(phone: e.phone, role: e.role);
        emit(const AuthOtpSent());
      } catch (err) {
        emit(AuthError(err.toString()));
      }
    });
    on<AuthOtpVerified>((e, emit) async {
      emit(const AuthLoading());
      try {
        final u = await _repo.verifyOtp(phone: e.phone, otp: e.otp, role: e.role);
        emit(AuthAuthenticated(u));
      } catch (err) {
        emit(AuthError(err.toString()));
      }
    });
    on<AuthSignOutRequested>((e, emit) async {
      await _repo.signOut();
      emit(const AuthUnauthenticated());
    });
  }
  final AuthRepository _repo;
}
