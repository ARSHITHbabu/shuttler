// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationListHash() => r'7f3bc8279d2957a5a6285babe96ab29b5c1ccd4c';

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

/// Provider for notification list
///
/// Copied from [notificationList].
@ProviderFor(notificationList)
const notificationListProvider = NotificationListFamily();

/// Provider for notification list
///
/// Copied from [notificationList].
class NotificationListFamily extends Family<AsyncValue<List<Notification>>> {
  /// Provider for notification list
  ///
  /// Copied from [notificationList].
  const NotificationListFamily();

  /// Provider for notification list
  ///
  /// Copied from [notificationList].
  NotificationListProvider call(
    int userId,
    String userType, {
    String? type,
    bool? isRead,
  }) {
    return NotificationListProvider(
      userId,
      userType,
      type: type,
      isRead: isRead,
    );
  }

  @override
  NotificationListProvider getProviderOverride(
    covariant NotificationListProvider provider,
  ) {
    return call(
      provider.userId,
      provider.userType,
      type: provider.type,
      isRead: provider.isRead,
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
  String? get name => r'notificationListProvider';
}

/// Provider for notification list
///
/// Copied from [notificationList].
class NotificationListProvider
    extends AutoDisposeFutureProvider<List<Notification>> {
  /// Provider for notification list
  ///
  /// Copied from [notificationList].
  NotificationListProvider(
    int userId,
    String userType, {
    String? type,
    bool? isRead,
  }) : this._internal(
         (ref) => notificationList(
           ref as NotificationListRef,
           userId,
           userType,
           type: type,
           isRead: isRead,
         ),
         from: notificationListProvider,
         name: r'notificationListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$notificationListHash,
         dependencies: NotificationListFamily._dependencies,
         allTransitiveDependencies:
             NotificationListFamily._allTransitiveDependencies,
         userId: userId,
         userType: userType,
         type: type,
         isRead: isRead,
       );

  NotificationListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.userType,
    required this.type,
    required this.isRead,
  }) : super.internal();

  final int userId;
  final String userType;
  final String? type;
  final bool? isRead;

