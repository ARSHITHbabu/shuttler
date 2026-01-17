import 'dart:async';
import 'package:dio/dio.dart';
import 'connectivity_service.dart';

/// Priority levels for queued requests
enum RequestPriority {
  low,
  normal,
  high,
  critical,
}

/// Queued request data
class QueuedRequest {
  final String method;
  final String path;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final Options? options;
  final RequestPriority priority;
  final Completer<Response> completer;
  final DateTime queuedAt;
  int retryCount;

  QueuedRequest({
    required this.method,
    required this.path,
    this.data,
    this.queryParameters,
    this.options,
    this.priority = RequestPriority.normal,
    required this.completer,
    DateTime? queuedAt,
    this.retryCount = 0,
  }) : queuedAt = queuedAt ?? DateTime.now();
}

/// Service for queuing requests when offline and retrying when online
class RequestQueue {
  final ConnectivityService _connectivityService;
  final Dio _dio;
  final List<QueuedRequest> _queue = [];
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isProcessing = false;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  RequestQueue({
    required ConnectivityService connectivityService,
    required Dio dio,
  })  : _connectivityService = connectivityService,
        _dio = dio {
    _listenToConnectivity();
  }

  /// Listen to connectivity changes and process queue when online
  void _listenToConnectivity() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected && _queue.isNotEmpty) {
          _processQueue();
        }
      },
    );
  }

  /// Add request to queue
  Future<Response> queueRequest({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    final completer = Completer<Response>();
    final request = QueuedRequest(
      method: method,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      priority: priority,
      completer: completer,
    );

    // Check if online first
    final isConnected = await _connectivityService.isConnected();
    if (isConnected) {
      // Try to execute immediately
      try {
        final response = await _executeRequest(request);
        return response;
      } catch (e) {
        // If execution fails, add to queue
        _addToQueue(request);
      }
    } else {
      // Offline - add to queue
      _addToQueue(request);
    }

    return completer.future;
  }

  /// Add request to queue with priority ordering
  void _addToQueue(QueuedRequest request) {
    _queue.add(request);
    // Sort by priority (critical first, then high, normal, low)
    _queue.sort((a, b) {
      final priorityOrder = {
        RequestPriority.critical: 0,
        RequestPriority.high: 1,
        RequestPriority.normal: 2,
        RequestPriority.low: 3,
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });
  }

  /// Process queued requests when online
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        _isProcessing = false;
        return;
      }

      final request = _queue.removeAt(0);

      try {
        final response = await _executeRequest(request);
        if (!request.completer.isCompleted) {
          request.completer.complete(response);
        }
      } catch (e) {
        // Retry if retry count is less than max
        if (request.retryCount < maxRetries) {
          request.retryCount++;
          await Future.delayed(retryDelay);
          _addToQueue(request);
        } else {
          // Max retries reached - complete with error
          if (!request.completer.isCompleted) {
            request.completer.completeError(e);
          }
        }
      }
    }

    _isProcessing = false;
  }

  /// Execute a request
  Future<Response> _executeRequest(QueuedRequest request) async {
    switch (request.method.toUpperCase()) {
      case 'GET':
        return await _dio.get(
          request.path,
          queryParameters: request.queryParameters,
          options: request.options,
        );
      case 'POST':
        return await _dio.post(
          request.path,
          data: request.data,
          queryParameters: request.queryParameters,
          options: request.options,
        );
      case 'PUT':
        return await _dio.put(
          request.path,
          data: request.data,
          queryParameters: request.queryParameters,
          options: request.options,
        );
      case 'DELETE':
        return await _dio.delete(
          request.path,
          data: request.data,
          queryParameters: request.queryParameters,
          options: request.options,
        );
      case 'PATCH':
        return await _dio.patch(
          request.path,
          data: request.data,
          queryParameters: request.queryParameters,
          options: request.options,
        );
      default:
        throw UnsupportedError('Unsupported HTTP method: ${request.method}');
    }
  }

  /// Get queue size
  int get queueSize => _queue.length;

  /// Clear queue
  void clearQueue() {
    for (final request in _queue) {
      if (!request.completer.isCompleted) {
        request.completer.completeError(
          Exception('Request queue cleared'),
        );
      }
    }
    _queue.clear();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    clearQueue();
  }
}
