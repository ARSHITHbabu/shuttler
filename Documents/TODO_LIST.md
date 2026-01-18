# TODO List - Badminton Academy Management System

**Last Updated**: 2026-01-XX
**Status**: 2 of 35+ items completed

---

## Progress Summary

- ✅ **Completed**: 2 items (students_screen.dart, fees_screen.dart)
- ⏳ **In Progress**: 0 items
- ⬜ **Pending**: 33+ items

---

## HIGH PRIORITY - Screen Migration to Providers

### ✅ 1. Migrate `lib/screens/owner/students_screen.dart`
- [x] Replace direct service calls with `studentListProvider`
- [x] Use `studentSearchProvider` for search functionality
- [x] Integrate Phase 6 components (skeleton, empty states, error handling, success feedback)
- [x] Replace FutureBuilder with AsyncValue.when pattern
- [x] Update all CRUD operations to use provider notifiers
- [x] Replace SnackBar with SuccessSnackbar
- [x] Replace AlertDialog with ConfirmationDialog for delete operations
- **Status**: ✅ **COMPLETED**

### ✅ 2. Migrate `lib/screens/owner/fees_screen.dart`
- [x] Replace direct service calls with `feeListProvider`
- [x] Use provider with status filter parameter
- [x] Integrate Phase 6 components (skeleton, empty states, error handling, success feedback)
- [x] Replace FutureBuilder with AsyncValue.when pattern
- [x] Update all CRUD operations to use provider notifiers
- [x] Replace SnackBar with SuccessSnackbar
- [x] Replace AlertDialog with ConfirmationDialog for delete operations
- **Status**: ✅ **COMPLETED**

### ⬜ 3. Migrate `lib/screens/owner/coaches_screen.dart`
- [ ] Replace direct service calls with providers
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 4. Migrate `lib/screens/owner/batches_screen.dart`
- [ ] Replace direct service calls with `batchListProvider`
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 5. Migrate `lib/screens/owner/attendance_screen.dart`
- [ ] Replace direct service calls with providers
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 6. Migrate `lib/screens/owner/performance_tracking_screen.dart`
- [ ] Replace direct service calls with `performanceListProvider`
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 7. Migrate `lib/screens/owner/bmi_tracking_screen.dart`
- [ ] Replace direct service calls with `bmiListProvider`
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 8. Migrate `lib/screens/owner/sessions_screen.dart`
- [ ] Replace direct service calls with providers
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 9. Migrate `lib/screens/owner/announcements_screen.dart`
- [ ] Replace direct service calls with `announcementListProvider`
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 10. Migrate `lib/screens/owner/calendar_screen.dart`
- [ ] Replace direct service calls with `calendarEventListProvider`
- [ ] Integrate Phase 6 components
- [ ] Update CRUD operations

### ⬜ 11. Migrate `lib/screens/owner/reports_screen.dart`
- [ ] Replace direct service calls with providers
- [ ] Integrate Phase 6 components
- [ ] Implement export functionality (PDF/CSV)

---

## MEDIUM PRIORITY - Widget Integration

### ⬜ 12. Integrate Loading States
- [ ] Replace LoadingSpinner with ListSkeleton in all list screens
- [ ] Replace LoadingSpinner with DashboardSkeleton in dashboard screens
- [ ] Replace LoadingSpinner with ProfileSkeleton in profile screens
- [ ] Add ShimmerList where appropriate

### ⬜ 13. Integrate Empty States
- [ ] Replace custom empty state widgets with EmptyState factory methods
- [ ] Use EmptyState.noStudents() in students_screen
- [ ] Use EmptyState.noBatches() in batches_screen
- [ ] Use EmptyState.noFees() in fees_screen
- [ ] Use EmptyState.noAttendance() in attendance_screen
- [ ] Use EmptyState.noNotifications() in notifications_screen
- [ ] Use EmptyState.noEvents() in calendar_screen
- [ ] Use EmptyState.noAnnouncements() in announcements_screen

### ⬜ 14. Integrate Error Handling
- [ ] Replace custom error widgets with ErrorDisplay
- [ ] Use ErrorDisplay with onRetry callback in all screens
- [ ] Integrate global error handler where appropriate

