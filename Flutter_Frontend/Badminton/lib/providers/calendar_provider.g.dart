// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarEventsHash() => r'3a0a83ecc4689643feced0f5f043750a0ede13ad';

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

/// Provider for calendar events by date range
///
/// Copied from [calendarEvents].
@ProviderFor(calendarEvents)
const calendarEventsProvider = CalendarEventsFamily();

/// Provider for calendar events by date range
///
/// Copied from [calendarEvents].
class CalendarEventsFamily extends Family<AsyncValue<List<CalendarEvent>>> {
  /// Provider for calendar events by date range
  ///
  /// Copied from [calendarEvents].
  const CalendarEventsFamily();

  /// Provider for calendar events by date range
  ///
  /// Copied from [calendarEvents].
  CalendarEventsProvider call({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) {
    return CalendarEventsProvider(
      startDate: startDate,
      endDate: endDate,
      eventType: eventType,
    );
  }

  @override
  CalendarEventsProvider getProviderOverride(
    covariant CalendarEventsProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
      eventType: provider.eventType,
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
  String? get name => r'calendarEventsProvider';
}

/// Provider for calendar events by date range
///
/// Copied from [calendarEvents].
class CalendarEventsProvider
    extends AutoDisposeFutureProvider<List<CalendarEvent>> {
  /// Provider for calendar events by date range
  ///
  /// Copied from [calendarEvents].
  CalendarEventsProvider({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) : this._internal(
         (ref) => calendarEvents(
           ref as CalendarEventsRef,
           startDate: startDate,
           endDate: endDate,
           eventType: eventType,
         ),
         from: calendarEventsProvider,
         name: r'calendarEventsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$calendarEventsHash,
         dependencies: CalendarEventsFamily._dependencies,
         allTransitiveDependencies:
             CalendarEventsFamily._allTransitiveDependencies,
         startDate: startDate,
         endDate: endDate,
         eventType: eventType,
       );

  CalendarEventsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
    required this.eventType,
  }) : super.internal();

  final DateTime? startDate;
  final DateTime? endDate;
  final String? eventType;

  @override
  Override overrideWith(
    FutureOr<List<CalendarEvent>> Function(CalendarEventsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarEventsProvider._internal(
        (ref) => create(ref as CalendarEventsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
        eventType: eventType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CalendarEvent>> createElement() {
    return _CalendarEventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventsProvider &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.eventType == eventType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, eventType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarEventsRef on AutoDisposeFutureProviderRef<List<CalendarEvent>> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `eventType` of this provider.
  String? get eventType;
}

class _CalendarEventsProviderElement
    extends AutoDisposeFutureProviderElement<List<CalendarEvent>>
    with CalendarEventsRef {
  _CalendarEventsProviderElement(super.provider);

  @override
  DateTime? get startDate => (origin as CalendarEventsProvider).startDate;
  @override
  DateTime? get endDate => (origin as CalendarEventsProvider).endDate;
  @override
  String? get eventType => (origin as CalendarEventsProvider).eventType;
}

String _$yearlyEventsHash() => r'778db72269d93b045cad3615b5d3a1ad7d71fbed';

/// Provider for calendar events for a specific year
///
/// Copied from [yearlyEvents].
@ProviderFor(yearlyEvents)
const yearlyEventsProvider = YearlyEventsFamily();

/// Provider for calendar events for a specific year
///
/// Copied from [yearlyEvents].
class YearlyEventsFamily extends Family<AsyncValue<List<CalendarEvent>>> {
  /// Provider for calendar events for a specific year
  ///
  /// Copied from [yearlyEvents].
  const YearlyEventsFamily();

  /// Provider for calendar events for a specific year
  ///
  /// Copied from [yearlyEvents].
  YearlyEventsProvider call(int year) {
    return YearlyEventsProvider(year);
  }

  @override
  YearlyEventsProvider getProviderOverride(
    covariant YearlyEventsProvider provider,
  ) {
    return call(provider.year);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'yearlyEventsProvider';
}

/// Provider for calendar events for a specific year
///
/// Copied from [yearlyEvents].
class YearlyEventsProvider
    extends AutoDisposeFutureProvider<List<CalendarEvent>> {
  /// Provider for calendar events for a specific year
  ///
  /// Copied from [yearlyEvents].
  YearlyEventsProvider(int year)
    : this._internal(
        (ref) => yearlyEvents(ref as YearlyEventsRef, year),
        from: yearlyEventsProvider,
        name: r'yearlyEventsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$yearlyEventsHash,
        dependencies: YearlyEventsFamily._dependencies,
        allTransitiveDependencies:
            YearlyEventsFamily._allTransitiveDependencies,
        year: year,
      );

  YearlyEventsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
  }) : super.internal();

  final int year;

  @override
  Override overrideWith(
    FutureOr<List<CalendarEvent>> Function(YearlyEventsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: YearlyEventsProvider._internal(
        (ref) => create(ref as YearlyEventsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CalendarEvent>> createElement() {
    return _YearlyEventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is YearlyEventsProvider && other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin YearlyEventsRef on AutoDisposeFutureProviderRef<List<CalendarEvent>> {
  /// The parameter `year` of this provider.
  int get year;
}

class _YearlyEventsProviderElement
    extends AutoDisposeFutureProviderElement<List<CalendarEvent>>
    with YearlyEventsRef {
  _YearlyEventsProviderElement(super.provider);

  @override
  int get year => (origin as YearlyEventsProvider).year;
}

String _$calendarEventByDateHash() =>
    r'9fea6c08569c7da2f914c694144ba337ab874ed0';

/// Provider for calendar events by specific date
///
/// Copied from [calendarEventByDate].
@ProviderFor(calendarEventByDate)
const calendarEventByDateProvider = CalendarEventByDateFamily();

/// Provider for calendar events by specific date
///
/// Copied from [calendarEventByDate].
class CalendarEventByDateFamily
    extends Family<AsyncValue<List<CalendarEvent>>> {
  /// Provider for calendar events by specific date
  ///
  /// Copied from [calendarEventByDate].
  const CalendarEventByDateFamily();

  /// Provider for calendar events by specific date
  ///
  /// Copied from [calendarEventByDate].
  CalendarEventByDateProvider call(DateTime date) {
    return CalendarEventByDateProvider(date);
  }

  @override
  CalendarEventByDateProvider getProviderOverride(
    covariant CalendarEventByDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calendarEventByDateProvider';
}

/// Provider for calendar events by specific date
///
/// Copied from [calendarEventByDate].
class CalendarEventByDateProvider
    extends AutoDisposeFutureProvider<List<CalendarEvent>> {
  /// Provider for calendar events by specific date
  ///
  /// Copied from [calendarEventByDate].
  CalendarEventByDateProvider(DateTime date)
    : this._internal(
        (ref) => calendarEventByDate(ref as CalendarEventByDateRef, date),
        from: calendarEventByDateProvider,
        name: r'calendarEventByDateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calendarEventByDateHash,
        dependencies: CalendarEventByDateFamily._dependencies,
        allTransitiveDependencies:
            CalendarEventByDateFamily._allTransitiveDependencies,
        date: date,
      );

  CalendarEventByDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<List<CalendarEvent>> Function(CalendarEventByDateRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarEventByDateProvider._internal(
        (ref) => create(ref as CalendarEventByDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CalendarEvent>> createElement() {
    return _CalendarEventByDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventByDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarEventByDateRef
    on AutoDisposeFutureProviderRef<List<CalendarEvent>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _CalendarEventByDateProviderElement
    extends AutoDisposeFutureProviderElement<List<CalendarEvent>>
    with CalendarEventByDateRef {
  _CalendarEventByDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as CalendarEventByDateProvider).date;
}

String _$calendarEventByTypeHash() =>
    r'8827bbf943bed630a940f9c19af30c2b1e0fdd70';

/// Provider for calendar events by type
///
/// Copied from [calendarEventByType].
@ProviderFor(calendarEventByType)
const calendarEventByTypeProvider = CalendarEventByTypeFamily();

/// Provider for calendar events by type
///
/// Copied from [calendarEventByType].
class CalendarEventByTypeFamily
    extends Family<AsyncValue<List<CalendarEvent>>> {
  /// Provider for calendar events by type
  ///
  /// Copied from [calendarEventByType].
  const CalendarEventByTypeFamily();

  /// Provider for calendar events by type
  ///
  /// Copied from [calendarEventByType].
  CalendarEventByTypeProvider call(String eventType) {
    return CalendarEventByTypeProvider(eventType);
  }

  @override
  CalendarEventByTypeProvider getProviderOverride(
    covariant CalendarEventByTypeProvider provider,
  ) {
    return call(provider.eventType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calendarEventByTypeProvider';
}

/// Provider for calendar events by type
///
/// Copied from [calendarEventByType].
class CalendarEventByTypeProvider
    extends AutoDisposeFutureProvider<List<CalendarEvent>> {
  /// Provider for calendar events by type
  ///
  /// Copied from [calendarEventByType].
  CalendarEventByTypeProvider(String eventType)
    : this._internal(
        (ref) => calendarEventByType(ref as CalendarEventByTypeRef, eventType),
        from: calendarEventByTypeProvider,
        name: r'calendarEventByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calendarEventByTypeHash,
        dependencies: CalendarEventByTypeFamily._dependencies,
        allTransitiveDependencies:
            CalendarEventByTypeFamily._allTransitiveDependencies,
        eventType: eventType,
      );

  CalendarEventByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventType,
  }) : super.internal();

  final String eventType;

  @override
  Override overrideWith(
    FutureOr<List<CalendarEvent>> Function(CalendarEventByTypeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarEventByTypeProvider._internal(
        (ref) => create(ref as CalendarEventByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventType: eventType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CalendarEvent>> createElement() {
    return _CalendarEventByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventByTypeProvider && other.eventType == eventType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarEventByTypeRef
    on AutoDisposeFutureProviderRef<List<CalendarEvent>> {
  /// The parameter `eventType` of this provider.
  String get eventType;
}

class _CalendarEventByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<CalendarEvent>>
    with CalendarEventByTypeRef {
  _CalendarEventByTypeProviderElement(super.provider);

  @override
  String get eventType => (origin as CalendarEventByTypeProvider).eventType;
}

String _$calendarEventByIdHash() => r'04a3d77e89caa3667e57e3269f497cbf0f3ca732';

/// Provider for calendar event by ID
///
/// Copied from [calendarEventById].
@ProviderFor(calendarEventById)
const calendarEventByIdProvider = CalendarEventByIdFamily();

/// Provider for calendar event by ID
///
/// Copied from [calendarEventById].
class CalendarEventByIdFamily extends Family<AsyncValue<CalendarEvent>> {
  /// Provider for calendar event by ID
  ///
  /// Copied from [calendarEventById].
  const CalendarEventByIdFamily();

  /// Provider for calendar event by ID
  ///
  /// Copied from [calendarEventById].
  CalendarEventByIdProvider call(int id) {
    return CalendarEventByIdProvider(id);
  }

  @override
  CalendarEventByIdProvider getProviderOverride(
    covariant CalendarEventByIdProvider provider,
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
  String? get name => r'calendarEventByIdProvider';
}

/// Provider for calendar event by ID
///
/// Copied from [calendarEventById].
class CalendarEventByIdProvider
    extends AutoDisposeFutureProvider<CalendarEvent> {
  /// Provider for calendar event by ID
  ///
  /// Copied from [calendarEventById].
  CalendarEventByIdProvider(int id)
    : this._internal(
        (ref) => calendarEventById(ref as CalendarEventByIdRef, id),
        from: calendarEventByIdProvider,
        name: r'calendarEventByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calendarEventByIdHash,
        dependencies: CalendarEventByIdFamily._dependencies,
        allTransitiveDependencies:
            CalendarEventByIdFamily._allTransitiveDependencies,
        id: id,
      );

  CalendarEventByIdProvider._internal(
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
    FutureOr<CalendarEvent> Function(CalendarEventByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarEventByIdProvider._internal(
        (ref) => create(ref as CalendarEventByIdRef),
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
  AutoDisposeFutureProviderElement<CalendarEvent> createElement() {
    return _CalendarEventByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventByIdProvider && other.id == id;
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
mixin CalendarEventByIdRef on AutoDisposeFutureProviderRef<CalendarEvent> {
  /// The parameter `id` of this provider.
  int get id;
}

class _CalendarEventByIdProviderElement
    extends AutoDisposeFutureProviderElement<CalendarEvent>
    with CalendarEventByIdRef {
  _CalendarEventByIdProviderElement(super.provider);

  @override
  int get id => (origin as CalendarEventByIdProvider).id;
}

String _$calendarEventListHash() => r'2666982d74898e6cdddb37a9906d2be011e23cbd';

abstract class _$CalendarEventList
    extends BuildlessAutoDisposeAsyncNotifier<List<CalendarEvent>> {
  late final DateTime? startDate;
  late final DateTime? endDate;
  late final String? eventType;

  FutureOr<List<CalendarEvent>> build({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  });
}

/// Provider class for calendar CRUD operations
///
/// Copied from [CalendarEventList].
@ProviderFor(CalendarEventList)
const calendarEventListProvider = CalendarEventListFamily();

/// Provider class for calendar CRUD operations
///
/// Copied from [CalendarEventList].
class CalendarEventListFamily extends Family<AsyncValue<List<CalendarEvent>>> {
  /// Provider class for calendar CRUD operations
  ///
  /// Copied from [CalendarEventList].
  const CalendarEventListFamily();

  /// Provider class for calendar CRUD operations
  ///
  /// Copied from [CalendarEventList].
  CalendarEventListProvider call({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) {
    return CalendarEventListProvider(
      startDate: startDate,
      endDate: endDate,
      eventType: eventType,
    );
  }

  @override
  CalendarEventListProvider getProviderOverride(
    covariant CalendarEventListProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
      eventType: provider.eventType,
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
  String? get name => r'calendarEventListProvider';
}

/// Provider class for calendar CRUD operations
///
/// Copied from [CalendarEventList].
class CalendarEventListProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CalendarEventList,
          List<CalendarEvent>
        > {
  /// Provider class for calendar CRUD operations
  ///
  /// Copied from [CalendarEventList].
  CalendarEventListProvider({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) : this._internal(
         () => CalendarEventList()
           ..startDate = startDate
           ..endDate = endDate
           ..eventType = eventType,
         from: calendarEventListProvider,
         name: r'calendarEventListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$calendarEventListHash,
         dependencies: CalendarEventListFamily._dependencies,
         allTransitiveDependencies:
             CalendarEventListFamily._allTransitiveDependencies,
         startDate: startDate,
         endDate: endDate,
         eventType: eventType,
       );

  CalendarEventListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
    required this.eventType,
  }) : super.internal();

  final DateTime? startDate;
  final DateTime? endDate;
  final String? eventType;

  @override
  FutureOr<List<CalendarEvent>> runNotifierBuild(
    covariant CalendarEventList notifier,
  ) {
    return notifier.build(
      startDate: startDate,
      endDate: endDate,
      eventType: eventType,
    );
  }

  @override
  Override overrideWith(CalendarEventList Function() create) {
    return ProviderOverride(
      origin: this,
      override: CalendarEventListProvider._internal(
        () => create()
          ..startDate = startDate
          ..endDate = endDate
          ..eventType = eventType,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
        eventType: eventType,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    CalendarEventList,
    List<CalendarEvent>
  >
  createElement() {
    return _CalendarEventListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventListProvider &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.eventType == eventType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, eventType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarEventListRef
    on AutoDisposeAsyncNotifierProviderRef<List<CalendarEvent>> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `eventType` of this provider.
  String? get eventType;
}

class _CalendarEventListProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CalendarEventList,
          List<CalendarEvent>
        >
    with CalendarEventListRef {
  _CalendarEventListProviderElement(super.provider);

  @override
  DateTime? get startDate => (origin as CalendarEventListProvider).startDate;
  @override
  DateTime? get endDate => (origin as CalendarEventListProvider).endDate;
  @override
  String? get eventType => (origin as CalendarEventListProvider).eventType;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
