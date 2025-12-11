import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_service.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminService _adminService = AdminService();

  AdminBloc() : super(AdminInitial()) {
    on<AdminLoadDashboardStats>(_onLoadDashboardStats);
    on<AdminLoadComplaints>(_onLoadComplaints);
    on<AdminAssignDriver>(_onAssignDriver);
    on<AdminLoadDrivers>(_onLoadDrivers);
    on<AdminApproveDriver>(_onApproveDriver);
    on<AdminLoadUsers>(_onLoadUsers);
  }

  Future<void> _onLoadDashboardStats(AdminLoadDashboardStats event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final stats = await _adminService.getDashboardStats();
      emit(AdminStatsLoaded(stats));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadComplaints(AdminLoadComplaints event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final complaints = await _adminService.getAllComplaints(
        status: event.status,
        category: event.category,
      );
      emit(AdminComplaintsLoaded(complaints));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onAssignDriver(AdminAssignDriver event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await _adminService.assignDriver(event.complaintId, event.driverId);
      emit(AdminDriverAssigned());
      add(AdminLoadComplaints());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadDrivers(AdminLoadDrivers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final drivers = await _adminService.getAllDrivers(status: event.status);
      emit(AdminDriversLoaded(drivers));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onApproveDriver(AdminApproveDriver event, Emitter<AdminState> emit) async {
    try {
      await _adminService.approveDriver(event.driverId);
      emit(AdminDriverApproved());
      add(AdminLoadDrivers());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadUsers(AdminLoadUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await _adminService.getAllUsers(searchQuery: event.searchQuery);
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _adminService.dispose();
    return super.close();
  }
}