  @override
  Override overrideWith(
    FutureOr<List<Notification>> Function(NotificationListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotificationListProvider._internal(
        (ref) => create(ref as NotificationListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        userType: userType,
        type: type,
        isRead: isRead,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Notification>> createElement() {
    return _NotificationListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationListProvider &&
        other.userId == userId &&
        other.userType == userType &&
        other.type == type &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, userType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, isRead.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationListRef on AutoDisposeFutureProviderRef<List<Notification>> {
  /// The parameter `userId` of this provider.
  int get userId;

  /// The parameter `userType` of this provider.
  String get userType;

  /// The parameter `type` of this provider.
  String? get type;

  /// The parameter `isRead` of this provider.
  bool? get isRead;
}

class _NotificationListProviderElement
    extends AutoDisposeFutureProviderElement<List<Notification>>
    with NotificationListRef {
  _NotificationListProviderElement(super.provider);

  @override
  int get userId => (origin as NotificationListProvider).userId;
  @override
  String get userType => (origin as NotificationListProvider).userType;
  @override
  String? get type => (origin as NotificationListProvider).type;
  @override
  bool? get isRead => (origin as NotificationListProvider).isRead;
}

String _$unreadCountHash() => r'b51ccbe03446609784e9663604b76a3981460362';

/// Provider for unread notification count
///
/// Copied from [unreadCount].
@ProviderFor(unreadCount)
const unreadCountProvider = UnreadCountFamily();

/// Provider for unread notification count
///
/// Copied from [unreadCount].
class UnreadCountFamily extends Family<AsyncValue<int>> {
  /// Provider for unread notification count
  ///
  /// Copied from [unreadCount].
  const UnreadCountFamily();

  /// Provider for unread notification count
  ///
  /// Copied from [unreadCount].
  UnreadCountProvider call(int userId, String userType) {
    return UnreadCountProvider(userId, userType);
  }

  @override
  UnreadCountProvider getProviderOverride(
    covariant UnreadCountProvider provider,
  ) {
    return call(provider.userId, provider.userType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'unreadCountProvider';
}

/// Provider for unread notification count
///
/// Copied from [unreadCount].
class UnreadCountProvider extends AutoDisposeFutureProvider<int> {
  /// Provider for unread notification count
  ///
  /// Copied from [unreadCount].
  UnreadCountProvider(int userId, String userType)
    : this._internal(
        (ref) => unreadCount(ref as UnreadCountRef, userId, userType),
        from: unreadCountProvider,
        name: r'unreadCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unreadCountHash,
        dependencies: UnreadCountFamily._dependencies,
        allTransitiveDependencies: UnreadCountFamily._allTransitiveDependencies,
        userId: userId,
        userType: userType,
      );

  UnreadCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.userType,
  }) : super.internal();

  final int userId;
  final String userType;

  @override
  Override overrideWith(
    FutureOr<int> Function(UnreadCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadCountProvider._internal(
        (ref) => create(ref as UnreadCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        userType: userType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _UnreadCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadCountProvider &&
        other.userId == userId &&
        other.userType == userType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, userType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnreadCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `userId` of this provider.
  int get userId;

  /// The parameter `userType` of this provider.
  String get userType;
}

class _UnreadCountProviderElement extends AutoDisposeFutureProviderElement<int>
    with UnreadCountRef {
  _UnreadCountProviderElement(super.provider);

  @override
  int get userId => (origin as UnreadCountProvider).userId;
  @override
  String get userType => (origin as UnreadCountProvider).userType;
}

String _$notificationByTypeHash() =>
    r'55064d6900514111507623e190930e103bfb1fd8';

/// Provider for notifications by type
///
/// Copied from [notificationByType].
@ProviderFor(notificationByType)
const notificationByTypeProvider = NotificationByTypeFamily();

/// Provider for notifications by type
///
/// Copied from [notificationByType].
class NotificationByTypeFamily extends Family<AsyncValue<List<Notification>>> {
  /// Provider for notifications by type
  ///
  /// Copied from [notificationByType].
  const NotificationByTypeFamily();

  /// Provider for notifications by type
  ///
  /// Copied from [notificationByType].
  NotificationByTypeProvider call(int userId, String userType, String type) {
    return NotificationByTypeProvider(userId, userType, type);
  }

  @override
  NotificationByTypeProvider getProviderOverride(
    covariant NotificationByTypeProvider provider,
  ) {
    return call(provider.userId, provider.userType, provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notificationByTypeProvider';
}

/// Provider for notifications by type
///
/// Copied from [notificationByType].
class NotificationByTypeProvider
    extends AutoDisposeFutureProvider<List<Notification>> {
  /// Provider for notifications by type
  ///
  /// Copied from [notificationByType].
  NotificationByTypeProvider(int userId, String userType, String type)
    : this._internal(
        (ref) => notificationByType(
          ref as NotificationByTypeRef,
          userId,
          userType,
          type,
        ),
        from: notificationByTypeProvider,
        name: r'notificationByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notificationByTypeHash,
        dependencies: NotificationByTypeFamily._dependencies,
        allTransitiveDependencies:
            NotificationByTypeFamily._allTransitiveDependencies,
        userId: userId,
        userType: userType,
        type: type,
      );

  NotificationByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.userType,
    required this.type,
  }) : super.internal();

  final int userId;
  final String userType;
  final String type;

  @override
  Override overrideWith(
    FutureOr<List<Notification>> Function(NotificationByTypeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotificationByTypeProvider._internal(
        (ref) => create(ref as NotificationByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        userType: userType,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Notification>> createElement() {
    return _NotificationByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationByTypeProvider &&
        other.userId == userId &&
        other.userType == userType &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, userType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationByTypeRef
    on AutoDisposeFutureProviderRef<List<Notification>> {
  /// The parameter `userId` of this provider.
  int get userId;

  /// The parameter `userType` of this provider.
  String get userType;

  /// The parameter `type` of this provider.
  String get type;
}

class _NotificationByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<Notification>>
    with NotificationByTypeRef {
  _NotificationByTypeProviderElement(super.provider);

  @override
  int get userId => (origin as NotificationByTypeProvider).userId;
  @override
  String get userType => (origin as NotificationByTypeProvider).userType;
  @override
  String get type => (origin as NotificationByTypeProvider).type;
}

String _$notificationByIdHash() => r'486e77d249f81ceef0381c6f678e1cfda35848ad';

/// Provider for notification by ID
///
/// Copied from [notificationById].
@ProviderFor(notificationById)
const notificationByIdProvider = NotificationByIdFamily();

/// Provider for notification by ID
///
/// Copied from [notificationById].
class NotificationByIdFamily extends Family<AsyncValue<Notification>> {
  /// Provider for notification by ID
  ///
  /// Copied from [notificationById].
  const NotificationByIdFamily();

  /// Provider for notification by ID
  ///
  /// Copied from [notificationById].
  NotificationByIdProvider call(int id) {
    return NotificationByIdProvider(id);
  }

  @override
  NotificationByIdProvider getProviderOverride(
    covariant NotificationByIdProvider provider,
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
  String? get name => r'notificationByIdProvider';
}

/// Provider for notification by ID
///
/// Copied from [notificationById].
class NotificationByIdProvider extends AutoDisposeFutureProvider<Notification> {
  /// Provider for notification by ID
  ///
  /// Copied from [notificationById].
  NotificationByIdProvider(int id)
    : this._internal(
        (ref) => notificationById(ref as NotificationByIdRef, id),
        from: notificationByIdProvider,
        name: r'notificationByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notificationByIdHash,
        dependencies: NotificationByIdFamily._dependencies,
        allTransitiveDependencies:
            NotificationByIdFamily._allTransitiveDependencies,
        id: id,
      );

  NotificationByIdProvider._internal(
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
    FutureOr<Notification> Function(NotificationByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotificationByIdProvider._internal(
        (ref) => create(ref as NotificationByIdRef),
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
  AutoDisposeFutureProviderElement<Notification> createElement() {
    return _NotificationByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationByIdProvider && other.id == id;
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
mixin NotificationByIdRef on AutoDisposeFutureProviderRef<Notification> {
  /// The parameter `id` of this provider.
  int get id;
}

class _NotificationByIdProviderElement
    extends AutoDisposeFutureProviderElement<Notification>
    with NotificationByIdRef {
  _NotificationByIdProviderElement(super.provider);

  @override
  int get id => (origin as NotificationByIdProvider).id;
}

String _$notificationManagerHash() =>
    r'64d497425896beb41547ce6436cd574d1b271a37';

abstract class _$NotificationManager
    extends BuildlessAutoDisposeAsyncNotifier<List<Notification>> {
  late final int userId;
  late final String userType;
  late final String? type;
  late final bool? isRead;

  FutureOr<List<Notification>> build({
    required int userId,
    required String userType,
    String? type,
    bool? isRead,
  });
}

/// Provider class for notification operations
///
/// Copied from [NotificationManager].
@ProviderFor(NotificationManager)
const notificationManagerProvider = NotificationManagerFamily();

/// Provider class for notification operations
///
/// Copied from [NotificationManager].
class NotificationManagerFamily extends Family<AsyncValue<List<Notification>>> {
  /// Provider class for notification operations
  ///
  /// Copied from [NotificationManager].
  const NotificationManagerFamily();

  /// Provider class for notification operations
  ///
  /// Copied from [NotificationManager].
  NotificationManagerProvider call({
    required int userId,
    required String userType,
    String? type,
    bool? isRead,
  }) {
    return NotificationManagerProvider(
      userId: userId,
      userType: userType,
      type: type,
      isRead: isRead,
    );
  }

  @override
  NotificationManagerProvider getProviderOverride(
    covariant NotificationManagerProvider provider,
  ) {
    return call(
      userId: provider.userId,
      userType: provider.userType,
      type: provider.type,
      isRead: provider.isRead,
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
  String? get name => r'notificationManagerProvider';
}

/// Provider class for notification operations
///
/// Copied from [NotificationManager].
class NotificationManagerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          NotificationManager,
          List<Notification>
        > {
  /// Provider class for notification operations
  ///
  /// Copied from [NotificationManager].
  NotificationManagerProvider({
    required int userId,
    required String userType,
    String? type,
    bool? isRead,
  }) : this._internal(
         () => NotificationManager()
           ..userId = userId
           ..userType = userType
           ..type = type
           ..isRead = isRead,
         from: notificationManagerProvider,
         name: r'notificationManagerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$notificationManagerHash,
         dependencies: NotificationManagerFamily._dependencies,
         allTransitiveDependencies:
             NotificationManagerFamily._allTransitiveDependencies,
         userId: userId,
         userType: userType,
         type: type,
         isRead: isRead,
       );

  NotificationManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.userType,
    required this.type,
    required this.isRead,
  }) : super.internal();

  final int userId;
  final String userType;
  final String? type;
  final bool? isRead;

  @override
  FutureOr<List<Notification>> runNotifierBuild(
    covariant NotificationManager notifier,
  ) {
    return notifier.build(
      userId: userId,
      userType: userType,
      type: type,
      isRead: isRead,
    );
  }

  @override
  Override overrideWith(NotificationManager Function() create) {
    return ProviderOverride(
      origin: this,
      override: NotificationManagerProvider._internal(
        () => create()
          ..userId = userId
          ..userType = userType
          ..type = type
          ..isRead = isRead,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        userType: userType,
        type: type,
        isRead: isRead,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    NotificationManager,
    List<Notification>
  >
  createElement() {
    return _NotificationManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationManagerProvider &&
        other.userId == userId &&
        other.userType == userType &&
        other.type == type &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, userType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, isRead.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationManagerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Notification>> {
  /// The parameter `userId` of this provider.
  int get userId;

  /// The parameter `userType` of this provider.
  String get userType;

  /// The parameter `type` of this provider.
  String? get type;

  /// The parameter `isRead` of this provider.
  bool? get isRead;
}

class _NotificationManagerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          NotificationManager,
          List<Notification>
        >
    with NotificationManagerRef {
  _NotificationManagerProviderElement(super.provider);

  @override
  int get userId => (origin as NotificationManagerProvider).userId;
  @override
  String get userType => (origin as NotificationManagerProvider).userType;
  @override
  String? get type => (origin as NotificationManagerProvider).type;
  @override
  bool? get isRead => (origin as NotificationManagerProvider).isRead;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
