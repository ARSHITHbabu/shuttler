// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coachBatchesHash() => r'9f953ff151920903cae2405939780530f4b9a0ea';

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

/// Provider for coach's assigned batches
///
/// Copied from [coachBatches].
@ProviderFor(coachBatches)
const coachBatchesProvider = CoachBatchesFamily();

/// Provider for coach's assigned batches
///
/// Copied from [coachBatches].
class CoachBatchesFamily extends Family<AsyncValue<List<Batch>>> {
  /// Provider for coach's assigned batches
  ///
  /// Copied from [coachBatches].
  const CoachBatchesFamily();

  /// Provider for coach's assigned batches
  ///
  /// Copied from [coachBatches].
  CoachBatchesProvider call(int coachId) {
    return CoachBatchesProvider(coachId);
  }

  @override
  CoachBatchesProvider getProviderOverride(
    covariant CoachBatchesProvider provider,
  ) {
    return call(provider.coachId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachBatchesProvider';
}

/// Provider for coach's assigned batches
///
/// Copied from [coachBatches].
class CoachBatchesProvider extends AutoDisposeFutureProvider<List<Batch>> {
  /// Provider for coach's assigned batches
  ///
  /// Copied from [coachBatches].
  CoachBatchesProvider(int coachId)
    : this._internal(
        (ref) => coachBatches(ref as CoachBatchesRef, coachId),
        from: coachBatchesProvider,
        name: r'coachBatchesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachBatchesHash,
        dependencies: CoachBatchesFamily._dependencies,
        allTransitiveDependencies:
            CoachBatchesFamily._allTransitiveDependencies,
        coachId: coachId,
      );

  CoachBatchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coachId,
  }) : super.internal();

  final int coachId;