### ⬜ 15. Integrate Success Feedback
- [ ] Replace all ScaffoldMessenger.showSnackBar with SuccessSnackbar.show
- [ ] Replace all AlertDialog with ConfirmationDialog for confirmations
- [ ] Use ToastUtils for non-critical feedback

### ⬜ 16. Integrate Form Validation
- [ ] Replace TextField with ValidatedTextField in all forms
- [ ] Add ValidationError display in forms
- [ ] Implement field-level validation

---

## LOW PRIORITY - Additional Features

### ⬜ 17. Implement Reports Export Functionality
- [ ] Implement PDF export for attendance reports
- [ ] Implement CSV export for attendance reports
- [ ] Implement PDF export for fee reports
- [ ] Implement CSV export for fee reports
- [ ] Implement PDF export for performance reports
- [ ] Add export buttons in reports_screen

### ⬜ 18. Implement Notifications Screen
- [ ] Create notifications_screen.dart
- [ ] Integrate with notificationListProvider
- [ ] Add mark as read functionality
- [ ] Add delete functionality
- [ ] Add filter by type

### ⬜ 19. Implement Academy Setup Screen
- [ ] Create academy_setup_screen.dart
- [ ] Add route in app_router.dart
- [ ] Implement academy information form
- [ ] Add image upload for academy logo
- [ ] Integrate with backend API

### ⬜ 20. Complete Offline Support
- [ ] Integrate RequestQueue in API service
- [ ] Add offline data caching
- [ ] Implement sync when back online
- [ ] Add offline indicator in all screens

### ⬜ 21. Complete Image Upload
- [ ] Integrate image_picker in profile screens
- [ ] Implement image cropping
- [ ] Add image upload to backend
- [ ] Display images with cached_network_image

### ⬜ 22. Complete Push Notifications
- [ ] Complete Firebase setup
- [ ] Implement foreground notification handler
- [ ] Implement background notification handler
- [ ] Add notification click handling
- [ ] Test with actual announcements

---

## Testing & Quality

### ⬜ 23. Provider Testing
- [ ] Add comprehensive tests for student_provider
- [ ] Add comprehensive tests for fee_provider
- [ ] Add comprehensive tests for performance_provider
- [ ] Add comprehensive tests for bmi_provider
- [ ] Add comprehensive tests for notification_provider
- [ ] Add comprehensive tests for calendar_provider
- [ ] Add comprehensive tests for announcement_provider
- [ ] Add mock services for testing

### ⬜ 24. Widget Testing
- [ ] Test ErrorDisplay widget
- [ ] Test EmptyState widget variants
- [ ] Test SuccessSnackbar
- [ ] Test ConfirmationDialog
- [ ] Test ValidatedTextField
- [ ] Test Skeleton screens

### ⬜ 25. Integration Testing
- [ ] Test provider integration in migrated screens
- [ ] Test error handling flow
- [ ] Test loading states
- [ ] Test empty states
- [ ] Test success feedback

---

## Notes

- **Priority**: High priority items should be completed first as they affect core functionality
- **Dependencies**: Some items depend on others (e.g., widget integration depends on screen migration)
- **Testing**: Testing items can be done in parallel with implementation

---

## Quick Reference

### Key Files Modified
- `Flutter_Frontend/Badminton/lib/screens/owner/students_screen.dart` ✅
- `Flutter_Frontend/Badminton/lib/screens/owner/fees_screen.dart` ✅

### Key Providers Available
- `studentListProvider` - Student list and CRUD
- `feeListProvider` - Fee list and CRUD
- `performanceListProvider` - Performance records
- `bmiListProvider` - BMI records
- `announcementListProvider` - Announcements
- `calendarEventListProvider` - Calendar events
- `notificationListProvider` - Notifications

### Key Widgets Available
- `ListSkeleton` - Loading state for lists
- `DashboardSkeleton` - Loading state for dashboards
- `ErrorDisplay` - Error state with retry
- `EmptyState` - Empty state with variants
- `SuccessSnackbar` - Success feedback
- `ConfirmationDialog` - Confirmation dialogs
- `ValidatedTextField` - Form field with validation

---

**Total Items**: 35+
**Completed**: 2
**Remaining**: 33+
