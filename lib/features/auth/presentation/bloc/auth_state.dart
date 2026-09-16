part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  AuthOtpSent({required this.verificationId, required this.phoneNumber});
}

class AuthAuthenticated extends AuthState {
  final String uid;
  final String displayName;
  AuthAuthenticated({required this.uid, required this.displayName});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
