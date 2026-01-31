import 'dart:io';
import 'dart:convert';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/leave_request.dart';

/// Service for leave request-related API operations
class LeaveRequestService {
  final ApiService _apiService;

  LeaveRequestService(this._apiService);

  /// Get all leave requests
  /// For owners: returns all requests
  /// For coaches: pass coachId to get only their requests
  Future<List<LeaveRequest>> getLeaveRequests({
    int? coachId,
    String? status,
  }) async {
    // #region agent log
    try {
      final logData = {
        "location": "leave_request_service.dart:14",
        "message": "getLeaveRequests called",
        "data": {"coachId": coachId, "status": status, "endpoint": ApiEndpoints.leaveRequests},
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "sessionId": "debug-session",
        "runId": "run1",
        "hypothesisId": "D"
      };
      final logFile = File(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log");
      await logFile.writeAsString("${jsonEncode(logData)}\n", mode: FileMode.append);
    } catch (_) {}
    // #endregion
    try {
      final queryParams = <String, String>{};
      if (coachId != null) {
        queryParams['coach_id'] = coachId.toString();
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      // #region agent log
      try {
        final logData2 = {
          "location": "leave_request_service.dart:27",
          "message": "Making API call",
          "data": {"url": ApiEndpoints.leaveRequests, "queryParams": queryParams},
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "D"
        };
        final logFile = File(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log");
        await logFile.writeAsString("${jsonEncode(logData2)}\n", mode: FileMode.append);
      } catch (_) {}
      // #endregion

      final response = await _apiService.get(
        ApiEndpoints.leaveRequests,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // #region agent log
      try {
        final logData3 = {
          "location": "leave_request_service.dart:32",
          "message": "API response received",
          "data": {"statusCode": response.statusCode, "dataType": response.data.runtimeType.toString(), "dataLength": response.data is List ? (response.data as List).length : "not_list"},
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "E"
        };
        final logFile = File(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log");
        await logFile.writeAsString("${jsonEncode(logData3)}\n", mode: FileMode.append);
      } catch (_) {}
      // #endregion

      if (response.data is List) {
        final result = (response.data as List)
            .map((json) => LeaveRequest.fromJson(json as Map<String, dynamic>))
            .toList();
        // #region agent log
        try {
          final logData4 = {
            "location": "leave_request_service.dart:36",
            "message": "Parsed leave requests",
            "data": {"count": result.length, "ids": result.map((r) => r.id).toList()},
            "timestamp": DateTime.now().millisecondsSinceEpoch,
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "E"
          };
          final logFile = File(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log");
          await logFile.writeAsString("${jsonEncode(logData4)}\n", mode: FileMode.append);
        } catch (_) {}
        // #endregion
        return result;
      }
      // #region agent log
      try {
        final logData5 = {
          "location": "leave_request_service.dart:37",
          "message": "Response data is not a List, returning empty",
          "data": {"dataType": response.data.runtimeType.toString()},
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "E"
        };
        final logFile = File(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log");
        await logFile.writeAsString("${jsonEncode(logData5)}\n", mode: FileMode.append);
      } catch (_) {}
      // #endregion
      return [];
    } catch (e) {
      // #region agent log
      try {
        final logData6 = {
          "location": "leave_request_service.dart:40",
          "message": "Error in getLeaveRequests",
          "data": {"error": e.toString(), "errorType": e.runtimeType.toString()},
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "sessionId": "debug-session",
          "runId": "run1",
          "hypothesisId": "C"
        };
        final logFile = File(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log");
        await logFile.writeAsString("${jsonEncode(logData6)}\n", mode: FileMode.append);
      } catch (_) {}
      // #endregion
      throw Exception(
          'Failed to fetch leave requests: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get a specific leave request by ID
  Future<LeaveRequest> getLeaveRequestById(int id) async {
    try {
      final response =
          await _apiService.get(ApiEndpoints.leaveRequestById(id));
      return LeaveRequest.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(
          'Failed to fetch leave request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Create a new leave request (coaches only)
  Future<LeaveRequest> createLeaveRequest({
    required int coachId,
    required String coachName,
    required DateTime startDate,
    required DateTime endDate,
    required String leaveType,
    required String reason,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.leaveRequests,
        data: {
          'coach_id': coachId,
          'coach_name': coachName,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'leave_type': leaveType,
          'reason': reason,
        },
      );
      return LeaveRequest.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(
          'Failed to create leave request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Update leave request status (owners only - approve/reject)
  Future<LeaveRequest> updateLeaveRequest({
    required int requestId,
    required int ownerId,
    required String status, // "approved" or "rejected"
    String? reviewNotes,
  }) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.leaveRequestById(requestId),
        queryParameters: {'owner_id': ownerId.toString()},
        data: {
          'status': status,
          'review_notes': reviewNotes,
        },
      );
      return LeaveRequest.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception(
          'Failed to update leave request: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Delete a leave request (coaches only - if pending)
  Future<void> deleteLeaveRequest({
    required int requestId,
    required int coachId,
  }) async {
    try {
      await _apiService.delete(
        ApiEndpoints.leaveRequestById(requestId),
        queryParameters: {'coach_id': coachId.toString()},
      );
    } catch (e) {
      throw Exception(
          'Failed to delete leave request: ${_apiService.getErrorMessage(e)}');
    }
  }
}
