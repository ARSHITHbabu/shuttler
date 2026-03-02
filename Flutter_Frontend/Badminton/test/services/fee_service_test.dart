import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:badminton/core/services/fee_service.dart';
import 'package:badminton/core/services/api_service.dart';
import 'package:badminton/models/fee.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late FeeService feeService;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    feeService = FeeService(mockApiService);
  });

  group('FeeService Tests', () {
    const fee1 = {
      'id': 1,
      'student_id': 1,
      'batch_id': 1,
      'amount': 1000.0,
      'total_paid': 500.0,
      'pending_amount': 500.0,
      'due_date': '2024-01-01',
      'status': 'pending',
      'created_at': '2024-01-01T00:00:00Z',
    };

    const fee2 = {
      'id': 2,
      'student_id': 2,
      'batch_id': 1,
      'amount': 1200.0,
      'total_paid': 1200.0,
      'pending_amount': 0.0,
      'due_date': '2024-01-01',
      'status': 'paid',
      'created_at': '2024-01-01T00:00:00Z',
    };

    test('getFees should return list of fees', () async {
      // Setup
      when(() => mockApiService.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [fee1, fee2],
                statusCode: 200,
              ));

      // Execute
      final result = await feeService.getFees();

      // Verify
      expect(result.length, 2);
      expect(result[0].status, 'pending');
      expect(result[1].status, 'paid');
    });

    test('getTotalPendingFees should sum pending amounts of pending and overdue fees', () async {
      // Setup
      const pendingFee = {
        'id': 1,
        'student_id': 1,
        'batch_id': 1,
        'amount': 1000.0,
        'total_paid': 200.0,
        'pending_amount': 800.0,
        'status': 'pending',
        'due_date': '2024-01-01',
      };
      
      const overdueFee = {
        'id': 2,
        'student_id': 2,
        'batch_id': 1,
        'amount': 1000.0,
        'total_paid': 0.0,
        'pending_amount': 1000.0,
        'status': 'overdue',
        'due_date': '2024-01-01',
      };

      // Mock first call for 'pending' fees
      when(() => mockApiService.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((Invocation invocation) async {
            final queryParams = invocation.namedArguments[#queryParameters];
            if (queryParams != null && queryParams['status'] == 'pending') {
              return Response(
                requestOptions: RequestOptions(path: ''),
                data: [pendingFee],
                statusCode: 200,
              );
            } else if (queryParams != null && queryParams['status'] == 'overdue') {
              return Response(
                requestOptions: RequestOptions(path: ''),
                data: [overdueFee],
                statusCode: 200,
              );
            }
            return Response(
              requestOptions: RequestOptions(path: ''),
              data: [],
              statusCode: 200,
            );
          });

      // Execute
      final result = await feeService.getTotalPendingFees();

      // Verify
      expect(result, 1800.0);
    });
  });
}
