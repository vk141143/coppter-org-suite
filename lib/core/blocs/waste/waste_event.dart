import 'package:equatable/equatable.dart';

abstract class WasteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WasteSubmitRequest extends WasteEvent {
  final double latitude;
  final double longitude;
  final String wasteType;
  final String description;
  final String? imageUrl;

  WasteSubmitRequest({
    required this.latitude,
    required this.longitude,
    required this.wasteType,
    required this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [latitude, longitude, wasteType, description, imageUrl];
}

class WasteLoadComplaints extends WasteEvent {
  final String? status;

  WasteLoadComplaints({this.status});

  @override
  List<Object?> get props => [status];
}

class WasteLoadCategories extends WasteEvent {}

class WasteUploadImage extends WasteEvent {
  final String filePath;

  WasteUploadImage(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class WasteTrackVehicle extends WasteEvent {
  final String complaintId;

  WasteTrackVehicle(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}
