// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$batchStudentsHash() => r'c11b4a9b97701552052d592b4488ca393f59ed38';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for batch students
///
/// Copied from [batchStudents].
@ProviderFor(batchStudents)
const batchStudentsProvider = BatchStudentsFamily();

/// Provider for batch students
///
/// Copied from [batchStudents].
class BatchStudentsFamily extends Family<AsyncValue<List<Student>>> {
  /// Provider for batch students
  ///
  /// Copied from [batchStudents].
  const BatchStudentsFamily();

  /// Provider for batch students
  ///
  /// Copied from [batchStudents].
  BatchStudentsProvider call(int batchId) {
    return BatchStudentsProvider(batchId);
  }

  @override
  BatchStudentsProvider getProviderOverride(
    covariant BatchStudentsProvider provider,
  ) {
    return call(provider.batchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'batchStudentsProvider';
}

/// Provider for batch students
///
/// Copied from [batchStudents].
class BatchStudentsProvider extends AutoDisposeFutureProvider<List<Student>> {
  /// Provider for batch students
  ///
  /// Copied from [batchStudents].
  BatchStudentsProvider(int batchId)
    : this._internal(
        (ref) => batchStudents(ref as BatchStudentsRef, batchId),
        from: batchStudentsProvider,
        name: r'batchStudentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$batchStudentsHash,
        dependencies: BatchStudentsFamily._dependencies,
        allTransitiveDependencies:
            BatchStudentsFamily._allTransitiveDependencies,
        batchId: batchId,
      );

  BatchStudentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.batchId,
  }) : super.internal();

  final int batchId;

  @override
  Override overrideWith(
    FutureOr<List<Student>> Function(BatchStudentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BatchStudentsProvider._internal(
        (ref) => create(ref as BatchStudentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        batchId: batchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Student>> createElement() {
    return _BatchStudentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BatchStudentsProvider && other.batchId == batchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, batchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BatchStudentsRef on AutoDisposeFutureProviderRef<List<Student>> {
  /// The parameter `batchId` of this provider.
  int get batchId;
}

class _BatchStudentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Student>>
    with BatchStudentsRef {
  _BatchStudentsProviderElement(super.provider);

  @override
  int get batchId => (origin as BatchStudentsProvider).batchId;
}

String _$batchListHash() => r'd1bbfc4ce2684feb4a5d425d64f341e6370ef394';

/// Provider for batch list state
///
/// Copied from [BatchList].
@ProviderFor(BatchList)
final batchListProvider =
    AutoDisposeAsyncNotifierProvider<BatchList, List<Batch>>.internal(
      BatchList.new,
      name: r'batchListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$batchListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BatchList = AutoDisposeAsyncNotifier<List<Batch>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
