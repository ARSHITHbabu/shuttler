// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingBatchesHash() => r'de062d46c63d266da25e5a7ac291629a9d664f5f';

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
String _$dashboardStatsHash() => r'0e48396effce8f7c9d046f1cd23df0e334c5f1dd';

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
