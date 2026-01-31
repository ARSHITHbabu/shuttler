// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tournamentListHash() => r'f257b3971aa46478f8f72b94486fb7af2c1619f3';

/// Provider for all tournaments
///
/// Copied from [tournamentList].
@ProviderFor(tournamentList)
final tournamentListProvider =
    AutoDisposeFutureProvider<List<Tournament>>.internal(
      tournamentList,
      name: r'tournamentListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tournamentListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TournamentListRef = AutoDisposeFutureProviderRef<List<Tournament>>;
String _$upcomingTournamentsHash() =>
    r'1c4932e39bbe5472a5d94bf7ae3122ce86dbc563';

/// Provider for upcoming tournaments
///
/// Copied from [upcomingTournaments].
@ProviderFor(upcomingTournaments)
final upcomingTournamentsProvider =
    AutoDisposeFutureProvider<List<Tournament>>.internal(
      upcomingTournaments,
      name: r'upcomingTournamentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$upcomingTournamentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingTournamentsRef = AutoDisposeFutureProviderRef<List<Tournament>>;
String _$tournamentByIdHash() => r'bb770ae4102e34a484c28407b29b6f9fcb15d2c2';

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

/// Provider for tournament by ID
///
/// Copied from [tournamentById].
@ProviderFor(tournamentById)
const tournamentByIdProvider = TournamentByIdFamily();

/// Provider for tournament by ID
///
/// Copied from [tournamentById].
class TournamentByIdFamily extends Family<AsyncValue<Tournament>> {
  /// Provider for tournament by ID
  ///
  /// Copied from [tournamentById].
  const TournamentByIdFamily();

  /// Provider for tournament by ID
  ///
  /// Copied from [tournamentById].
  TournamentByIdProvider call(int id) {
    return TournamentByIdProvider(id);
  }

  @override
  TournamentByIdProvider getProviderOverride(
    covariant TournamentByIdProvider provider,
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
  String? get name => r'tournamentByIdProvider';
}

/// Provider for tournament by ID
///
/// Copied from [tournamentById].
class TournamentByIdProvider extends AutoDisposeFutureProvider<Tournament> {
  /// Provider for tournament by ID
  ///
  /// Copied from [tournamentById].
  TournamentByIdProvider(int id)
    : this._internal(
        (ref) => tournamentById(ref as TournamentByIdRef, id),
        from: tournamentByIdProvider,
        name: r'tournamentByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tournamentByIdHash,
        dependencies: TournamentByIdFamily._dependencies,
        allTransitiveDependencies:
            TournamentByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TournamentByIdProvider._internal(
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
    FutureOr<Tournament> Function(TournamentByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TournamentByIdProvider._internal(
        (ref) => create(ref as TournamentByIdRef),
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
  AutoDisposeFutureProviderElement<Tournament> createElement() {
    return _TournamentByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentByIdProvider && other.id == id;
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
mixin TournamentByIdRef on AutoDisposeFutureProviderRef<Tournament> {
  /// The parameter `id` of this provider.
  int get id;
}

class _TournamentByIdProviderElement
    extends AutoDisposeFutureProviderElement<Tournament>
    with TournamentByIdRef {
  _TournamentByIdProviderElement(super.provider);

  @override
  int get id => (origin as TournamentByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
