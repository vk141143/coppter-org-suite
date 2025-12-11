import 'package:equatable/equatable.dart';

abstract class DriverEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DriverLoadJobs extends DriverEvent {}

class DriverAcceptJob extends DriverEvent {
  final String jobId;

  DriverAcceptJob(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class DriverStartJob extends DriverEvent {
  final String jobId;

  DriverStartJob(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class DriverCompleteJob extends DriverEvent {
  final String jobId;
  final String? proofImageUrl;

  DriverCompleteJob(this.jobId, {this.proofImageUrl});

  @override
  List<Object?> get props => [jobId, proofImageUrl];
}

class DriverToggleOnlineStatus extends DriverEvent {}

class DriverLoadEarnings extends DriverEvent {
  final String? period;

  DriverLoadEarnings({this.period});

  @override
  List<Object?> get props => [period];
}

class DriverUpdateLocation extends DriverEvent {
  final double latitude;
  final double longitude;

  DriverUpdateLocation(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}
