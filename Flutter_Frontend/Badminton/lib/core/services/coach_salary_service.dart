import 'api_service.dart';
import '../../models/coach_salary.dart';

class CoachSalaryService {
  final ApiService _apiService;

  CoachSalaryService(this._apiService);

  Future<List<CoachSalary>> getCoachSalaries({String? month, int? coachId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (coachId != null) queryParams['coach_id'] = coachId;

      final response = await _apiService.get(
        '/coach-salaries/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => CoachSalary.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load coach salaries: ${_apiService.getErrorMessage(e)}');
    }
  }

  Future<CoachSalary> createCoachSalary(Map<String, dynamic> salaryData) async {
    try {
      final response = await _apiService.post(
        '/coach-salaries/',
        data: salaryData,
      );
      return CoachSalary.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create coach salary: ${_apiService.getErrorMessage(e)}');
    }
  }

  Future<CoachSalary> updateCoachSalary(int id, Map<String, dynamic> salaryData) async {
    try {
      final response = await _apiService.put(
        '/coach-salaries/$id',
        data: salaryData,
      );
      return CoachSalary.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update coach salary: ${_apiService.getErrorMessage(e)}');
    }
  }

  Future<void> deleteCoachSalary(int id) async {
    try {
      await _apiService.delete('/coach-salaries/$id');
    } catch (e) {
      throw Exception('Failed to delete coach salary: ${_apiService.getErrorMessage(e)}');
    }
  }
}
