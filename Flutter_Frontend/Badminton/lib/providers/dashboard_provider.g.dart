// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$finishedBatchesWithAttendanceHash() =>
    r'abd080b2260462afa02595c1cfad7740c9dce10e';

/// Provider for finished batches with attendance rates
///
/// Copied from [finishedBatchesWithAttendance].
@ProviderFor(finishedBatchesWithAttendance)
final finishedBatchesWithAttendanceProvider =
    AutoDisposeFutureProvider<List<BatchAttendance>>.internal(
      finishedBatchesWithAttendance,
      name: r'finishedBatchesWithAttendanceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$finishedBatchesWithAttendanceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FinishedBatchesWithAttendanceRef =
    AutoDisposeFutureProviderRef<List<BatchAttendance>>;
String _$upcomingBatchesHash() => r'a4f64b269ad4ed065b147b1fbfcb2080b6e173c8';

/// Provider for upcoming batches
///
/// Copied from [upcomingBatches].
@ProviderFor(upcomingBatches)
final upcomingBatchesProvider = AutoDisposeFutureProvider<List<Batch>>.internal(
  upcomingBatches,
  name: r'upcomingBatchesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingBatchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingBatchesRef = AutoDisposeFutureProviderRef<List<Batch>>;
String _$ownerUpcomingSessionsHash() =>
    r'dc1f31b1c03c8df92ab931ca314b8c911b2f8147';

/// Provider for upcoming sessions for all active batches (Owner view)
/// Shows next occurrence for each active batch
///
/// Copied from [ownerUpcomingSessions].
@ProviderFor(ownerUpcomingSessions)
final ownerUpcomingSessionsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      ownerUpcomingSessions,
      name: r'ownerUpcomingSessionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ownerUpcomingSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OwnerUpcomingSessionsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$dashboardStatsHash() => r'c417e1c971b9ab1e42fed39c39d72b0503b56624';

/// Provider for dashboard statistics
///
/// Copied from [DashboardStats].
@ProviderFor(DashboardStats)
final dashboardStatsProvider =
    AutoDisposeAsyncNotifierProvider<
      DashboardStats,
      DashboardStatsData
    >.internal(
      DashboardStats.new,
      name: r'dashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardStats = AutoDisposeAsyncNotifier<DashboardStatsData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
