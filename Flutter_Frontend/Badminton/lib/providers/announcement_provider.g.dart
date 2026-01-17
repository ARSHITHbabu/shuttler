// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$announcementListHash() => r'6903efb596bfaac944ded2fb649896b8928dc8ac';

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

/// Provider for announcement list
///
/// Copied from [announcementList].
@ProviderFor(announcementList)
const announcementListProvider = AnnouncementListFamily();

/// Provider for announcement list
///
/// Copied from [announcementList].
class AnnouncementListFamily extends Family<AsyncValue<List<Announcement>>> {
  /// Provider for announcement list
  ///
  /// Copied from [announcementList].
  const AnnouncementListFamily();

  /// Provider for announcement list
  ///
  /// Copied from [announcementList].
  AnnouncementListProvider call({
    String? targetAudience,
    String? priority,
    bool? isSent,
  }) {
    return AnnouncementListProvider(
      targetAudience: targetAudience,
      priority: priority,
      isSent: isSent,
    );
  }

  @override
  AnnouncementListProvider getProviderOverride(
    covariant AnnouncementListProvider provider,
  ) {
    return call(
      targetAudience: provider.targetAudience,
      priority: provider.priority,
      isSent: provider.isSent,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'announcementListProvider';
}

/// Provider for announcement list
///
/// Copied from [announcementList].
class AnnouncementListProvider
    extends AutoDisposeFutureProvider<List<Announcement>> {
  /// Provider for announcement list
  ///
  /// Copied from [announcementList].
  AnnouncementListProvider({
    String? targetAudience,
    String? priority,
    bool? isSent,
  }) : this._internal(
         (ref) => announcementList(
           ref as AnnouncementListRef,
           targetAudience: targetAudience,
           priority: priority,
           isSent: isSent,
         ),
         from: announcementListProvider,
         name: r'announcementListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$announcementListHash,
         dependencies: AnnouncementListFamily._dependencies,
         allTransitiveDependencies:
             AnnouncementListFamily._allTransitiveDependencies,
         targetAudience: targetAudience,
         priority: priority,
         isSent: isSent,
       );

  AnnouncementListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.targetAudience,
    required this.priority,
    required this.isSent,
  }) : super.internal();

  final String? targetAudience;
  final String? priority;
  final bool? isSent;

