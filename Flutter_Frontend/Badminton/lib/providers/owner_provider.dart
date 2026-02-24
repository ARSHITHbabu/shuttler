import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/owner.dart';
import 'service_providers.dart';

part 'owner_provider.g.dart';

/// Provider for owner by ID
@riverpod
Future<Owner> ownerById(OwnerByIdRef ref, int id) async {
  final ownerService = ref.watch(ownerServiceProvider);
  return ownerService.getOwnerById(id);
}

/// Provider for owner list state
@riverpod
class OwnerList extends _$OwnerList {
  @override
  Future<List<Owner>> build() async {
    final ownerService = ref.watch(ownerServiceProvider);
    return ownerService.getOwners();
  }

  /// Refresh owner list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ownerService = ref.read(ownerServiceProvider);
      return ownerService.getOwners();
    });
  }

  /// Update an owner
  Future<void> updateOwner(int id, Map<String, dynamic> ownerData) async {
    try {
      final ownerService = ref.read(ownerServiceProvider);
      await ownerService.updateOwner(id, ownerData);
      await refresh();
    } catch (e) {
      throw Exception('Failed to update owner: $e');
    }
  }

  /// Delete an owner
  Future<void> deleteOwner(int id) async {
    try {
      final ownerService = ref.read(ownerServiceProvider);
      await ownerService.deleteOwner(id);
      await refresh();
    } catch (e) {
      throw Exception('Failed to delete owner: $e');
    }
  }
}

/// Provider for the active owner
@riverpod
Future<Owner?> activeOwner(ActiveOwnerRef ref) async {
  final ownerService = ref.watch(ownerServiceProvider);
  final owners = await ownerService.getOwners();
  if (owners.isNotEmpty) {
    return owners.first; // Return the first owner for now
  }
  return null;
}
