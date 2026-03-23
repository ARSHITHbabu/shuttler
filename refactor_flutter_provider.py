import os
import re

def update_flutter_provider():
    file_path = "Flutter_Frontend/Badminton/lib/providers/performance_provider.dart"
    with open(file_path, "r") as f:
        content = f.read()

    # Update trend mapping
    trend_replacement = """  // Convert to trend data format for charts
  return records.map((record) {
    final Map<String, dynamic> data = {
      'date': record.date,
      'average': record.averageRating,
    };
    // Include individual skill ratings
    record.skills.forEach((key, value) {
      data[key] = value;
    });
    return data;
  }).toList();"""
    
    pattern_trend = re.compile(r"  // Convert to trend data format for charts.*?  }\)\.toList\(\);", re.DOTALL)
    content = pattern_trend.sub(trend_replacement, content)

    # Update averagePerformance
    avg_replacement = """  if (records.isEmpty) {
    return {
      'average': 0.0,
      'skills': <String, double>{},
      'totalRecords': 0,
    };
  }
  
  Map<String, double> skillSums = {};
  Map<String, int> skillCounts = {};
  
  for (var record in records) {
    record.skills.forEach((skill, rating) {
      skillSums[skill] = (skillSums[skill] ?? 0.0) + rating;
      skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
    });
  }
  
  Map<String, double> skillAverages = {};
  skillSums.forEach((skill, sum) {
    skillAverages[skill] = sum / skillCounts[skill]!;
  });
  
  final overallAvg = records.map((r) => r.averageRating).reduce((a, b) => a + b) / records.length;
  
  return {
    'average': overallAvg,
    'skills': skillAverages,
    'totalRecords': records.length,
  };"""
  
    pattern_avg = re.compile(r"  if \(records\.isEmpty\) \{.*?  \};", re.DOTALL)
    content = pattern_avg.sub(avg_replacement, content)
    
    with open(file_path, "w") as f:
        f.write(content)

if __name__ == "__main__":
    update_flutter_provider()
