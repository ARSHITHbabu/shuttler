import 'dart:io';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/leave_request.dart';
import 'service_providers.dart';
import 'calendar_provider.dart';

part 'leave_request_provider.g.dart';

/// Provider for all leave requests (owner view - all requests)
@riverpod
Future<List<LeaveRequest>> allLeaveRequests(AllLeaveRequestsRef ref, {String? status}) async {
  final leaveRequestService = ref.watch(leaveRequestServiceProvider);
  return leaveRequestService.getLeaveRequests(status: status);
}

/// Provider for leave requests by coach ID (coach view - their own requests)
@riverpod
Future<List<LeaveRequest>> coachLeaveRequests(
  CoachLeaveRequestsRef ref,
  int coachId, {
  String? status,
}) async {
  final leaveRequestService = ref.watch(leaveRequestServiceProvider);
  return leaveRequestService.getLeaveRequests(coachId: coachId, status: status);
}

/// Provider for pending leave requests (owner view)
@riverpod
Future<List<LeaveRequest>> pendingLeaveRequests(PendingLeaveRequestsRef ref) async {
  final leaveRequestService = ref.watch(leaveRequestServiceProvider);
  return leaveRequestService.getLeaveRequests(status: 'pending');
}

/// Provider for leave request by ID
@riverpod
Future<LeaveRequest> leaveRequestById(LeaveRequestByIdRef ref, int id) async {
  final leaveRequestService = ref.watch(leaveRequestServiceProvider);
  return leaveRequestService.getLeaveRequestById(id);
}

/// Provider for leave request management (CRUD operations)
@riverpod
class LeaveRequestManager extends _$LeaveRequestManager {
  @override
  Future<List<LeaveRequest>> build({int? coachId, String? status}) async {
    final leaveRequestService = ref.watch(leaveRequestServiceProvider);
    return await leaveRequestService.getLeaveRequests(coachId: coachId, status: status);
  }

  /// Refresh leave requests
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final leaveRequestService = ref.read(leaveRequestServiceProvider);
      // Rebuild with same parameters - we'll need to get them from the provider key
      // For now, just call getLeaveRequests without filters (will get all)
      return leaveRequestService.getLeaveRequests();
    });
  }

  /// Create a new leave request
  Future<void> createLeaveRequest({
    required int coachId,
    required String coachName,
    required DateTime startDate,
    required DateTime endDate,
    required String leaveType,
    required String reason,
  }) async {
    try {
      final leaveRequestService = ref.read(leaveRequestServiceProvider);
      await leaveRequestService.createLeaveRequest(
        coachId: coachId,
        coachName: coachName,
        startDate: startDate,
        endDate: endDate,
        leaveType: leaveType,
        reason: reason,
      );
      await refresh();
    } catch (e) {
      throw Exception('Failed to create leave request: $e');
    }
  }

  /// Update leave request status (approve/reject)
  Future<void> updateLeaveRequestStatus({
    required int requestId,
    required int ownerId,
    required String status, // "approved" or "rejected"
    String? reviewNotes,
  }) async {
    try {
      final leaveRequestService = ref.read(leaveRequestServiceProvider);
      await leaveRequestService.updateLeaveRequest(
        requestId: requestId,
        ownerId: ownerId,
        status: status,
        reviewNotes: reviewNotes,
      );
      
      // Invalidate calendar providers on approval/rejection as it affects leave events
      if (status == 'approved' || status == 'rejected') {
        try {
          final request = await leaveRequestService.getLeaveRequestById(requestId);
          final startDate = request.startDate;
          ref.invalidate(yearlyEventsProvider(startDate.year));
        } catch (_) {}
      }
      
      await refresh();
    } catch (e) {
      throw Exception('Failed to update leave request: $e');
    }
  }

  /// Delete a leave request
  Future<void> deleteLeaveRequest({
    required int requestId,
    required int coachId,
  }) async {
    try {
      final leaveRequestService = ref.read(leaveRequestServiceProvider);
      await leaveRequestService.deleteLeaveRequest(
        requestId: requestId,
        coachId: coachId,
      );
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete leave request: $e');
    }
  }

  /// Patch a pending leave request (coaches only)
  Future<void> patchLeaveRequest({
    required int requestId,
    required int coachId,
    DateTime? startDate,
    DateTime? endDate,
    String? leaveType,
    String? reason,
  }) async {
    try {
      final leaveRequestService = ref.read(leaveRequestServiceProvider);
      await leaveRequestService.patchLeaveRequest(
        requestId: requestId,
        coachId: coachId,
        startDate: startDate,
        endDate: endDate,
        leaveType: leaveType,
        reason: reason,
      );
      await refresh();
    } catch (e) {
      throw Exception('Failed to edit leave request: $e');
    }
  }
}
