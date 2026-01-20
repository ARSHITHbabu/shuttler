# Phase 6 Remaining TODO List

**Last Updated**: 2026-01-XX  
**Status**: Phase 6 is ~85% complete  
**Remaining Work**: Student/Coach Portal Migration + Minor Fixes

---

## Progress Summary

- ✅ **Completed**: Owner Portal (11/11 screens migrated), Phase 6 Components Created (100%), Testing (100%)
- ⏳ **In Progress**: 0 items
- ⬜ **Pending**: 23 screens + 3 loading state fixes

---

## HIGH PRIORITY - Student Portal Screen Migration

### ⬜ 1. Migrate `lib/screens/student/student_attendance_screen.dart`
- [ ] Replace direct API calls with `attendanceProvider` or `studentAttendanceProvider`
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton` or `ProfileSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noAttendance()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/attendance_screen.dart`

### ⬜ 2. Migrate `lib/screens/student/student_fees_screen.dart`
- [ ] Replace direct API calls with `feeByStudentProvider(studentId)`
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noFees()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/fees_screen.dart`

### ⬜ 3. Migrate `lib/screens/student/student_performance_screen.dart`
- [ ] Replace direct API calls with `performanceByStudentProvider(studentId)`
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ProfileSkeleton` (for chart loading)
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noPerformance()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/performance_tracking_screen.dart`

### ⬜ 4. Migrate `lib/screens/student/student_bmi_screen.dart`
- [ ] Replace direct API calls with `bmiByStudentProvider(studentId)`
- [ ] Use `AsyncValue.when` pattern (already partially done)
- [ ] Ensure `ProfileSkeleton` is used consistently (already done ✅)
- [ ] Ensure `ErrorDisplay` is used consistently (already done ✅)
- [ ] Ensure `EmptyState.noBmiRecords()` is used (already done ✅)
- [ ] Replace any remaining `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 1-2 hours (mostly cleanup)
- **Reference**: `lib/screens/owner/bmi_tracking_screen.dart`

### ⬜ 5. Migrate `lib/screens/student/student_announcements_screen.dart`
- [ ] Replace direct API calls with `announcementListProvider` (filtered by audience)
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noAnnouncements()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/announcement_management_screen.dart`

### ⬜ 6. Migrate `lib/screens/student/student_schedule_screen.dart`
- [ ] Replace direct API calls with appropriate schedule provider
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with appropriate `EmptyState` variant
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/session_management_screen.dart`

### ⬜ 7. Migrate `lib/screens/student/student_calendar_screen.dart`
- [ ] Replace direct API calls with `calendarEventsProvider(startDate, endDate)`
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noEvents()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/calendar_view_screen.dart`

### ⬜ 8. Migrate `lib/screens/student/student_profile_screen.dart`
- [ ] Replace direct API calls with `studentByIdProvider(userId)` for reading
- [ ] Use `AsyncValue.when` pattern for loading profile data
- [ ] Replace `LoadingSpinner` with `ProfileSkeleton` (1 instance found)
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Keep using `studentListProvider.notifier` for updates (already done ✅)
- [ ] Ensure `SuccessSnackbar` is used consistently (already done ✅)
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 1-2 hours (mostly cleanup)
- **Reference**: `lib/screens/owner/students_screen.dart` (edit functionality)

### ⬜ 9. Migrate `lib/screens/student/student_settings_screen.dart`
- [ ] Review if any API calls need provider migration
- [ ] Use `AsyncValue.when` pattern if applicable
- [ ] Replace `LoadingSpinner` with appropriate skeleton if needed
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- **Estimated Time**: 1-2 hours
- **Note**: May not need provider migration if it's just settings storage

### ⬜ 10. Migrate `lib/screens/student/student_more_screen.dart`
- [ ] Review if any API calls need provider migration
- [ ] Use `AsyncValue.when` pattern if applicable
- [ ] Replace `LoadingSpinner` with appropriate skeleton if needed
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- **Estimated Time**: 1-2 hours
- **Note**: May not need provider migration if it's just navigation

### ⬜ 11. Review `lib/screens/student/student_home_screen.dart`
- [ ] Verify all providers are used correctly (already uses `studentDashboardProvider` ✅)
- [ ] Verify `DashboardSkeleton` is used (already done ✅)
- [ ] Verify `ErrorDisplay` is used (already done ✅)
- [ ] Ensure `SuccessSnackbar` is used if needed
- **Estimated Time**: 30 minutes (verification only)
- **Status**: Mostly complete, just needs verification

### ⬜ 12. Review `lib/screens/student/profile_completion_screen.dart`
- [ ] Verify provider usage (already uses `studentListProvider.notifier` ✅)
- [ ] Verify `SuccessSnackbar` is used (already done ✅)
- [ ] Ensure proper error handling with `ErrorDisplay` if needed
- **Estimated Time**: 30 minutes (verification only)
- **Status**: Mostly complete, just needs verification

