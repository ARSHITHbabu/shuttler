import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the bottom navigation index for Owner Dashboard
final ownerBottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Provider to manage the selected filter on the Fees screen
final feeFilterProvider = StateProvider<String>((ref) => 'all');

