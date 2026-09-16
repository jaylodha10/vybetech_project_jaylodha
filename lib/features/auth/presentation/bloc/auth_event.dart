part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthPhoneOtpRequested extends AuthEvent {
  final String phoneNumber;
  AuthPhoneOtpRequested(this.phoneNumber);
}

class AuthPhoneOtpVerified extends AuthEvent {
  final String verificationId;
  final String otp;
  AuthPhoneOtpVerified({required this.verificationId, required this.otp});
}

class AuthEmailSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final bool isSignUp;
  AuthEmailSubmitted({
    required this.email,
    required this.password,
    this.name = '',
    this.isSignUp = false,
  });
}

class AuthLogoutRequested extends AuthEvent {}