  @override
  Override overrideWith(
    FutureOr<List<Batch>> Function(CoachBatchesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachBatchesProvider._internal(
        (ref) => create(ref as CoachBatchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coachId: coachId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Batch>> createElement() {
    return _CoachBatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachBatchesProvider && other.coachId == coachId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coachId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachBatchesRef on AutoDisposeFutureProviderRef<List<Batch>> {
  /// The parameter `coachId` of this provider.
  int get coachId;
}

class _CoachBatchesProviderElement
    extends AutoDisposeFutureProviderElement<List<Batch>>
    with CoachBatchesRef {
  _CoachBatchesProviderElement(super.provider);

  @override
  int get coachId => (origin as CoachBatchesProvider).coachId;
}

String _$coachStatsHash() => r'41b7ca2b69022a523ef440f1ead19288df48c333';

/// Provider for coach statistics
///
/// Copied from [coachStats].
@ProviderFor(coachStats)
const coachStatsProvider = CoachStatsFamily();

/// Provider for coach statistics
///
/// Copied from [coachStats].
class CoachStatsFamily extends Family<AsyncValue<CoachStats>> {
  /// Provider for coach statistics
  ///
  /// Copied from [coachStats].
  const CoachStatsFamily();

  /// Provider for coach statistics
  ///
  /// Copied from [coachStats].
  CoachStatsProvider call(int coachId) {
    return CoachStatsProvider(coachId);
  }

  @override
  CoachStatsProvider getProviderOverride(
    covariant CoachStatsProvider provider,
  ) {
    return call(provider.coachId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachStatsProvider';
}

/// Provider for coach statistics
///
/// Copied from [coachStats].
class CoachStatsProvider extends AutoDisposeFutureProvider<CoachStats> {
  /// Provider for coach statistics
  ///
  /// Copied from [coachStats].
  CoachStatsProvider(int coachId)
    : this._internal(
        (ref) => coachStats(ref as CoachStatsRef, coachId),
        from: coachStatsProvider,
        name: r'coachStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachStatsHash,
        dependencies: CoachStatsFamily._dependencies,
        allTransitiveDependencies: CoachStatsFamily._allTransitiveDependencies,
        coachId: coachId,
      );

  CoachStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coachId,
  }) : super.internal();

  final int coachId;

  @override
  Override overrideWith(
    FutureOr<CoachStats> Function(CoachStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachStatsProvider._internal(
        (ref) => create(ref as CoachStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coachId: coachId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CoachStats> createElement() {
    return _CoachStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachStatsProvider && other.coachId == coachId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coachId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachStatsRef on AutoDisposeFutureProviderRef<CoachStats> {
  /// The parameter `coachId` of this provider.
  int get coachId;
}

class _CoachStatsProviderElement
    extends AutoDisposeFutureProviderElement<CoachStats>
    with CoachStatsRef {
  _CoachStatsProviderElement(super.provider);

  @override
  int get coachId => (origin as CoachStatsProvider).coachId;
}

String _$coachTodaySessionsHash() =>
    r'41bd7668bb1d3d3291385760fc9a4dc6ebbe093c';

/// Provider for coach's today sessions
/// Since schedules don't have coach_id directly, we get schedules through batches
///
/// Copied from [coachTodaySessions].
@ProviderFor(coachTodaySessions)
const coachTodaySessionsProvider = CoachTodaySessionsFamily();

/// Provider for coach's today sessions
/// Since schedules don't have coach_id directly, we get schedules through batches
///
/// Copied from [coachTodaySessions].
class CoachTodaySessionsFamily extends Family<AsyncValue<List<Schedule>>> {
  /// Provider for coach's today sessions
  /// Since schedules don't have coach_id directly, we get schedules through batches
  ///
  /// Copied from [coachTodaySessions].
  const CoachTodaySessionsFamily();

  /// Provider for coach's today sessions
  /// Since schedules don't have coach_id directly, we get schedules through batches
  ///
  /// Copied from [coachTodaySessions].
  CoachTodaySessionsProvider call(int coachId) {
    return CoachTodaySessionsProvider(coachId);
  }

  @override
  CoachTodaySessionsProvider getProviderOverride(
    covariant CoachTodaySessionsProvider provider,
  ) {
    return call(provider.coachId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachTodaySessionsProvider';
}

/// Provider for coach's today sessions
/// Since schedules don't have coach_id directly, we get schedules through batches
///
/// Copied from [coachTodaySessions].
class CoachTodaySessionsProvider
    extends AutoDisposeFutureProvider<List<Schedule>> {
  /// Provider for coach's today sessions
  /// Since schedules don't have coach_id directly, we get schedules through batches
  ///
  /// Copied from [coachTodaySessions].
  CoachTodaySessionsProvider(int coachId)
    : this._internal(
        (ref) => coachTodaySessions(ref as CoachTodaySessionsRef, coachId),
        from: coachTodaySessionsProvider,
        name: r'coachTodaySessionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachTodaySessionsHash,
        dependencies: CoachTodaySessionsFamily._dependencies,
        allTransitiveDependencies:
            CoachTodaySessionsFamily._allTransitiveDependencies,
        coachId: coachId,
      );

  CoachTodaySessionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.coachId,
  }) : super.internal();

  final int coachId;

  @override
  Override overrideWith(
    FutureOr<List<Schedule>> Function(CoachTodaySessionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachTodaySessionsProvider._internal(
        (ref) => create(ref as CoachTodaySessionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        coachId: coachId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Schedule>> createElement() {
    return _CoachTodaySessionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachTodaySessionsProvider && other.coachId == coachId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, coachId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachTodaySessionsRef on AutoDisposeFutureProviderRef<List<Schedule>> {
  /// The parameter `coachId` of this provider.
  int get coachId;
}

class _CoachTodaySessionsProviderElement
    extends AutoDisposeFutureProviderElement<List<Schedule>>
    with CoachTodaySessionsRef {
  _CoachTodaySessionsProviderElement(super.provider);

  @override
  int get coachId => (origin as CoachTodaySessionsProvider).coachId;
}

String _$coachAnnouncementsHash() =>
    r'3cc2fbbaf9bf71a776b34dc3f7b4824273b279b4';

/// Provider for coach announcements (filtered for coaches)
///
/// Copied from [coachAnnouncements].
@ProviderFor(coachAnnouncements)
final coachAnnouncementsProvider =
    AutoDisposeFutureProvider<List<Announcement>>.internal(
      coachAnnouncements,
      name: r'coachAnnouncementsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$coachAnnouncementsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CoachAnnouncementsRef =
    AutoDisposeFutureProviderRef<List<Announcement>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
