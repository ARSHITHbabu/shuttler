import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/tournament.dart';
import 'service_providers.dart';

part 'tournament_provider.g.dart';

/// Provider for all tournaments
@riverpod
Future<List<Tournament>> tournamentList(TournamentListRef ref) async {
  final tournamentService = ref.watch(tournamentServiceProvider);
  return tournamentService.getTournaments();
}

/// Provider for upcoming tournaments
@riverpod
Future<List<Tournament>> upcomingTournaments(UpcomingTournamentsRef ref) async {
  final tournamentService = ref.watch(tournamentServiceProvider);
  return tournamentService.getUpcomingTournaments();
}

/// Provider for tournament by ID
@riverpod
Future<Tournament> tournamentById(TournamentByIdRef ref, int id) async {
  final tournamentService = ref.watch(tournamentServiceProvider);
  return tournamentService.getTournamentById(id);
}
