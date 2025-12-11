import 'package:equatable/equatable.dart';

abstract class WasteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WasteInitial extends WasteState {}

class WasteLoading extends WasteState {}

class WasteComplaintsLoaded extends WasteState {
  final List<dynamic> complaints;

  WasteComplaintsLoaded(this.complaints);

  @override
  List<Object?> get props => [complaints];
}

class WasteCategoriesLoaded extends WasteState {
  final List<dynamic> categories;

  WasteCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class WasteRequestSubmitted extends WasteState {}

class WasteImageUploaded extends WasteState {
  final String imageUrl;

  WasteImageUploaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class WasteTrackingLoaded extends WasteState {
  final Map<String, dynamic> trackingData;

  WasteTrackingLoaded(this.trackingData);

  @override
  List<Object?> get props => [trackingData];
}

class WasteError extends WasteState {
  final String message;

  WasteError(this.message);

  @override
  List<Object?> get props => [message];
}
