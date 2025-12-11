import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/driver_service.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverService _driverService = DriverService();
  bool _isOnline = false;

  DriverBloc() : super(DriverInitial()) {
    on<DriverLoadJobs>(_onLoadJobs);
    on<DriverAcceptJob>(_onAcceptJob);
    on<DriverStartJob>(_onStartJob);
    on<DriverCompleteJob>(_onCompleteJob);
    on<DriverToggleOnlineStatus>(_onToggleOnlineStatus);
    on<DriverLoadEarnings>(_onLoadEarnings);
    on<DriverUpdateLocation>(_onUpdateLocation);
  }

  Future<void> _onLoadJobs(DriverLoadJobs event, Emitter<DriverState> emit) async {
    emit(DriverLoading());
    try {
      final jobs = await _driverService.getAssignedJobs();
      emit(DriverJobsLoaded(jobs, isOnline: _isOnline));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onAcceptJob(DriverAcceptJob event, Emitter<DriverState> emit) async {
    emit(DriverLoading());
    try {
      await _driverService.acceptJob(event.jobId);
      emit(DriverJobAccepted());
      add(DriverLoadJobs());
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onStartJob(DriverStartJob event, Emitter<DriverState> emit) async {
    emit(DriverLoading());
    try {
      await _driverService.startJob(event.jobId);
      add(DriverLoadJobs());
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onCompleteJob(DriverCompleteJob event, Emitter<DriverState> emit) async {
    emit(DriverLoading());
    try {
      await _driverService.completeJob(event.jobId, event.proofImageUrl);
      emit(DriverJobCompleted());
      add(DriverLoadJobs());
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onToggleOnlineStatus(DriverToggleOnlineStatus event, Emitter<DriverState> emit) async {
    try {
      _isOnline = !_isOnline;
      await _driverService.toggleOnlineStatus(_isOnline);
      emit(DriverOnlineStatusChanged(_isOnline));
    } catch (e) {
      _isOnline = !_isOnline;
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onLoadEarnings(DriverLoadEarnings event, Emitter<DriverState> emit) async {
    try {
      final earnings = await _driverService.getEarnings(period: event.period);
      emit(DriverEarningsLoaded(earnings));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onUpdateLocation(DriverUpdateLocation event, Emitter<DriverState> emit) async {
    try {
      await _driverService.updateLocation(event.latitude, event.longitude);
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _driverService.dispose();
    return super.close();
  }
}
