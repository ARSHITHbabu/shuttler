import '../constants/api_endpoints.dart';
import 'api_service.dart';
import '../../models/tournament.dart';

/// Service for tournament API operations
class TournamentService {
  final ApiService _apiService;

  TournamentService(this._apiService);

  /// Get all tournaments
  Future<List<Tournament>> getTournaments() async {
    try {
      final response = await _apiService.get(ApiEndpoints.tournaments);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch tournaments: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get upcoming tournaments
  Future<List<Tournament>> getUpcomingTournaments() async {
    try {
      final response = await _apiService.get('${ApiEndpoints.tournaments}upcoming');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch upcoming tournaments: ${_apiService.getErrorMessage(e)}');
    }
  }

  /// Get tournament by ID
  Future<Tournament> getTournamentById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.tournamentById(id));
      return Tournament.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch tournament: ${_apiService.getErrorMessage(e)}');
    }
  }
}
