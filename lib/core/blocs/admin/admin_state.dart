import 'package:equatable/equatable.dart';

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final Map<String, dynamic> stats;

  AdminStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AdminComplaintsLoaded extends AdminState {
  final List<dynamic> complaints;

  AdminComplaintsLoaded(this.complaints);

  @override
  List<Object?> get props => [complaints];
}

class AdminDriversLoaded extends AdminState {
  final List<dynamic> drivers;

  AdminDriversLoaded(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

class AdminUsersLoaded extends AdminState {
  final List<dynamic> users;

  AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class AdminDriverAssigned extends AdminState {}

class AdminDriverApproved extends AdminState {}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
