import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/waste_service.dart';
import 'waste_event.dart';
import 'waste_state.dart';

class WasteBloc extends Bloc<WasteEvent, WasteState> {
  final WasteService _wasteService = WasteService();

  WasteBloc() : super(WasteInitial()) {
    on<WasteSubmitRequest>(_onSubmitRequest);
    on<WasteLoadComplaints>(_onLoadComplaints);
    on<WasteLoadCategories>(_onLoadCategories);
    on<WasteUploadImage>(_onUploadImage);
    on<WasteTrackVehicle>(_onTrackVehicle);
  }

  Future<void> _onSubmitRequest(WasteSubmitRequest event, Emitter<WasteState> emit) async {
    emit(WasteLoading());
    try {
      await _wasteService.submitWasteRequest(
        latitude: event.latitude,
        longitude: event.longitude,
        wasteType: event.wasteType,
        description: event.description,
        imageUrl: event.imageUrl,
      );
      emit(WasteRequestSubmitted());
    } catch (e) {
      emit(WasteError(e.toString()));
    }
  }

  Future<void> _onLoadComplaints(WasteLoadComplaints event, Emitter<WasteState> emit) async {
    emit(WasteLoading());
    try {
      final complaints = await _wasteService.getMyComplaints(status: event.status);
      emit(WasteComplaintsLoaded(complaints));
    } catch (e) {
      emit(WasteError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(WasteLoadCategories event, Emitter<WasteState> emit) async {
    try {
      final categories = await _wasteService.getWasteCategories();
      emit(WasteCategoriesLoaded(categories));
    } catch (e) {
      emit(WasteError(e.toString()));
    }
  }

  Future<void> _onUploadImage(WasteUploadImage event, Emitter<WasteState> emit) async {
    emit(WasteLoading());
    try {
      final imageUrl = await _wasteService.uploadImage(event.filePath);
      emit(WasteImageUploaded(imageUrl));
    } catch (e) {
      emit(WasteError(e.toString()));
    }
  }

  Future<void> _onTrackVehicle(WasteTrackVehicle event, Emitter<WasteState> emit) async {
    emit(WasteLoading());
    try {
      final trackingData = await _wasteService.trackWasteVehicle(event.complaintId);
      emit(WasteTrackingLoaded(trackingData));
    } catch (e) {
      emit(WasteError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _wasteService.dispose();
    return super.close();
  }
}
