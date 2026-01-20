import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/session.dart';
import 'service_providers.dart';

part 'session_provider.g.dart';

/// Provider for all sessions, optionally filtered by status
@riverpod
Future<List<Session>> sessionList(
  SessionListRef ref, {
  String? status,
}) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSessions(status: status);
}

/// Provider for active sessions only
@riverpod
Future<List<Session>> activeSessions(ActiveSessionsRef ref) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSessions(status: 'active');
}

/// Provider for archived sessions only
@riverpod
Future<List<Session>> archivedSessions(ArchivedSessionsRef ref) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSessions(status: 'archived');
}

/// Provider for session by ID
@riverpod
Future<Session> sessionById(SessionByIdRef ref, int id) async {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSessionById(id);
}

/// Provider class for session CRUD operations
@riverpod
class SessionManager extends _$SessionManager {
  @override
  Future<List<Session>> build({String? status}) async {
    final sessionService = ref.watch(sessionServiceProvider);
    return sessionService.getSessions(status: status);
  }

  /// Create a new session
  Future<Session> createSession(Map<String, dynamic> sessionData) async {
    final sessionService = ref.read(sessionServiceProvider);
    final newSession = await sessionService.createSession(sessionData);
    // Refresh the list - invalidate current state and related providers
    ref.invalidateSelf();
    // Invalidate all session list providers
    ref.invalidate(sessionListProvider(status: null));
    ref.invalidate(sessionListProvider(status: 'active'));
    ref.invalidate(sessionListProvider(status: 'archived'));
    ref.invalidate(activeSessionsProvider);
    ref.invalidate(archivedSessionsProvider);
    return newSession;
  }

  /// Update a session
  Future<Session> updateSession(int id, Map<String, dynamic> sessionData) async {
    final sessionService = ref.read(sessionServiceProvider);
    final updatedSession = await sessionService.updateSession(id, sessionData);
    // Refresh the list - invalidate current state and related providers
    ref.invalidateSelf();
    // Invalidate all session list providers
    ref.invalidate(sessionListProvider(status: null));
    ref.invalidate(sessionListProvider(status: 'active'));
    ref.invalidate(sessionListProvider(status: 'archived'));
    ref.invalidate(activeSessionsProvider);
    ref.invalidate(archivedSessionsProvider);
    ref.invalidate(sessionByIdProvider(id));
    return updatedSession;
  }

  /// Delete a session
  Future<void> deleteSession(int id) async {
    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.deleteSession(id);
    // Refresh the list - invalidate current state and related providers
    ref.invalidateSelf();
    // Invalidate all session list providers
    ref.invalidate(sessionListProvider(status: null));
    ref.invalidate(sessionListProvider(status: 'active'));
    ref.invalidate(sessionListProvider(status: 'archived'));
    ref.invalidate(activeSessionsProvider);
    ref.invalidate(archivedSessionsProvider);
  }
}
