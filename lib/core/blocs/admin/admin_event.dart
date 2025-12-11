import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminLoadDashboardStats extends AdminEvent {}

class AdminLoadComplaints extends AdminEvent {
  final String? status;
  final String? category;

  AdminLoadComplaints({this.status, this.category});

  @override
  List<Object?> get props => [status, category];
}

class AdminAssignDriver extends AdminEvent {
  final String complaintId;
  final String driverId;

  AdminAssignDriver(this.complaintId, this.driverId);

  @override
  List<Object?> get props => [complaintId, driverId];
}

class AdminLoadDrivers extends AdminEvent {
  final String? status;

  AdminLoadDrivers({this.status});

  @override
  List<Object?> get props => [status];
}

class AdminApproveDriver extends AdminEvent {
  final String driverId;

  AdminApproveDriver(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class AdminLoadUsers extends AdminEvent {
  final String? searchQuery;

  AdminLoadUsers({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}
