# Batch Management Enhancements - Summary

## Changes Implemented

### 1. Active/Inactive Filtering (Owner & Coach Portals)

**Feature:** Added a filter toggle to show only Active or Inactive batches in the list.

**Implementation Details:**
- **UI:** Added "Active" and "Inactive" toggle buttons below the search bar on both `BatchesScreen` (Owner) and `CoachBatchesScreen` (Coach).
- **Default State:** The filter defaults to "Active", showing only active batches initially.
- **Logic:** Implemented case-insensitive filtering based on the `batch.status` field.
  - Active Filter: Shows batches where `status == 'active'` (case-insensitive).
  - Inactive Filter: Shows batches where `status != 'active'` (case-insensitive).

### 2. Owner Dashboard Improvements

**Feature:** "Active Batches" card now displays the correct count and navigates to the batches list.

**Implementation Details:**
- **Navigation:** Clicking the "Active Batches" card on the dashboard now switches the bottom navigation tab to the "Batches" screen.
  - Created `owner_navigation_provider.dart` to manage the bottom navigation state globally.
  - Updated `OwnerDashboard` to use this provider for controlling the active tab.
  - Updated `HomeScreen` to update the provider state on card tap.
- **Correct Count:** Updated `DashboardService._getActiveBatches` to explicitly filter batches by `status == 'active'` on the client side, ensuring the count on the dashboard matches the filtered list.

## Files Modified

1.  `lib/screens/owner/batches_screen.dart`: Added filter state, UI, and logic.
2.  `lib/screens/coach/coach_batches_screen.dart`: Added filter state, UI, and logic.
3.  `lib/core/services/dashboard_service.dart`: Updated active batches count logic.
4.  `lib/providers/owner_navigation_provider.dart`: Created new provider for navigation state.
5.  `lib/screens/owner/owner_dashboard.dart`: Integrated navigation provider.
6.  `lib/screens/owner/home_screen.dart`: Added navigation action to "Active Batches" card.
