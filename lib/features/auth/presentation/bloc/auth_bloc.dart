import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthPhoneOtpRequested>(_onPhoneOtpRequested);
    on<AuthPhoneOtpVerified>(_onPhoneOtpVerified);
    on<AuthEmailSubmitted>(_onEmailSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getStoredSession();
      if (user != null) {
        emit(AuthAuthenticated(uid: user.uid, displayName: user.displayName));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onPhoneOtpRequested(
    AuthPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    authRepository.phoneNumber = event.phoneNumber;
    final verId = await authRepository.sendPhoneOtp(event.phoneNumber);
    if (verId != null) {
      emit(AuthOtpSent(verificationId: verId, phoneNumber: event.phoneNumber));
    } else {
      emit(AuthError('Failed to send OTP. Check phone number and try again.'));
    }
  }

  Future<void> _onPhoneOtpVerified(
    AuthPhoneOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await authRepository.verifyPhoneOtp(
      event.verificationId,
      event.otp,
    );
    if (user != null) {
      emit(AuthAuthenticated(uid: user.uid, displayName: user.displayName));
    } else {
      emit(AuthError('Invalid OTP code. Please try again.'));
    }
  }

  Future<void> _onEmailSubmitted(
    AuthEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = event.isSignUp
        ? await authRepository.registerWithEmail(
            event.email,
            event.password,
            event.name,
          )
        : await authRepository.loginWithEmail(event.email, event.password);
    if (user != null) {
      emit(AuthAuthenticated(uid: user.uid, displayName: user.displayName));
    } else {
      emit(
        AuthError(
          event.isSignUp
              ? 'Registration failed. Try a different email.'
              : 'Invalid credentials. Check email & password.',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.clearSession();
    emit(AuthUnauthenticated());
  }
}
