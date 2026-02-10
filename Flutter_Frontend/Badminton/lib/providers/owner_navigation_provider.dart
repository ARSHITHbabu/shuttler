import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the bottom navigation index for Owner Dashboard
final ownerBottomNavIndexProvider = StateProvider<int>((ref) => 0);
