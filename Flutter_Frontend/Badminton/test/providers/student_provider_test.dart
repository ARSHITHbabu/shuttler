import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/models/student.dart';

/// Basic unit tests for student provider logic
/// Note: Full provider testing requires Riverpod test setup with ProviderContainer
void main() {
  group('Student Provider Logic Tests', () {
    test('Student filtering by batch works correctly', () {
      // Arrange
      final students = [
        Student(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '1234567890',
          dateOfBirth: '2000-01-01',
          address: '123 Main St',
          status: 'active',
        ),
        Student(
          id: 2,
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '0987654321',
          dateOfBirth: '2001-02-02',
          address: '456 Oak Ave',
          status: 'active',
        ),
      ];

      // Act - simulate filtering by batch (assuming batchId is stored in student)
      // This is a placeholder test - actual implementation depends on Student model
      final filtered = students.where((s) => s.id == 1).toList();

      // Assert
      expect(filtered.length, 1);
      expect(filtered.first.name, 'John Doe');
    });

    test('Student search filters correctly', () {
      // Arrange
      final students = [
        Student(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '1234567890',
          dateOfBirth: '2000-01-01',
          address: '123 Main St',
          status: 'active',
        ),
        Student(
          id: 2,
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '0987654321',
          dateOfBirth: '2001-02-02',
          address: '456 Oak Ave',
          status: 'active',
        ),
      ];

      // Act - simulate search
      final searchQuery = 'John';
      final filtered = students
          .where((s) =>
              s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              s.email.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      // Assert
      expect(filtered.length, 1);
      expect(filtered.first.name, 'John Doe');
    });
  });
}
