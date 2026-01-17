import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for checking network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityService() {
    _connectivityController = StreamController<bool>.broadcast();
  }

  /// Get current connectivity status
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _hasConnection(result);
    } catch (e) {
      // If check fails, assume no connection
      return false;
    }
  }

  /// Check if connectivity result indicates connection
  bool _hasConnection(ConnectivityResult result) {
    // If result is not 'none', we have a connection
    return result != ConnectivityResult.none;
  }

  /// Stream of connectivity status changes
  Stream<bool> get onConnectivityChanged {
    if (_subscription == null) {
      _subscription = _connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) {
          final isConnected = _hasConnection(result);
          _connectivityController?.add(isConnected);
        },
        onError: (error) {
          _connectivityController?.addError(error);
        },
      );
    }
    return _connectivityController!.stream;
  }

  /// Get connectivity result details
  Future<ConnectivityResult> getConnectivityResults() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Check if connected via WiFi
  Future<bool> isConnectedViaWifi() async {
    final result = await getConnectivityResults();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected via mobile data
  Future<bool> isConnectedViaMobile() async {
    final result = await getConnectivityResults();
    return result == ConnectivityResult.mobile;
  }

  /// Check if connected via ethernet
  Future<bool> isConnectedViaEthernet() async {
    final result = await getConnectivityResults();
    return result == ConnectivityResult.ethernet;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
    _subscription = null;
    _connectivityController = null;
  }
}
