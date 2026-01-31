import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student_registration_request.dart';
import 'service_providers.dart';

part 'student_registration_request_provider.g.dart';

/// Provider for all student registration requests (owner view)
@riverpod
Future<List<StudentRegistrationRequest>> studentRegistrationRequestManager(
  StudentRegistrationRequestManagerRef ref, {
  String? status,
}) async {
  final service = ref.watch(studentRegistrationRequestServiceProvider);
  return service.getRequests(status: status);
}

/// Provider for student registration request by ID
@riverpod
Future<StudentRegistrationRequest> studentRegistrationRequestById(
  StudentRegistrationRequestByIdRef ref,
  int id,
) async {
  final service = ref.watch(studentRegistrationRequestServiceProvider);
  return service.getRequest(id);
}
