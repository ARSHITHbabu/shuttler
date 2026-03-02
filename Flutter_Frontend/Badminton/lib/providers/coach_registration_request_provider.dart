import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/coach_registration_request.dart';
import 'service_providers.dart';

part 'coach_registration_request_provider.g.dart';

/// Provider for all coach registration requests (owner view)
@riverpod
Future<List<CoachRegistrationRequest>> coachRegistrationRequestManager(
  CoachRegistrationRequestManagerRef ref, {
  String? status,
}) async {
  final service = ref.watch(coachRegistrationRequestServiceProvider);
  return service.getRequests(status: status);
}

/// Provider for coach registration request by ID
@riverpod
Future<CoachRegistrationRequest> coachRegistrationRequestById(
  CoachRegistrationRequestByIdRef ref,
  int id,
) async {
  final service = ref.watch(coachRegistrationRequestServiceProvider);
  return service.getRequest(id);
}