  @override
  Override overrideWith(
    FutureOr<List<Announcement>> Function(AnnouncementListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnnouncementListProvider._internal(
        (ref) => create(ref as AnnouncementListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        targetAudience: targetAudience,
        priority: priority,
        isSent: isSent,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Announcement>> createElement() {
    return _AnnouncementListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementListProvider &&
        other.targetAudience == targetAudience &&
        other.priority == priority &&
        other.isSent == isSent;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, targetAudience.hashCode);
    hash = _SystemHash.combine(hash, priority.hashCode);
    hash = _SystemHash.combine(hash, isSent.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnnouncementListRef on AutoDisposeFutureProviderRef<List<Announcement>> {
  /// The parameter `targetAudience` of this provider.
  String? get targetAudience;

  /// The parameter `priority` of this provider.
  String? get priority;

  /// The parameter `isSent` of this provider.
  bool? get isSent;
}

class _AnnouncementListProviderElement
    extends AutoDisposeFutureProviderElement<List<Announcement>>
    with AnnouncementListRef {
  _AnnouncementListProviderElement(super.provider);

  @override
  String? get targetAudience =>
      (origin as AnnouncementListProvider).targetAudience;
  @override
  String? get priority => (origin as AnnouncementListProvider).priority;
  @override
  bool? get isSent => (origin as AnnouncementListProvider).isSent;
}

String _$announcementByIdHash() => r'd7a2e7c632ce223198c32125dfd059b6ece08bba';

/// Provider for announcement by ID
///
/// Copied from [announcementById].
@ProviderFor(announcementById)
const announcementByIdProvider = AnnouncementByIdFamily();

/// Provider for announcement by ID
///
/// Copied from [announcementById].
class AnnouncementByIdFamily extends Family<AsyncValue<Announcement>> {
  /// Provider for announcement by ID
  ///
  /// Copied from [announcementById].
  const AnnouncementByIdFamily();

  /// Provider for announcement by ID
  ///
  /// Copied from [announcementById].
  AnnouncementByIdProvider call(int id) {
    return AnnouncementByIdProvider(id);
  }

  @override
  AnnouncementByIdProvider getProviderOverride(
    covariant AnnouncementByIdProvider provider,
  ) {
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
  String? get name => r'announcementByIdProvider';
}

/// Provider for announcement by ID
///
/// Copied from [announcementById].
class AnnouncementByIdProvider extends AutoDisposeFutureProvider<Announcement> {
  /// Provider for announcement by ID
  ///
  /// Copied from [announcementById].
  AnnouncementByIdProvider(int id)
    : this._internal(
        (ref) => announcementById(ref as AnnouncementByIdRef, id),
        from: announcementByIdProvider,
        name: r'announcementByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$announcementByIdHash,
        dependencies: AnnouncementByIdFamily._dependencies,
        allTransitiveDependencies:
            AnnouncementByIdFamily._allTransitiveDependencies,
        id: id,
      );

  AnnouncementByIdProvider._internal(
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
    FutureOr<Announcement> Function(AnnouncementByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnnouncementByIdProvider._internal(
        (ref) => create(ref as AnnouncementByIdRef),
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
  AutoDisposeFutureProviderElement<Announcement> createElement() {
    return _AnnouncementByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementByIdProvider && other.id == id;
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
mixin AnnouncementByIdRef on AutoDisposeFutureProviderRef<Announcement> {
  /// The parameter `id` of this provider.
  int get id;
}

class _AnnouncementByIdProviderElement
    extends AutoDisposeFutureProviderElement<Announcement>
    with AnnouncementByIdRef {
  _AnnouncementByIdProviderElement(super.provider);

  @override
  int get id => (origin as AnnouncementByIdProvider).id;
}

String _$announcementByAudienceHash() =>
    r'6d8078e06720fb12773499314524654aadbb3797';

/// Provider for announcements by target audience
///
/// Copied from [announcementByAudience].
@ProviderFor(announcementByAudience)
const announcementByAudienceProvider = AnnouncementByAudienceFamily();

/// Provider for announcements by target audience
///
/// Copied from [announcementByAudience].
class AnnouncementByAudienceFamily
    extends Family<AsyncValue<List<Announcement>>> {
  /// Provider for announcements by target audience
  ///
  /// Copied from [announcementByAudience].
  const AnnouncementByAudienceFamily();

  /// Provider for announcements by target audience
  ///
  /// Copied from [announcementByAudience].
  AnnouncementByAudienceProvider call(String audience) {
    return AnnouncementByAudienceProvider(audience);
  }

  @override
  AnnouncementByAudienceProvider getProviderOverride(
    covariant AnnouncementByAudienceProvider provider,
  ) {
    return call(provider.audience);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'announcementByAudienceProvider';
}

/// Provider for announcements by target audience
///
/// Copied from [announcementByAudience].
class AnnouncementByAudienceProvider
    extends AutoDisposeFutureProvider<List<Announcement>> {
  /// Provider for announcements by target audience
  ///
  /// Copied from [announcementByAudience].
  AnnouncementByAudienceProvider(String audience)
    : this._internal(
        (ref) =>
            announcementByAudience(ref as AnnouncementByAudienceRef, audience),
        from: announcementByAudienceProvider,
        name: r'announcementByAudienceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$announcementByAudienceHash,
        dependencies: AnnouncementByAudienceFamily._dependencies,
        allTransitiveDependencies:
            AnnouncementByAudienceFamily._allTransitiveDependencies,
        audience: audience,
      );

  AnnouncementByAudienceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.audience,
  }) : super.internal();

  final String audience;

  @override
  Override overrideWith(
    FutureOr<List<Announcement>> Function(AnnouncementByAudienceRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnnouncementByAudienceProvider._internal(
        (ref) => create(ref as AnnouncementByAudienceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        audience: audience,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Announcement>> createElement() {
    return _AnnouncementByAudienceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementByAudienceProvider &&
        other.audience == audience;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, audience.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnnouncementByAudienceRef
    on AutoDisposeFutureProviderRef<List<Announcement>> {
  /// The parameter `audience` of this provider.
  String get audience;
}

class _AnnouncementByAudienceProviderElement
    extends AutoDisposeFutureProviderElement<List<Announcement>>
    with AnnouncementByAudienceRef {
  _AnnouncementByAudienceProviderElement(super.provider);

  @override
  String get audience => (origin as AnnouncementByAudienceProvider).audience;
}

String _$announcementByPriorityHash() =>
    r'12d2ddd9cfe21fdeef588c4b4f384304c7bb1e6b';

/// Provider for announcements by priority
///
/// Copied from [announcementByPriority].
@ProviderFor(announcementByPriority)
const announcementByPriorityProvider = AnnouncementByPriorityFamily();

/// Provider for announcements by priority
///
/// Copied from [announcementByPriority].
class AnnouncementByPriorityFamily
    extends Family<AsyncValue<List<Announcement>>> {
  /// Provider for announcements by priority
  ///
  /// Copied from [announcementByPriority].
  const AnnouncementByPriorityFamily();

  /// Provider for announcements by priority
  ///
  /// Copied from [announcementByPriority].
  AnnouncementByPriorityProvider call(String priority) {
    return AnnouncementByPriorityProvider(priority);
  }

  @override
  AnnouncementByPriorityProvider getProviderOverride(
    covariant AnnouncementByPriorityProvider provider,
  ) {
    return call(provider.priority);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'announcementByPriorityProvider';
}

/// Provider for announcements by priority
///
/// Copied from [announcementByPriority].
class AnnouncementByPriorityProvider
    extends AutoDisposeFutureProvider<List<Announcement>> {
  /// Provider for announcements by priority
  ///
  /// Copied from [announcementByPriority].
  AnnouncementByPriorityProvider(String priority)
    : this._internal(
        (ref) =>
            announcementByPriority(ref as AnnouncementByPriorityRef, priority),
        from: announcementByPriorityProvider,
        name: r'announcementByPriorityProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$announcementByPriorityHash,
        dependencies: AnnouncementByPriorityFamily._dependencies,
        allTransitiveDependencies:
            AnnouncementByPriorityFamily._allTransitiveDependencies,
        priority: priority,
      );

  AnnouncementByPriorityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.priority,
  }) : super.internal();

  final String priority;

  @override
  Override overrideWith(
    FutureOr<List<Announcement>> Function(AnnouncementByPriorityRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnnouncementByPriorityProvider._internal(
        (ref) => create(ref as AnnouncementByPriorityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        priority: priority,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Announcement>> createElement() {
    return _AnnouncementByPriorityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementByPriorityProvider &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, priority.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnnouncementByPriorityRef
    on AutoDisposeFutureProviderRef<List<Announcement>> {
  /// The parameter `priority` of this provider.
  String get priority;
}

class _AnnouncementByPriorityProviderElement
    extends AutoDisposeFutureProviderElement<List<Announcement>>
    with AnnouncementByPriorityRef {
  _AnnouncementByPriorityProviderElement(super.provider);

  @override
  String get priority => (origin as AnnouncementByPriorityProvider).priority;
}

String _$announcementManagerHash() =>
    r'c8d7ddd31d1e9add65a2926acd2029c175009df6';

abstract class _$AnnouncementManager
    extends BuildlessAutoDisposeAsyncNotifier<List<Announcement>> {
  late final String? targetAudience;
  late final String? priority;
  late final bool? isSent;

  FutureOr<List<Announcement>> build({
    String? targetAudience,
    String? priority,
    bool? isSent,
  });
}

/// Provider class for announcement CRUD operations
///
/// Copied from [AnnouncementManager].
@ProviderFor(AnnouncementManager)
const announcementManagerProvider = AnnouncementManagerFamily();

/// Provider class for announcement CRUD operations
///
/// Copied from [AnnouncementManager].
class AnnouncementManagerFamily extends Family<AsyncValue<List<Announcement>>> {
  /// Provider class for announcement CRUD operations
  ///
  /// Copied from [AnnouncementManager].
  const AnnouncementManagerFamily();

  /// Provider class for announcement CRUD operations
  ///
  /// Copied from [AnnouncementManager].
  AnnouncementManagerProvider call({
    String? targetAudience,
    String? priority,
    bool? isSent,
  }) {
    return AnnouncementManagerProvider(
      targetAudience: targetAudience,
      priority: priority,
      isSent: isSent,
    );
  }

  @override
  AnnouncementManagerProvider getProviderOverride(
    covariant AnnouncementManagerProvider provider,
  ) {
    return call(
      targetAudience: provider.targetAudience,
      priority: provider.priority,
      isSent: provider.isSent,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'announcementManagerProvider';
}

/// Provider class for announcement CRUD operations
///
/// Copied from [AnnouncementManager].
class AnnouncementManagerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AnnouncementManager,
          List<Announcement>
        > {
  /// Provider class for announcement CRUD operations
  ///
  /// Copied from [AnnouncementManager].
  AnnouncementManagerProvider({
    String? targetAudience,
    String? priority,
    bool? isSent,
  }) : this._internal(
         () => AnnouncementManager()
           ..targetAudience = targetAudience
           ..priority = priority
           ..isSent = isSent,
         from: announcementManagerProvider,
         name: r'announcementManagerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$announcementManagerHash,
         dependencies: AnnouncementManagerFamily._dependencies,
         allTransitiveDependencies:
             AnnouncementManagerFamily._allTransitiveDependencies,
         targetAudience: targetAudience,
         priority: priority,
         isSent: isSent,
       );

  AnnouncementManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.targetAudience,
    required this.priority,
    required this.isSent,
  }) : super.internal();

  final String? targetAudience;
  final String? priority;
  final bool? isSent;

  @override
  FutureOr<List<Announcement>> runNotifierBuild(
    covariant AnnouncementManager notifier,
  ) {
    return notifier.build(
      targetAudience: targetAudience,
      priority: priority,
      isSent: isSent,
    );
  }

  @override
  Override overrideWith(AnnouncementManager Function() create) {
    return ProviderOverride(
      origin: this,
      override: AnnouncementManagerProvider._internal(
        () => create()
          ..targetAudience = targetAudience
          ..priority = priority
          ..isSent = isSent,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        targetAudience: targetAudience,
        priority: priority,
        isSent: isSent,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    AnnouncementManager,
    List<Announcement>
  >
  createElement() {
    return _AnnouncementManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementManagerProvider &&
        other.targetAudience == targetAudience &&
        other.priority == priority &&
        other.isSent == isSent;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, targetAudience.hashCode);
    hash = _SystemHash.combine(hash, priority.hashCode);
    hash = _SystemHash.combine(hash, isSent.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnnouncementManagerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Announcement>> {
  /// The parameter `targetAudience` of this provider.
  String? get targetAudience;

  /// The parameter `priority` of this provider.
  String? get priority;

  /// The parameter `isSent` of this provider.
  bool? get isSent;
}

class _AnnouncementManagerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AnnouncementManager,
          List<Announcement>
        >
    with AnnouncementManagerRef {
  _AnnouncementManagerProviderElement(super.provider);

  @override
  String? get targetAudience =>
      (origin as AnnouncementManagerProvider).targetAudience;
  @override
  String? get priority => (origin as AnnouncementManagerProvider).priority;
  @override
  bool? get isSent => (origin as AnnouncementManagerProvider).isSent;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
