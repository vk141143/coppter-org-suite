import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String phone;
  final String userType;

  AuthLoginRequested(this.phone, this.userType);

  @override
  List<Object?> get props => [phone, userType];
}

class AuthOTPVerifyRequested extends AuthEvent {
  final String phone;
  final String otp;
  final String userType;

  AuthOTPVerifyRequested(this.phone, this.otp, this.userType);

  @override
  List<Object?> get props => [phone, otp, userType];
}

class AuthRegisterRequested extends AuthEvent {
  final Map<String, dynamic> userData;

  AuthRegisterRequested(this.userData);

  @override
  List<Object?> get props => [userData];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthLoadProfile extends AuthEvent {}

class AuthUpdateProfile extends AuthEvent {
  final Map<String, dynamic> data;

  AuthUpdateProfile(this.data);

  @override
  List<Object?> get props => [data];
}

class AuthCheckStatus extends AuthEvent {}