### ⬜ 13. Review `lib/screens/student/student_dashboard.dart`
- [ ] Verify navigation and routing
- [ ] Ensure all child screens use providers (covered by above items)
- **Estimated Time**: 15 minutes (verification only)

---

## HIGH PRIORITY - Coach Portal Screen Migration

### ⬜ 14. Migrate `lib/screens/coach/coach_attendance_screen.dart`
- [ ] Replace direct API calls with `attendanceProvider` or `coachAttendanceProvider`
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noAttendance()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/attendance_screen.dart`

### ⬜ 15. Migrate `lib/screens/coach/coach_batches_screen.dart`
- [ ] Replace direct API calls with `batchListProvider` (filtered by coach)
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noBatches()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/batches_screen.dart`

### ⬜ 16. Migrate `lib/screens/coach/coach_schedule_screen.dart`
- [ ] Replace direct API calls with appropriate schedule provider
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with appropriate `EmptyState` variant
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/session_management_screen.dart`

### ⬜ 17. Migrate `lib/screens/coach/coach_announcements_screen.dart`
- [ ] Replace direct API calls with `announcementListProvider` (filtered by audience)
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noAnnouncements()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/announcement_management_screen.dart`

### ⬜ 18. Migrate `lib/screens/coach/coach_calendar_screen.dart`
- [ ] Replace direct API calls with `calendarEventsProvider(startDate, endDate)`
- [ ] Use `AsyncValue.when` pattern instead of `FutureBuilder`
- [ ] Replace `LoadingSpinner` with `ListSkeleton`
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace custom empty state with `EmptyState.noEvents()`
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/calendar_view_screen.dart`

### ⬜ 19. Migrate `lib/screens/coach/coach_profile_screen.dart`
- [ ] Replace direct API calls with `coachByIdProvider(coachId)` for reading
- [ ] Use `AsyncValue.when` pattern for loading profile data
- [ ] Replace `LoadingSpinner` with `ProfileSkeleton` (3 instances found)
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace direct `coachService.updateCoach` with `coachListProvider.notifier` if available
- [ ] Ensure `SuccessSnackbar` is used consistently (already done ✅)
- [ ] Add refresh functionality using provider invalidation
- **Estimated Time**: 2-3 hours
- **Reference**: `lib/screens/owner/coaches_screen.dart` (edit functionality)

### ⬜ 20. Review `lib/screens/coach/coach_home_screen.dart`
- [ ] Verify all providers are used correctly (already uses `coachStatsProvider` ✅)
- [ ] Verify `GridSkeleton` is used (already done ✅)
- [ ] Verify `ErrorDisplay` is used (already done ✅)
- [ ] Ensure `SuccessSnackbar` is used if needed
- **Estimated Time**: 30 minutes (verification only)
- **Status**: Mostly complete, just needs verification

### ⬜ 21. Review `lib/screens/coach/coach_settings_screen.dart`
- [ ] Review if any API calls need provider migration
- [ ] Use `AsyncValue.when` pattern if applicable
- [ ] Replace `LoadingSpinner` with appropriate skeleton if needed
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- **Estimated Time**: 1-2 hours
- **Note**: May not need provider migration if it's just settings storage

### ⬜ 22. Review `lib/screens/coach/coach_more_screen.dart`
- [ ] Review if any API calls need provider migration
- [ ] Use `AsyncValue.when` pattern if applicable
- [ ] Replace `LoadingSpinner` with appropriate skeleton if needed
- [ ] Replace custom error handling with `ErrorDisplay` widget
- [ ] Replace `ScaffoldMessenger.showSnackBar` with `SuccessSnackbar.show`
- **Estimated Time**: 1-2 hours
- **Note**: May not need provider migration if it's just navigation

### ⬜ 23. Review `lib/screens/coach/coach_dashboard.dart`
- [ ] Verify navigation and routing
- [ ] Ensure all child screens use providers (covered by above items)
- **Estimated Time**: 15 minutes (verification only)

---

## MEDIUM PRIORITY - Loading State Fixes

### ⬜ 24. Fix `lib/screens/owner/home_screen.dart`
- [ ] Replace all `LoadingSpinner` instances with `DashboardSkeleton`
- [ ] Verify `AsyncValue.when` pattern is used correctly
- [ ] Ensure consistent loading states throughout the screen
- **Estimated Time**: 1 hour
- **Current Status**: Uses `DashboardSkeleton` in some places, but may have `LoadingSpinner` in others

### ⬜ 25. Fix `lib/screens/coach/coach_profile_screen.dart`
- [ ] Replace 3 instances of `LoadingSpinner` with `ProfileSkeleton`
- [ ] Verify loading states are consistent
- **Estimated Time**: 30 minutes
- **Current Status**: Already uses `ProfileSkeleton` in one place, but has 3 `LoadingSpinner` instances

### ⬜ 26. Fix `lib/screens/student/student_profile_screen.dart`
- [ ] Replace 1 instance of `LoadingSpinner` with `ProfileSkeleton`
- [ ] Verify loading states are consistent
- **Estimated Time**: 15 minutes
- **Current Status**: Mostly uses providers, but has 1 `LoadingSpinner` instance

---

## LOW PRIORITY - Optional Enhancements

### ⬜ 27. Consider ValidatedTextField Migration
- [ ] Evaluate if `ValidatedTextField` provides better functionality than `CustomTextField` with validators
- [ ] If yes, migrate key forms to use `ValidatedTextField`
- [ ] If no, document that `CustomTextField` with validators is the preferred approach
- **Estimated Time**: 2-4 hours (if migration is decided)
- **Status**: Optional - `CustomTextField` with validators may be sufficient

### ⬜ 28. PDF Export Implementation
- [ ] Add `pdf: ^3.10.0` to `pubspec.yaml`
- [ ] Uncomment PDF export code in `reports_screen.dart`
- [ ] Test PDF generation for attendance, fee, and performance reports
- **Estimated Time**: 2-3 hours
- **Status**: Code structure ready, just needs dependency

### ⬜ 29. Image Cropping Enhancement
- [ ] Add `image_cropper: ^5.0.0` to `pubspec.yaml`
- [ ] Integrate image cropping in `ProfileImagePicker` widget
- [ ] Test image cropping flow
- **Estimated Time**: 2-3 hours
- **Status**: Optional enhancement

---

## Migration Pattern Reference

### Standard Migration Steps (for each screen):

1. **Import Required Providers**:
   ```dart
   import '../../providers/student_provider.dart';
   import '../../providers/fee_provider.dart';
   // etc.
   ```

2. **Import Phase 6 Components**:
   ```dart
   import '../../widgets/common/skeleton_screen.dart';
   import '../../widgets/common/error_widget.dart';
   import '../../widgets/common/success_snackbar.dart';
   import '../../widgets/common/confirmation_dialog.dart';
   ```

3. **Replace Direct API Calls with Providers**:
   ```dart
   // OLD:
   final apiService = ref.read(apiServiceProvider);
   final response = await apiService.get('/api/students/$userId/fees');
   final fees = List<Fee>.from(response.data.map((x) => Fee.fromJson(x)));
   
   // NEW:
   final feesAsync = ref.watch(feeByStudentProvider(userId));
   ```

4. **Replace FutureBuilder with AsyncValue.when**:
   ```dart
   // OLD:
   FutureBuilder<List<Fee>>(
     future: _loadFees(),
     builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return LoadingSpinner();
       }
       if (snapshot.hasError) {
         return Text('Error: ${snapshot.error}');
       }
       // ...
     },
   )
   
   // NEW:
   feesAsync.when(
     loading: () => const ListSkeleton(itemCount: 5),
     error: (error, stack) => ErrorDisplay(
       message: 'Failed to load fees: ${error.toString()}',
       onRetry: () => ref.invalidate(feeByStudentProvider(userId)),
     ),
     data: (fees) => _buildFeesList(fees),
   )
   ```

5. **Replace SnackBar with SuccessSnackbar**:
   ```dart
   // OLD:
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Success!')),
   );
   
   // NEW:
   SuccessSnackbar.show(context, 'Success!');
   ```

6. **Replace AlertDialog with ConfirmationDialog**:
   ```dart
   // OLD:
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: Text('Delete?'),
       actions: [...],
     ),
   );
   
   // NEW:
   final confirmed = await ConfirmationDialog.showDelete(
     context,
     'Student',
   );
   if (confirmed) {
     // Delete logic
   }
   ```

7. **Add Refresh Functionality**:
   ```dart
   RefreshIndicator(
     onRefresh: () async {
       ref.invalidate(feeByStudentProvider(userId));
     },
     child: ListView(...),
   )
   ```

---

## Key Providers Available

### Student-Related Providers:
- `studentListProvider` - All students
- `studentByIdProvider(int id)` - Single student
- `studentSearchProvider(String query)` - Search students
- `studentByBatchProvider(int batchId)` - Students in batch
- `studentDashboardProvider(int userId)` - Student dashboard data

### Fee-Related Providers:
- `feeListProvider({String? status})` - All fees (with optional status filter)
- `feeByStudentProvider(int studentId)` - Student's fees
- `feeStatsProvider` - Fee statistics

### Performance-Related Providers:
- `performanceByStudentProvider(int studentId)` - Student's performance records
- `performanceTrendProvider(int studentId, DateTime start, DateTime end)` - Performance trends

### BMI-Related Providers:
- `bmiByStudentProvider(int studentId)` - Student's BMI records
- `latestBmiProvider(int studentId)` - Latest BMI record
- `bmiTrendProvider(int studentId)` - BMI trends

### Other Providers:
- `announcementListProvider` - All announcements
- `calendarEventsProvider(DateTime start, DateTime end)` - Calendar events
- `notificationListProvider(int userId, String userType)` - User notifications
- `attendanceProvider` - Attendance records
- `batchListProvider` - All batches
- `coachListProvider` - All coaches
- `coachStatsProvider(int coachId)` - Coach statistics
- `coachTodaySessionsProvider(int coachId)` - Coach's today sessions

---

## Key Widgets Available

### Loading States:
- `ListSkeleton(itemCount: 5)` - For list screens
- `DashboardSkeleton()` - For dashboard screens
- `ProfileSkeleton()` - For profile screens
- `GridSkeleton(itemCount: 4, crossAxisCount: 2)` - For grid layouts

### Error Handling:
- `ErrorDisplay(message: 'Error message', onRetry: () {...})` - Error screen with retry

### Empty States:
- `EmptyState.noStudents(onAdd: () {...})` - No students
- `EmptyState.noBatches(onCreate: () {...})` - No batches
- `EmptyState.noFees()` - No fees
- `EmptyState.noAttendance(onMark: () {...})` - No attendance
- `EmptyState.noPerformance()` - No performance records
- `EmptyState.noBmiRecords()` - No BMI records
- `EmptyState.noAnnouncements(onCreate: () {...})` - No announcements
- `EmptyState.noEvents(onAdd: () {...})` - No events
- `EmptyState.noNotifications()` - No notifications

### Success Feedback:
- `SuccessSnackbar.show(context, 'Success message')` - Success message
- `SuccessSnackbar.showError(context, 'Error message')` - Error message
- `SuccessSnackbar.showInfo(context, 'Info message')` - Info message
- `ConfirmationDialog.showDelete(context, 'Item name')` - Delete confirmation
- `ConfirmationDialog.show(context, title: 'Title', message: 'Message')` - Generic confirmation

---

## Estimated Timeline

### High Priority Items (Student/Coach Portal Migration):
- **Student Portal**: 13 screens × 2-3 hours = **26-39 hours** (~1-2 weeks)
- **Coach Portal**: 10 screens × 2-3 hours = **20-30 hours** (~1-1.5 weeks)
- **Total**: **46-69 hours** (~2-3.5 weeks)

### Medium Priority Items (Loading State Fixes):
- **3 screens** × 15-60 minutes = **1-3 hours** (~0.5 days)

### Low Priority Items (Optional):
- **ValidatedTextField**: 2-4 hours (if decided)
- **PDF Export**: 2-3 hours
- **Image Cropping**: 2-3 hours
- **Total**: **6-10 hours** (~1-1.5 days)

### Grand Total:
- **High Priority**: 46-69 hours (~2-3.5 weeks)
- **Medium Priority**: 1-3 hours (~0.5 days)
- **Low Priority**: 6-10 hours (~1-1.5 days)
- **Overall**: **53-82 hours** (~2.5-4 weeks)

---

## Priority Order

### Week 1: Student Portal Core Screens
1. student_attendance_screen.dart
2. student_fees_screen.dart
3. student_performance_screen.dart
4. student_bmi_screen.dart (cleanup)
5. student_announcements_screen.dart

### Week 2: Student Portal Remaining + Coach Portal Core
6. student_schedule_screen.dart
7. student_calendar_screen.dart
8. student_profile_screen.dart (cleanup)
9. coach_attendance_screen.dart
10. coach_batches_screen.dart

### Week 3: Coach Portal Remaining + Fixes
11. coach_schedule_screen.dart
12. coach_announcements_screen.dart
13. coach_calendar_screen.dart
14. coach_profile_screen.dart
15. Loading state fixes (3 screens)

### Week 4: Verification + Optional
16. Review and verify all screens
17. Optional enhancements (if time permits)

---

## Notes

- **Reference Screens**: Use owner portal screens as reference since they're fully migrated
- **Testing**: Test each migrated screen thoroughly before moving to the next
- **Incremental**: Migrate one screen at a time to avoid breaking changes
- **Provider Pattern**: Always use `AsyncValue.when` pattern for consistency
- **Error Handling**: Always provide `onRetry` callback in `ErrorDisplay`
- **Success Feedback**: Use `SuccessSnackbar` for all user feedback
- **Refresh**: Add `RefreshIndicator` for pull-to-refresh functionality

---

**Total Items**: 29  
**High Priority**: 23 (Student/Coach Portal Migration)  
**Medium Priority**: 3 (Loading State Fixes)  
**Low Priority**: 3 (Optional Enhancements)  
**Estimated Completion**: 2.5-4 weeks
