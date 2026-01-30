import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/request.dart';
import 'service_providers.dart';

part 'request_provider.g.dart';

/// Provider for request list state with filters
@riverpod
class RequestList extends _$RequestList {
  @override
  Future<List<Request>> build({
    String? requestType,
    String? status,
    String? requesterType,
    int? requesterId,
  }) async {
    final requestService = ref.watch(requestServiceProvider);
    return requestService.getRequests(
      requestType: requestType,
      status: status,
      requesterType: requesterType,
      requesterId: requesterId,
    );
  }

  /// Refresh request list
  Future<void> refresh() async {
    final currentFilters = state.valueOrNull != null
        ? {
            'requestType': state.valueOrNull?.first.requestType,
            'status': state.valueOrNull?.first.status,
            'requesterType': state.valueOrNull?.first.requesterType,
            'requesterId': state.valueOrNull?.first.requesterId,
          }
        : {};
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final requestService = ref.read(requestServiceProvider);
      return requestService.getRequests(
        requestType: currentFilters['requestType'] as String?,
        status: currentFilters['status'] as String?,
        requesterType: currentFilters['requesterType'] as String?,
        requesterId: currentFilters['requesterId'] as int?,
      );
    });
  }
}

/// Provider for request by ID
@riverpod
Future<Request> requestById(RequestByIdRef ref, int id) async {
  final requestService = ref.watch(requestServiceProvider);
  return requestService.getRequestById(id);
}

/// Provider for request statistics
@riverpod
Future<Map<String, dynamic>> requestStats(RequestStatsRef ref) async {
  final requestService = ref.watch(requestServiceProvider);
  return requestService.getRequestStats();
}

/// Provider for pending requests count (for badges)
@riverpod
Future<int> pendingRequestsCount(PendingRequestsCountRef ref) async {
  final requestService = ref.watch(requestServiceProvider);
  final requests = await requestService.getRequests(status: 'pending');
  return requests.length;
}

/// Provider for requests by type
@riverpod
Future<List<Request>> requestsByType(
  RequestsByTypeRef ref,
  String requestType, {
  String? status,
}) async {
  final requestService = ref.watch(requestServiceProvider);
  return requestService.getRequests(
    requestType: requestType,
    status: status,
  );
}
