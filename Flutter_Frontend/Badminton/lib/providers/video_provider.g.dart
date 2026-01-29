// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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

String _$videosByStudentHash() => r'abc123videosbystudent0123456789abcdef';

/// Provider for videos by student ID
///
/// Copied from [videosByStudent].
@ProviderFor(videosByStudent)
const videosByStudentProvider = VideosByStudentFamily();

/// Provider for videos by student ID
///
/// Copied from [videosByStudent].
class VideosByStudentFamily extends Family<AsyncValue<List<VideoResource>>> {
  /// Provider for videos by student ID
  ///
  /// Copied from [videosByStudent].
  const VideosByStudentFamily();

  /// Provider for videos by student ID
  ///
  /// Copied from [videosByStudent].
  VideosByStudentProvider call(int studentId) {
    return VideosByStudentProvider(studentId);
  }

  @override
  VideosByStudentProvider getProviderOverride(
    covariant VideosByStudentProvider provider,
  ) {
    return call(provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videosByStudentProvider';
}

/// Provider for videos by student ID
///
/// Copied from [videosByStudent].
class VideosByStudentProvider
    extends AutoDisposeFutureProvider<List<VideoResource>> {
  /// Provider for videos by student ID
  ///
  /// Copied from [videosByStudent].
  VideosByStudentProvider(int studentId)
      : this._internal(
          (ref) => videosByStudent(ref as VideosByStudentRef, studentId),
          from: videosByStudentProvider,
          name: r'videosByStudentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videosByStudentHash,
          dependencies: VideosByStudentFamily._dependencies,
          allTransitiveDependencies:
              VideosByStudentFamily._allTransitiveDependencies,
          studentId: studentId,
        );

  VideosByStudentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final int studentId;

  @override
  Override overrideWith(
    FutureOr<List<VideoResource>> Function(VideosByStudentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideosByStudentProvider._internal(
        (ref) => create(ref as VideosByStudentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VideoResource>> createElement() {
    return _VideosByStudentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideosByStudentProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideosByStudentRef on AutoDisposeFutureProviderRef<List<VideoResource>> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _VideosByStudentProviderElement
    extends AutoDisposeFutureProviderElement<List<VideoResource>>
    with VideosByStudentRef {
  _VideosByStudentProviderElement(super.provider);

  @override
  int get studentId => (origin as VideosByStudentProvider).studentId;
}

String _$allVideosHash() => r'def456allvideos0123456789abcdef012345';

/// Provider for all videos (owner view)
///
/// Copied from [allVideos].
@ProviderFor(allVideos)
final allVideosProvider = AutoDisposeFutureProvider<List<VideoResource>>.internal(
  allVideos,
  name: r'allVideosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allVideosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllVideosRef = AutoDisposeFutureProviderRef<List<VideoResource>>;

String _$videoByIdHash() => r'789012videobyid0123456789abcdef012345678';

/// Provider for video by ID
///
/// Copied from [videoById].
@ProviderFor(videoById)
const videoByIdProvider = VideoByIdFamily();

/// Provider for video by ID
///
/// Copied from [videoById].
class VideoByIdFamily extends Family<AsyncValue<VideoResource>> {
  /// Provider for video by ID
  ///
  /// Copied from [videoById].
  const VideoByIdFamily();

  /// Provider for video by ID
  ///
  /// Copied from [videoById].
  VideoByIdProvider call(int id) {
    return VideoByIdProvider(id);
  }

  @override
  VideoByIdProvider getProviderOverride(
    covariant VideoByIdProvider provider,
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
  String? get name => r'videoByIdProvider';
}

/// Provider for video by ID
///
/// Copied from [videoById].
class VideoByIdProvider extends AutoDisposeFutureProvider<VideoResource> {
  /// Provider for video by ID
  ///
  /// Copied from [videoById].
  VideoByIdProvider(int id)
      : this._internal(
          (ref) => videoById(ref as VideoByIdRef, id),
          from: videoByIdProvider,
          name: r'videoByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoByIdHash,
          dependencies: VideoByIdFamily._dependencies,
          allTransitiveDependencies:
              VideoByIdFamily._allTransitiveDependencies,
          id: id,
        );

  VideoByIdProvider._internal(
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
    FutureOr<VideoResource> Function(VideoByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VideoByIdProvider._internal(
        (ref) => create(ref as VideoByIdRef),
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
  AutoDisposeFutureProviderElement<VideoResource> createElement() {
    return _VideoByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoByIdProvider && other.id == id;
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
mixin VideoByIdRef on AutoDisposeFutureProviderRef<VideoResource> {
  /// The parameter `id` of this provider.
  int get id;
}

class _VideoByIdProviderElement
    extends AutoDisposeFutureProviderElement<VideoResource> with VideoByIdRef {
  _VideoByIdProviderElement(super.provider);

  @override
  int get id => (origin as VideoByIdProvider).id;
}

String _$videoManagerHash() => r'abcdef012345videomanager6789012345678901';

/// Provider class for video CRUD operations
///
/// Copied from [VideoManager].
@ProviderFor(VideoManager)
const videoManagerProvider = VideoManagerFamily();

/// Provider class for video CRUD operations
///
/// Copied from [VideoManager].
class VideoManagerFamily extends Family<AsyncValue<List<VideoResource>>> {
  /// Provider class for video CRUD operations
  ///
  /// Copied from [VideoManager].
  const VideoManagerFamily();

  /// Provider class for video CRUD operations
  ///
  /// Copied from [VideoManager].
  VideoManagerProvider call({int? studentId}) {
    return VideoManagerProvider(studentId: studentId);
  }

  @override
  VideoManagerProvider getProviderOverride(
    covariant VideoManagerProvider provider,
  ) {
    return call(studentId: provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoManagerProvider';
}

/// Provider class for video CRUD operations
///
/// Copied from [VideoManager].
class VideoManagerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<VideoManager, List<VideoResource>> {
  /// Provider class for video CRUD operations
  ///
  /// Copied from [VideoManager].
  VideoManagerProvider({int? studentId})
      : this._internal(
          () => VideoManager()..studentId = studentId,
          from: videoManagerProvider,
          name: r'videoManagerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoManagerHash,
          dependencies: VideoManagerFamily._dependencies,
          allTransitiveDependencies:
              VideoManagerFamily._allTransitiveDependencies,
          studentId: studentId,
        );

  VideoManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final int? studentId;

  @override
  FutureOr<List<VideoResource>> runNotifierBuild(
    covariant VideoManager notifier,
  ) {
    return notifier.build(studentId: studentId);
  }

  @override
  Override overrideWith(VideoManager Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoManagerProvider._internal(
        () => create()..studentId = studentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<VideoManager, List<VideoResource>>
      createElement() {
    return _VideoManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoManagerProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoManagerRef
    on AutoDisposeAsyncNotifierProviderRef<List<VideoResource>> {
  /// The parameter `studentId` of this provider.
  int? get studentId;
}

class _VideoManagerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<VideoManager, List<VideoResource>>
    with VideoManagerRef {
  _VideoManagerProviderElement(super.provider);

  @override
  int? get studentId => (origin as VideoManagerProvider).studentId;
}

abstract class _$VideoManager
    extends BuildlessAutoDisposeAsyncNotifier<List<VideoResource>> {
  late final int? studentId;

  FutureOr<List<VideoResource>> build({int? studentId});
}
