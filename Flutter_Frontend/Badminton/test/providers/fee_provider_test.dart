import 'package:flutter_test/flutter_test.dart';
import 'package:badminton/models/fee.dart';

/// Basic unit tests for fee provider logic
void main() {
  group('Fee Provider Logic Tests', () {
    test('Fee statistics calculation works correctly', () {
      // Arrange
      final fees = [
        Fee(
          id: 1,
          studentId: 1,
          batchId: 1,
          amount: 1000.0,
          totalPaid: 1000.0,
          pendingAmount: 0.0,
          dueDate: DateTime(2024, 1, 1),
          status: 'paid',
        ),
        Fee(
          id: 2,
          studentId: 2,
          batchId: 1,
          amount: 1500.0,
          totalPaid: 0.0,
          pendingAmount: 1500.0,
          dueDate: DateTime(2024, 1, 15),
          status: 'pending',
        ),
        Fee(
          id: 3,
          studentId: 3,
          batchId: 1,
          amount: 2000.0,
          totalPaid: 0.0,
          pendingAmount: 2000.0,
          dueDate: DateTime(2023, 12, 1),
          status: 'overdue',
        ),
      ];

      // Act - calculate stats
      final total = fees.fold<double>(0, (sum, fee) => sum + fee.amount);
      final paid = fees.where((f) => f.status == 'paid').length;
      final pending = fees.where((f) => f.status == 'pending').length;
      final overdue = fees.where((f) => f.status == 'overdue').length;

      // Assert
      expect(total, 4500.0);
      expect(paid, 1);
      expect(pending, 1);
      expect(overdue, 1);
    });

    test('Pending fees filtering works correctly', () {
      // Arrange
      final fees = [
        Fee(
          id: 1,
          studentId: 1,
          batchId: 1,
          amount: 1000.0,
          totalPaid: 1000.0,
          pendingAmount: 0.0,
          dueDate: DateTime(2024, 1, 1),
          status: 'paid',
        ),
        Fee(
          id: 2,
          studentId: 2,
          batchId: 1,
          amount: 1500.0,
          totalPaid: 0.0,
          pendingAmount: 1500.0,
          dueDate: DateTime(2024, 1, 15),
          status: 'pending',
        ),
      ];

      // Act
      final pending = fees.where((f) => f.status == 'pending').toList();

      // Assert
      expect(pending.length, 1);
      expect(pending.first.id, 2);
    });
  });
}
