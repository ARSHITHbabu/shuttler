import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';

part 'service_providers.g.dart';

/// Provider for StorageService singleton
@riverpod
StorageService storageService(StorageServiceRef ref) {
  final service = StorageService();
  // Note: init() must be called before use, but we can't do async in sync provider
  // The service will be initialized in main.dart
  return service;
}

/// Provider for ApiService singleton
@riverpod
ApiService apiService(ApiServiceRef ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService);
}

/// Provider for AuthService singleton
@riverpod
AuthService authService(AuthServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(apiService, storageService);
}
