# Screen Migration Guide: Using Providers Instead of Direct Service Calls

This guide explains how to update existing screens to use Riverpod providers instead of direct service calls.

## Overview

Previously, screens were making direct API calls or using services directly. Now, we have Riverpod providers that handle state management, caching, and error handling automatically.

## Benefits of Using Providers

1. **Automatic State Management**: Providers handle loading, error, and data states
2. **Caching**: Data is cached and shared across widgets
3. **Auto-refresh**: Related providers are invalidated when data changes
4. **Error Handling**: Centralized error handling through providers
5. **Testing**: Easier to test with mock providers

## Migration Steps

### Step 1: Identify Direct Service Calls

Look for patterns like:
```dart
final apiService = ref.read(apiServiceProvider);
final response = await apiService.get('/api/students');
```

Or:
```dart
final studentService = ref.read(studentServiceProvider);
final students = await studentService.getStudents();
```

### Step 2: Replace with Provider

Instead of:
```dart
class _MyScreenState extends ConsumerState<MyScreen> {
  List<Student> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final studentService = ref.read(studentServiceProvider);
      _students = await studentService.getStudents();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

Use:
```dart
class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentListProvider);

    return studentsAsync.when(
      data: (students) => ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) => StudentCard(student: students[index]),
      ),
      loading: () => const LoadingSpinner(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

### Step 3: Use Provider Methods for Mutations

For create/update/delete operations, use provider methods:

```dart
// Instead of:
final studentService = ref.read(studentServiceProvider);
await studentService.createStudent(data);

// Use:
final studentList = ref.read(studentListProvider.notifier);
await studentList.createStudent(data);
// Provider automatically refreshes related data
```

## Example: Student BMI Screen

### Before (Direct API Call):
```dart
Future<void> _loadData() async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.get('/api/students/$userId/bmi');
  _bmiRecords = List<Map<String, dynamic>>.from(response.data['records'] ?? []);
}
```

### After (Using Provider):
```dart
@override
Widget build(BuildContext context) {
  final userId = _getUserId(); // Get from auth provider
  final bmiAsync = ref.watch(bmiByStudentProvider(userId));

  return bmiAsync.when(
    data: (records) => BMIRecordsList(records: records),
    loading: () => const DashboardSkeleton(),
    error: (error, stack) => ErrorWidget(error: error),
  );
}
```

## Available Providers

### Student Providers
- `studentListProvider` - List all students
- `studentByIdProvider(id)` - Get student by ID
- `studentSearchProvider(query)` - Search students
- `studentByBatchProvider(batchId)` - Filter by batch
- `studentStatsProvider` - Student statistics

### Fee Providers
- `feeListProvider` - List all fees
- `feeByStudentProvider(studentId)` - Student fee history
- `feeStatsProvider` - Fee statistics
- `pendingFeesProvider` - Pending fees
- `overdueFeesProvider` - Overdue fees

### Performance Providers
- `performanceByStudentProvider(studentId)` - Student performance
- `performanceTrendProvider(studentId, start, end)` - Trend data
- `averagePerformanceProvider(studentId)` - Average ratings

### BMI Providers
- `bmiByStudentProvider(studentId)` - Student BMI history
- `latestBmiProvider(studentId)` - Latest BMI record
- `bmiTrendProvider(studentId)` - BMI trend data

### Notification Providers
- `notificationListProvider(userId, userType)` - User notifications
- `unreadCountProvider(userId, userType)` - Unread count
- `notificationByTypeProvider(userId, userType, type)` - Filter by type

### Calendar Providers
- `calendarEventsProvider(start, end)` - Events in date range
- `calendarEventByDateProvider(date)` - Events for specific date
- `calendarEventByTypeProvider(eventType)` - Filter by type

### Announcement Providers
- `announcementListProvider` - All announcements
- `announcementByAudienceProvider(audience)` - Filter by audience
- `announcementByPriorityProvider(priority)` - Filter by priority

## Error Handling

Providers automatically handle errors. Use `AsyncValue.when()` to handle states:

```dart
final dataAsync = ref.watch(someProvider);

dataAsync.when(
  data: (data) => DataWidget(data: data),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error: error),
);
```

## Refresh Data

To manually refresh provider data:

```dart
// Refresh specific provider
ref.invalidate(studentListProvider);

// Or use refresh method
await ref.refresh(studentListProvider.future);
```

## Best Practices

1. **Use `ref.watch()`** for data that should rebuild when it changes
2. **Use `ref.read()`** for one-time reads or in callbacks
3. **Use `AsyncValue.when()`** to handle all states (loading, data, error)
4. **Use skeleton screens** for loading states instead of spinners
5. **Use empty states** when data is empty
6. **Invalidate related providers** after mutations

## Common Patterns

### Pattern 1: List Screen with Search
```dart
final searchQuery = useState('');
final studentsAsync = ref.watch(
  searchQuery.value.isEmpty
    ? studentListProvider
    : studentSearchProvider(searchQuery.value),
);
```

### Pattern 2: Detail Screen
```dart
final studentId = 1;
final studentAsync = ref.watch(studentByIdProvider(studentId));
```

### Pattern 3: Form Submission
```dart
Future<void> _submitForm() async {
  try {
    final studentList = ref.read(studentListProvider.notifier);
    await studentList.createStudent(formData);
    // Success - provider auto-refreshes
    Navigator.pop(context);
  } catch (e) {
    // Error handling
    ErrorDialog.show(context, e);
  }
}
```

## Testing

When testing screens that use providers, override providers with mock data:

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      studentListProvider.overrideWithValue(
        AsyncValue.data([mockStudent1, mockStudent2]),
      ),
    ],
    child: MyScreen(),
  ),
);
```

## Migration Checklist

- [ ] Identify all direct service calls in the screen
- [ ] Replace with appropriate provider
- [ ] Update build method to use `AsyncValue.when()`
- [ ] Replace loading states with skeleton screens
- [ ] Add empty states for empty data
- [ ] Update error handling to use ErrorWidget
- [ ] Test the updated screen
- [ ] Remove unused state variables and methods

## Need Help?

Refer to existing provider implementations:
- `lib/providers/student_provider.dart`
- `lib/providers/fee_provider.dart`
- `lib/providers/batch_provider.dart` (existing example)
