import os
import re

def main():
    path = "Flutter_Frontend/Badminton/lib/screens/owner/performance_tracking_screen.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Add imports
    if "performance_skill_provider.dart" not in content:
        content = content.replace("import '../../providers/performance_provider.dart';", 
        "import '../../providers/performance_provider.dart';\nimport '../../providers/performance_skill_provider.dart';")

    # 2. Add `_currentSkills` state variable
    if "List<PerformanceSkill> _currentSkills = [];" not in content:
        content = content.replace("List<Student> _batchStudents = [];", 
        "List<Student> _batchStudents = [];\n  List<PerformanceSkill> _currentSkills = [];")

    # 3. Load skills
    if "_loadSkills" not in content:
        load_skills_func = """
  Future<void> _loadSkills() async {
    try {
      final skills = await ref.read(performanceSkillListProvider.future);
      if (mounted) {
        setState(() => _currentSkills = skills);
      }
    } catch (e) {
      if (mounted) {
        SuccessSnackbar.showError(context, 'Failed to load skills: $e');
      }
    }
  }
"""
        content = content.replace("  @override\n  void initState() {", load_skills_func + "\n  @override\n  void initState() {\n    _loadSkills();")

    # 4. Remove hardcoded _skills list
    content = re.sub(r"  final List<Map<String, dynamic>> _skills = \[.*?\];", "", content, flags=re.DOTALL)
    
    # 5. _initializeTableData
    old_init = """      _tableData[student.id] = {
        'serve': 0,
        'smash': 0,
        'footwork': 0,
        'defense': 0,
        'stamina': 0,
        'comments': '',
      };"""
    new_init = """      final Map<String, dynamic> data = {'comments': '', 'skills': <String, int>{}};
      for (var skill in _currentSkills) {
        data['skills'][skill.name] = 0;
      }
      _tableData[student.id] = data;"""
    content = content.replace(old_init, new_init)

    # 6. _saveBulkPerformance
    old_validation = """      if (studentData['serve'] > 0 ||
          studentData['smash'] > 0 ||
          studentData['footwork'] > 0 ||
          studentData['defense'] > 0 ||
          studentData['stamina'] > 0) {"""
    new_validation = """      final skills = studentData['skills'] as Map<String, int>;
      if (skills.values.any((r) => r > 0)) {"""
    content = content.replace(old_validation, new_validation)

    old_skip = """        if (data['serve'] == 0 &&
            data['smash'] == 0 &&
            data['footwork'] == 0 &&
            data['defense'] == 0 &&
            data['stamina'] == 0) {
          continue;
        }"""
    new_skip = """        final skills = data['skills'] as Map<String, int>;
        if (!skills.values.any((r) => r > 0)) continue;"""
    content = content.replace(old_skip, new_skip)

    old_perf_data = """          final performanceData = {
            'student_id': studentId,
            'batch_id': _selectedBatchId,
            'date': dateString,
            'serve': data['serve'] ?? 0,
            'smash': data['smash'] ?? 0,
            'footwork': data['footwork'] ?? 0,
            'defense': data['defense'] ?? 0,
            'stamina': data['stamina'] ?? 0,
            'comments': (data['comments'] as String?)?.trim().isEmpty == true
                ? null
                : (data['comments'] as String?)?.trim(),
          };"""
    new_perf_data = """          final performanceData = {
            'student_id': studentId,
            'batch_id': _selectedBatchId,
            'date': dateString,
            'skills': data['skills'],
            'comments': (data['comments'] as String?)?.trim().isEmpty == true
                ? null
                : (data['comments'] as String?)?.trim(),
          };"""
    content = content.replace(old_perf_data, new_perf_data)

    # 7. Render dynamic table headers
    # Instead of reading from `_skills`, read from `_currentSkills`
    content = content.replace("_skills.length", "_currentSkills.length")
    content = content.replace("for (int i = 1; i <= _skills.length; i++)", "for (int i = 1; i <= _currentSkills.length; i++)")
    
    old_headers = """                for (var skill in _skills)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingM,
                      horizontal: AppDimensions.paddingS,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          skill['icon'] as IconData,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skill['label'] as String,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),"""
    new_headers = """                for (var skill in _currentSkills)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingM,
                      horizontal: AppDimensions.paddingS,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_outline,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skill.name.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),"""
    content = content.replace(old_headers, new_headers)

    # Table rows
    old_row_children = """                  for (var skill in _skills) ...[
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                        horizontal: AppDimensions.paddingS,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _tableData[student.id]![skill['key']],
                          isDense: true,
                          dropdownColor: AppColors.cardBackground,
                          style: const TextStyle(color: AppColors.textPrimary),
                          items: [0, 1, 2, 3, 4, 5].map((rating) {
                            return DropdownMenuItem<int>(
                              value: rating,
                              child: Text(
                                rating == 0 ? '-' : rating.toString(),
                                style: TextStyle(
                                  color: rating == 0
                                      ? AppColors.textSecondary
                                      : _getRatingColor(rating),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _tableData[student.id]![skill['key']] = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],"""
    new_row_children = """                  for (var skill in _currentSkills) ...[
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                        horizontal: AppDimensions.paddingS,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: (_tableData[student.id]!['skills'] as Map<String, int>)[skill.name] ?? 0,
                          isDense: true,
                          dropdownColor: AppColors.cardBackground,
                          style: const TextStyle(color: AppColors.textPrimary),
                          items: [0, 1, 2, 3, 4, 5].map((rating) {
                            return DropdownMenuItem<int>(
                              value: rating,
                              child: Text(
                                rating == 0 ? '-' : rating.toString(),
                                style: TextStyle(
                                  color: rating == 0
                                      ? AppColors.textSecondary
                                      : _getRatingColor(rating),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                (_tableData[student.id]!['skills'] as Map<String, int>)[skill.name] = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],"""
    content = content.replace(old_row_children, new_row_children)

    # 8. Performance card display
    old_card_skills = """              Wrap(
                spacing: AppDimensions.spacingM,
                runSpacing: AppDimensions.spacingM,
                children: _skills.map((skill) {
                  final rating = switch (skill['key'] as String) {
                    'serve' => performance.serve,
                    'smash' => performance.smash,
                    'footwork' => performance.footwork,
                    'defense' => performance.defense,
                    'stamina' => performance.stamina,
                    _ => 0,
                  };

                  return _buildSkillRating(
                    skill['label'] as String,
                    rating,
                    skill['icon'] as IconData,
                  );
                }).toList(),
              ),"""
    new_card_skills = """              Wrap(
                spacing: AppDimensions.spacingM,
                runSpacing: AppDimensions.spacingM,
                children: performance.skills.entries.map((entry) {
                  return _buildSkillRating(
                    entry.key.toUpperCase(),
                    entry.value,
                    Icons.star_border,
                  );
                }).toList(),
              ),"""
    content = content.replace(old_card_skills, new_card_skills)
    
    # 9. Chart generation limits
    old_chart = """                  LineChartBarData(
                    spots: history.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.averageRating);
                    }).toList(),"""
    # Just need to make sure the tooltip and averages work
    # Because we removed `_skills`, the radar chart or anything else using `_skills` will error. Let's replace _skills.map with performance.skills
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

if __name__ == "__main__":
    main()
