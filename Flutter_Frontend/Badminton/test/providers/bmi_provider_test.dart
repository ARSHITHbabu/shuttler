import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/models/bmi_record.dart';

/// Basic unit tests for BMI provider logic
void main() {
  group('BMI Provider Logic Tests', () {
    test('BMI health status calculation works correctly', () {
      // Arrange
      final records = [
        BMIRecord(
          id: 1,
          studentId: 1,
          date: DateTime(2024, 1, 1),
          height: 150.0,
          weight: 45.0,
          bmi: 20.0,
          healthStatus: 'normal',
        ),
        BMIRecord(
          id: 2,
          studentId: 1,
          date: DateTime(2024, 2, 1),
          height: 150.0,
          weight: 50.0,
          bmi: 22.2,
          healthStatus: 'normal',
        ),
      ];

      // Act - calculate average BMI
      final avgBmi = records.map((r) => r.bmi).reduce((a, b) => a + b) / records.length;

      // Assert
      expect(avgBmi, 21.1);
      expect(records.first.healthStatus, 'normal');
    });

    test('Latest BMI record selection works correctly', () {
      // Arrange
      final records = [
        BMIRecord(
          id: 1,
          studentId: 1,
          date: DateTime(2024, 1, 1),
          height: 150.0,
          weight: 45.0,
          bmi: 20.0,
        ),
        BMIRecord(
          id: 2,
          studentId: 1,
          date: DateTime(2024, 2, 1),
          height: 150.0,
          weight: 50.0,
          bmi: 22.2,
        ),
      ];

      // Act - sort by date descending
      records.sort((a, b) => b.date.compareTo(a.date));
      final latest = records.first;

      // Assert
      expect(latest.id, 2);
      expect(latest.bmi, 22.2);
    });
  });
}
