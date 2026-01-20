// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coachByIdHash() => r'81cb73456fd9603af3e470e8fac9f62cbcf9347c';

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

/// Provider for coach by ID
///
/// Copied from [coachById].
@ProviderFor(coachById)
const coachByIdProvider = CoachByIdFamily();

/// Provider for coach by ID
///
/// Copied from [coachById].
class CoachByIdFamily extends Family<AsyncValue<Coach>> {
  /// Provider for coach by ID
  ///
  /// Copied from [coachById].
  const CoachByIdFamily();

  /// Provider for coach by ID
  ///
  /// Copied from [coachById].
  CoachByIdProvider call(int id) {
    return CoachByIdProvider(id);
  }

  @override
  CoachByIdProvider getProviderOverride(covariant CoachByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachByIdProvider';
}

/// Provider for coach by ID
///
/// Copied from [coachById].
class CoachByIdProvider extends AutoDisposeFutureProvider<Coach> {
  /// Provider for coach by ID
  ///
  /// Copied from [coachById].
  CoachByIdProvider(int id)
    : this._internal(
        (ref) => coachById(ref as CoachByIdRef, id),
        from: coachByIdProvider,
        name: r'coachByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachByIdHash,
        dependencies: CoachByIdFamily._dependencies,
        allTransitiveDependencies: CoachByIdFamily._allTransitiveDependencies,
        id: id,
      );

  CoachByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Coach> Function(CoachByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachByIdProvider._internal(
        (ref) => create(ref as CoachByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Coach> createElement() {
    return _CoachByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachByIdRef on AutoDisposeFutureProviderRef<Coach> {
  /// The parameter `id` of this provider.
  int get id;
}

class _CoachByIdProviderElement extends AutoDisposeFutureProviderElement<Coach>
    with CoachByIdRef {
  _CoachByIdProviderElement(super.provider);

  @override
  int get id => (origin as CoachByIdProvider).id;
}

String _$coachBatchesHash() => r'9f953ff151920903cae2405939780530f4b9a0ea';

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
String _$coachScheduleHash() => r'3b1d2d47b58bf60361aa77c704bf60b91d7e6841';

/// Provider for coach's all sessions (upcoming and past)
/// Gets schedules through coach's batches
///
/// Copied from [coachSchedule].
@ProviderFor(coachSchedule)
const coachScheduleProvider = CoachScheduleFamily();

/// Provider for coach's all sessions (upcoming and past)
/// Gets schedules through coach's batches
///
/// Copied from [coachSchedule].
class CoachScheduleFamily extends Family<AsyncValue<List<Schedule>>> {
  /// Provider for coach's all sessions (upcoming and past)
  /// Gets schedules through coach's batches
  ///
  /// Copied from [coachSchedule].
  const CoachScheduleFamily();

  /// Provider for coach's all sessions (upcoming and past)
  /// Gets schedules through coach's batches
  ///
  /// Copied from [coachSchedule].
  CoachScheduleProvider call(int coachId) {
    return CoachScheduleProvider(coachId);
  }

  @override
  CoachScheduleProvider getProviderOverride(
    covariant CoachScheduleProvider provider,
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
  String? get name => r'coachScheduleProvider';
}

/// Provider for coach's all sessions (upcoming and past)
/// Gets schedules through coach's batches
///
/// Copied from [coachSchedule].
class CoachScheduleProvider extends AutoDisposeFutureProvider<List<Schedule>> {
  /// Provider for coach's all sessions (upcoming and past)
  /// Gets schedules through coach's batches
  ///
  /// Copied from [coachSchedule].
  CoachScheduleProvider(int coachId)
    : this._internal(
        (ref) => coachSchedule(ref as CoachScheduleRef, coachId),
        from: coachScheduleProvider,
        name: r'coachScheduleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachScheduleHash,
        dependencies: CoachScheduleFamily._dependencies,
        allTransitiveDependencies:
            CoachScheduleFamily._allTransitiveDependencies,
        coachId: coachId,
      );

  CoachScheduleProvider._internal(
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
    FutureOr<List<Schedule>> Function(CoachScheduleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachScheduleProvider._internal(
        (ref) => create(ref as CoachScheduleRef),
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
    return _CoachScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachScheduleProvider && other.coachId == coachId;
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
mixin CoachScheduleRef on AutoDisposeFutureProviderRef<List<Schedule>> {
  /// The parameter `coachId` of this provider.
  int get coachId;
}

class _CoachScheduleProviderElement
    extends AutoDisposeFutureProviderElement<List<Schedule>>
    with CoachScheduleRef {
  _CoachScheduleProviderElement(super.provider);

  @override
  int get coachId => (origin as CoachScheduleProvider).coachId;
}

String _$coachListHash() => r'5451a14ed89475defccca77a2a7065a15583b4e7';

/// Provider for coach list state
///
/// Copied from [CoachList].
@ProviderFor(CoachList)
final coachListProvider =
    AutoDisposeAsyncNotifierProvider<CoachList, List<Coach>>.internal(
      CoachList.new,
      name: r'coachListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$coachListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CoachList = AutoDisposeAsyncNotifier<List<Coach>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
