import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

/// Provider for pending invitations (waiting for registration)
final pendingInvitationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(invitationServiceProvider);
  return service.getPendingInvitations();
});
