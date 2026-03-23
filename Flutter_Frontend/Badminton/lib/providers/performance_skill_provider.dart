import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'service_providers.dart';

part 'performance_skill_provider.g.dart';

class PerformanceSkill {
  final int id;
  final String name;
  final bool isActive;

  PerformanceSkill({required this.id, required this.name, required this.isActive});

  factory PerformanceSkill.fromJson(Map<String, dynamic> json) {
    return PerformanceSkill(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
    );
  }
}

@riverpod
class PerformanceSkillList extends _$PerformanceSkillList {
  @override
  Future<List<PerformanceSkill>> build() async {
    return _fetchSkills();
  }

  Future<List<PerformanceSkill>> _fetchSkills() async {
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.get('/api/performance-skills?active_only=true');
    final List<dynamic> data = response.data;
    return data.map((json) => PerformanceSkill.fromJson(json)).toList();
  }

  Future<void> addSkill(String name) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/api/performance-skills', data: {'name': name});
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSkills());
  }

  Future<void> updateSkill(int id, String name) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.patch('/api/performance-skills/$id', data: {'name': name});
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSkills());
  }

  Future<void> deleteSkill(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/api/performance-skills/$id');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSkills());
  }
}
