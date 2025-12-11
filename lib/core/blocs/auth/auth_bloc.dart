import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOTPVerifyRequested>(_onOTPVerifyRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthLoadProfile>(_onLoadProfile);
    on<AuthUpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      try {
        final user = await _authService.getUserProfile();
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.login(event.phone, event.userType);
      emit(AuthOTPSent(event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOTPVerifyRequested(AuthOTPVerifyRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authService.verifyOTP(event.phone, event.otp, event.userType);
      emit(AuthAuthenticated(response['user']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authService.register(event.userData);
      emit(AuthAuthenticated(response['user']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onLoadProfile(AuthLoadProfile event, Emitter<AuthState> emit) async {
    try {
      final user = await _authService.getUserProfile();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(AuthUpdateProfile event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.updateProfile(
        fullName: event.data['full_name'],
        email: event.data['email'],
        phoneNumber: event.data['phone_number'],
      );
      final user = await _authService.getUserProfile();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authService.dispose();
    return super.close();
  }
}
