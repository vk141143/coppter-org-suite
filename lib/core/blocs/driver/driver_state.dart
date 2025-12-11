import 'package:equatable/equatable.dart';

abstract class DriverState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverJobsLoaded extends DriverState {
  final List<dynamic> jobs;
  final bool isOnline;

  DriverJobsLoaded(this.jobs, {this.isOnline = false});

  @override
  List<Object?> get props => [jobs, isOnline];
}

class DriverEarningsLoaded extends DriverState {
  final Map<String, dynamic> earnings;

  DriverEarningsLoaded(this.earnings);

  @override
  List<Object?> get props => [earnings];
}

class DriverJobAccepted extends DriverState {}

class DriverJobCompleted extends DriverState {}

class DriverOnlineStatusChanged extends DriverState {
  final bool isOnline;

  DriverOnlineStatusChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class DriverError extends DriverState {
  final String message;

  DriverError(this.message);

  @override
  List<Object?> get props => [message];
}
