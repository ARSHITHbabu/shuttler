# Flutter Frontend Development Plan - Badminton Academy Management App

## Project Overview

**Goal**: Build a complete Flutter mobile application for the Badminton Academy Management System, using the existing React UI as a reference and connecting to the existing FastAPI backend.

**Current State**:
- ✅ Complete React reference UI with all features (`Reference/Badminton_Academy_Management_App/`)
- ✅ Working FastAPI backend with SQLite database (`Reference/sample/`)
- ❌ Flutter app is currently just boilerplate (`Flutter_Frontend/Badminton/`)

---

## Architecture Overview

### Flutter App Structure
```
Badminton/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   ├── theme.dart            # Dark neumorphic theme
│   │   ├── routes.dart           # Route configuration
│   │   └── constants.dart        # API URLs, app constants
│   ├── models/                   # Data models (11 entities)
│   │   ├── student.dart
│   │   ├── coach.dart
│   │   ├── batch.dart
│   │   ├── attendance.dart
│   │   ├── fee.dart
│   │   ├── performance.dart
│   │   ├── bmi_record.dart
│   │   └── user.dart
│   ├── services/                 # Business logic layer
│   │   ├── api_service.dart      # HTTP client wrapper
│   │   ├── auth_service.dart     # Authentication
│   │   ├── student_service.dart  # Student CRUD
│   │   ├── batch_service.dart    # Batch CRUD
│   │   ├── attendance_service.dart
│   │   ├── fee_service.dart
│   │   └── storage_service.dart  # Local storage
│   ├── providers/                # State management (Riverpod)
│   │   ├── auth_provider.dart
│   │   ├── student_provider.dart
│   │   ├── batch_provider.dart
│   │   └── dashboard_provider.dart
│   ├── screens/                  # UI screens
│   │   ├── auth/
│   │   │   ├── role_selection_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── academy_setup_screen.dart
│   │   ├── owner/
│   │   │   ├── owner_dashboard.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── batches_screen.dart
│   │   │   ├── attendance_screen.dart
│   │   │   ├── reports_screen.dart
│   │   │   ├── more_screen.dart
│   │   │   ├── student_management_screen.dart
│   │   │   ├── coach_management_screen.dart
│   │   │   ├── fee_management_screen.dart
│   │   │   ├── performance_tracking_screen.dart
│   │   │   ├── bmi_tracking_screen.dart
│   │   │   ├── session_management_screen.dart
│   │   │   ├── announcement_management_screen.dart
│   │   │   └── calendar_view_screen.dart
│   │   ├── coach/                # Future implementation
│   │   └── student/              # Future implementation
│   └── widgets/                  # Reusable UI components
│       ├── common/
│       │   ├── neumorphic_button.dart
│       │   ├── neumorphic_card.dart
│       │   ├── neumorphic_input.dart
│       │   ├── custom_app_bar.dart
│       │   ├── loading_indicator.dart
│       │   └── empty_state.dart
│       ├── statistics_card.dart
│       ├── batch_card.dart
│       ├── student_card.dart
│       └── bottom_nav_bar.dart
```

---

## Implementation Plan

### Phase 1: Project Foundation

#### 1.1 Dependencies Setup
Add to `pubspec.yaml`:
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0

  # HTTP Client
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1

  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # Navigation
  go_router: ^13.0.0

  # UI Components
  flutter_svg: ^2.0.9
  google_fonts: ^6.1.0
  intl: ^0.19.0

  # Date & Time
  table_calendar: ^3.0.9

  # Charts
  fl_chart: ^0.66.0

  # Utilities
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
```

#### 1.2 Theme Configuration
Create dark neumorphic theme matching React reference:
- Background colors: #1a1a1a, #242424, #2a2a2a
- Text colors: #e8e8e8 (primary), #a0a0a0 (secondary)
- Neumorphic shadows (inset and outset)
- Card styles with rounded corners
- Button styles

**File**: [lib/config/theme.dart](Flutter_Frontend/Badminton/lib/config/theme.dart)

#### 1.3 Data Models
Create Dart models for all 11 backend entities:
- Student, Coach, Batch, BatchStudent
- Attendance, CoachAttendance
- Fee, Performance, BMIRecord
- Enquiry, Schedule

Use `freezed` for immutable models with JSON serialization.

**Files**: [lib/models/](Flutter_Frontend/Badminton/lib/models/)

#### 1.4 API Service Layer
Create base API service using Dio:
- Base URL configuration
- Request/response interceptors
- Error handling
- Authentication token management
- Logging

**File**: [lib/services/api_service.dart](Flutter_Frontend/Badminton/lib/services/api_service.dart)

#### 1.5 Authentication Service
Implement authentication matching backend endpoints:
- Login for all roles (owner/coach/student)
- Token storage (flutter_secure_storage)
- Session management
- Auto-logout on token expiry

**File**: [lib/services/auth_service.dart](Flutter_Frontend/Badminton/lib/services/auth_service.dart)

---

### Phase 2: Authentication Flow

#### 2.1 Role Selection Screen
Replicate React's role selection with 3 cards:
- Owner
- Coach
- Student

Navigate to login/signup after selection.

**Reference**: React component at `src/app/components/RoleSelection.tsx`
**File**: [lib/screens/auth/role_selection_screen.dart](Flutter_Frontend/Badminton/lib/screens/auth/role_selection_screen.dart)

#### 2.2 Login/Signup Screen
Create combined login/signup screen:
- Tab switching between login/signup
- Email/phone and password fields
- Role-specific validation
- Loading states
- Error messages

**Reference**: React component at `src/app/components/auth/LoginSignup.tsx`
**File**: [lib/screens/auth/login_screen.dart](Flutter_Frontend/Badminton/lib/screens/auth/login_screen.dart)

#### 2.3 Academy Setup Screen (Owner Only)
3-step wizard for first-time owner setup:
- Step 1: Academy details (name, location)
- Step 2: Contact information
- Step 3: Operating hours and facilities

**Reference**: React component at `src/app/components/owner/AcademySetup.tsx`
**File**: [lib/screens/auth/academy_setup_screen.dart](Flutter_Frontend/Badminton/lib/screens/auth/academy_setup_screen.dart)

#### 2.4 Navigation Setup
Configure go_router with:
- Public routes (role selection, login)
- Protected routes (dashboards)
- Role-based routing
- Deep linking support

**File**: [lib/config/routes.dart](Flutter_Frontend/Badminton/lib/config/routes.dart)

---

### Phase 3: Owner Dashboard - Core Screens

#### 3.1 Owner Dashboard Container
Bottom navigation with 5 tabs:
- Home
- Batches
- Attendance
- Reports
- More

**Reference**: React component at `src/app/components/owner/OwnerDashboard.tsx`
**File**: [lib/screens/owner/owner_dashboard.dart](Flutter_Frontend/Badminton/lib/screens/owner/owner_dashboard.dart)

#### 3.2 Home Screen
Dashboard overview with:
- 4 statistics cards (Students, Coaches, Batches, Pending Fees)
- Today's insights section (attendance rate)
- Upcoming batches list
- Quick action buttons (Add Student, Add Coach)

**Reference**: `src/app/components/owner/HomeScreen.tsx` (lines 1-400)
**File**: [lib/screens/owner/home_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/home_screen.dart)

**API Endpoints**:
- GET `/api/students/` - Count total students
- GET `/api/coaches/` - Count total coaches
- GET `/api/batches/` - Count active batches
- GET `/api/fees/` - Calculate pending fees
- GET `/api/attendance/` - Calculate today's attendance rate

#### 3.3 Batches Screen
List all batches with:
- Batch cards showing timing, days, capacity
- Add new batch button
- Edit/delete batch actions
- View enrolled students
- Filter by status

**Reference**: `src/app/components/owner/BatchesScreen.tsx`
**File**: [lib/screens/owner/batches_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/batches_screen.dart)

**API Endpoints**:
- GET `/api/batches/` - List all batches
- POST `/api/batches/` - Create new batch
- PUT `/api/batches/{id}` - Update batch
- DELETE `/api/batches/{id}` - Delete batch
- GET `/api/batches/{id}/students` - Get enrolled students

#### 3.4 Attendance Screen
Dual-mode attendance marking:
- Toggle: Student Attendance / Coach Attendance
- Date picker for selecting date
- Batch selector (for student attendance)
- Student/Coach list with checkboxes
- Remarks field for each entry
- Summary statistics (Present/Absent/Percentage)
- View history button

**Reference**: `src/app/components/owner/AttendanceScreen.tsx`
**File**: [lib/screens/owner/attendance_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/attendance_screen.dart)

**API Endpoints**:
- GET `/api/attendance/?date={date}&batch_id={id}` - Get attendance records
- POST `/api/attendance/` - Mark student attendance
- POST `/api/coach_attendance/` - Mark coach attendance
- GET `/api/students/?batch_id={id}` - Get students by batch
- GET `/api/coaches/` - Get all coaches

#### 3.5 Reports Screen
Generate and view reports:
- Report type selector (Attendance, Fee, Performance)
- Date range picker
- Batch/Student filter (optional)
- Generate button
- Previously generated reports list
- Export functionality (PDF/CSV)

**Reference**: `src/app/components/owner/ReportsScreen.tsx`
**File**: [lib/screens/owner/reports_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/reports_screen.dart)

**API Endpoints**:
- GET `/api/attendance/?start_date={date}&end_date={date}` - Attendance report data
- GET `/api/fees/?start_date={date}&end_date={date}` - Fee report data
- GET `/api/performance/?student_id={id}` - Performance report data

#### 3.6 More Screen
Settings and additional features:
- **Account Section**: Profile, Academy Details
- **Management Section**: Sessions, Announcements, Calendar
- **App Section**: Settings, Logout

**Reference**: `src/app/components/owner/MoreScreen.tsx`
**File**: [lib/screens/owner/more_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/more_screen.dart)

---

### Phase 4: Management Screens

#### 4.1 Student Management
Complete CRUD for students:
- List view with search and filter
- Student card showing name, batch, fee status
- Add student form (name, guardian, contact, batch assignment)
- Edit student details
- View student profile (detailed view)
- Navigate to Performance Tracking
- Navigate to BMI Tracking
- Navigate to Fee Management

**Reference**: `src/app/components/owner/StudentManagement.tsx`
**File**: [lib/screens/owner/student_management_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/student_management_screen.dart)

**API Endpoints**:
- GET `/api/students/` - List students
- GET `/api/students/{id}` - Get student details
- POST `/api/students/` - Create student
- PUT `/api/students/{id}` - Update student
- DELETE `/api/students/{id}` - Delete student
- POST `/api/batch-students/` - Assign student to batch

#### 4.2 Coach Management
Complete CRUD for coaches:
- List view with specialization
- Add coach form (name, contact, specialization, batch assignment)
- Edit coach details
- Toggle active/inactive status
- View assigned batches

**Reference**: `src/app/components/owner/CoachManagement.tsx`
**File**: [lib/screens/owner/coach_management_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/coach_management_screen.dart)

**API Endpoints**:
- GET `/api/coaches/` - List coaches
- GET `/api/coaches/{id}` - Get coach details
- POST `/api/coaches/` - Create coach
- PUT `/api/coaches/{id}` - Update coach
- DELETE `/api/coaches/{id}` - Delete coach

#### 4.3 Fee Management
Track and collect fees:
- Student list with fee status
- Filter by status (Paid/Pending/Overdue)
- Record payment dialog
- Payment method selection
- Due date management
- Individual student fee history
- Send payment reminder

**Reference**: `src/app/components/owner/FeeManagement.tsx`
**File**: [lib/screens/owner/fee_management_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/fee_management_screen.dart)

**API Endpoints**:
- GET `/api/fees/` - List all fees
- GET `/api/fees/?student_id={id}` - Student fee history
- POST `/api/fees/` - Record payment
- PUT `/api/fees/{id}` - Update fee record

#### 4.4 Performance Tracking
Track student skill development:
- Student selector
- Skill categories (Serve, Smash, Footwork, Defense, Stamina)
- 5-star rating system for each skill
- Date-based records
- Progress chart
- Comments/notes section

**Reference**: `src/app/components/owner/PerformanceTracking.tsx`
**File**: [lib/screens/owner/performance_tracking_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/performance_tracking_screen.dart)

**API Endpoints**:
- GET `/api/performance/?student_id={id}` - Get performance records
- POST `/api/performance/` - Create performance record
- PUT `/api/performance/{id}` - Update performance record

#### 4.5 BMI Tracking
Track student health metrics:
- Student selector
- Height, Weight, BMI input
- Date selection
- Historical records table
- BMI trend chart
- Health status indicator

**Reference**: `src/app/components/owner/BMITracking.tsx`
**File**: [lib/screens/owner/bmi_tracking_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/bmi_tracking_screen.dart)

**API Endpoints**:
- GET `/api/bmi-records/?student_id={id}` - Get BMI records
- POST `/api/bmi-records/` - Create BMI record

#### 4.6 Session Management
Schedule special sessions:
- Session type (Practice/Tournament/Camp)
- Date and time selection
- Duration
- Batch/student selection
- Location
- Coach assignment
- Session list with upcoming/past tabs

**Reference**: `src/app/components/owner/SessionManagement.tsx`
**File**: [lib/screens/owner/session_management_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/session_management_screen.dart)

**API Endpoints**:
- GET `/api/schedules/` - List sessions
- POST `/api/schedules/` - Create session
- PUT `/api/schedules/{id}` - Update session
- DELETE `/api/schedules/{id}` - Delete session

#### 4.7 Announcement Management
Create and send announcements:
- Title and message
- Target audience (All/Students/Coaches)
- Priority level (Normal/High/Urgent)
- Scheduled send time (optional)
- Announcement history list
- Delete announcement

**Reference**: `src/app/components/owner/AnnouncementManagement.tsx`
**File**: [lib/screens/owner/announcement_management_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/announcement_management_screen.dart)

**Note**: Backend doesn't have announcement endpoint yet - may need to add or use local notifications initially.

#### 4.8 Calendar View
Visual calendar for events:
- Month view calendar
- Mark holidays
- Add tournament dates
- Add in-house events
- Color-coded events (Holiday: red, Tournament: blue, Event: green)
- Event detail view
- Date range selection

**Reference**: `src/app/components/owner/CalendarView.tsx`
**File**: [lib/screens/owner/calendar_view_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/calendar_view_screen.dart)

Use `table_calendar` package for calendar widget.

---

### Phase 5: Reusable UI Components

#### 5.1 Neumorphic Components
Create custom widgets matching React's neumorphic design:

**NeumorphicButton**: [lib/widgets/common/neumorphic_button.dart](Flutter_Frontend/Badminton/lib/widgets/common/neumorphic_button.dart)
- Outset shadow effect
- Press animation
- Loading state
- Icon support

**NeumorphicCard**: [lib/widgets/common/neumorphic_card.dart](Flutter_Frontend/Badminton/lib/widgets/common/neumorphic_card.dart)
- Subtle shadows
- Rounded corners
- Padding variants

**NeumorphicInput**: [lib/widgets/common/neumorphic_input.dart](Flutter_Frontend/Badminton/lib/widgets/common/neumorphic_input.dart)
- Inset shadow effect
- Label and hint text
- Validation states
- Prefix/suffix icons

#### 5.2 Domain Components

**StatisticsCard**: [lib/widgets/statistics_card.dart](Flutter_Frontend/Badminton/lib/widgets/statistics_card.dart)
- Icon, label, value display
- Trend indicator (optional)
- Tap action

**BatchCard**: [lib/widgets/batch_card.dart](Flutter_Frontend/Badminton/lib/widgets/batch_card.dart)
- Batch name, timing, days
- Coach name
- Enrollment count/capacity
- Status badge

**StudentCard**: [lib/widgets/student_card.dart](Flutter_Frontend/Badminton/lib/widgets/student_card.dart)
- Student photo, name
- Batch name
- Fee status badge
- Tap to view details

**BottomNavBar**: [lib/widgets/bottom_nav_bar.dart](Flutter_Frontend/Badminton/lib/widgets/bottom_nav_bar.dart)
- 5 tabs with icons
- Active state styling
- Badge support (for notifications)

#### 5.3 Common Components

**CustomAppBar**: [lib/widgets/common/custom_app_bar.dart](Flutter_Frontend/Badminton/lib/widgets/common/custom_app_bar.dart)
- Back button
- Title
- Actions (search, filter, add)

**LoadingIndicator**: [lib/widgets/common/loading_indicator.dart](Flutter_Frontend/Badminton/lib/widgets/common/loading_indicator.dart)
- Circular progress indicator
- Overlay with backdrop

**EmptyState**: [lib/widgets/common/empty_state.dart](Flutter_Frontend/Badminton/lib/widgets/common/empty_state.dart)
- Icon, message, action button
- Used when lists are empty

---

### Phase 6: State Management

#### 6.1 Provider Setup
Use Riverpod for state management:

**AuthProvider**: [lib/providers/auth_provider.dart](Flutter_Frontend/Badminton/lib/providers/auth_provider.dart)
- User authentication state
- Login/logout methods
- Token management
- Role information

**StudentProvider**: [lib/providers/student_provider.dart](Flutter_Frontend/Badminton/lib/providers/student_provider.dart)
- Student list state
- CRUD operations
- Search and filter
- Loading states

**BatchProvider**: [lib/providers/batch_provider.dart](Flutter_Frontend/Badminton/lib/providers/batch_provider.dart)
- Batch list state
- CRUD operations
- Enrolled students

**DashboardProvider**: [lib/providers/dashboard_provider.dart](Flutter_Frontend/Badminton/lib/providers/dashboard_provider.dart)
- Dashboard statistics
- Today's insights
- Upcoming batches

Create similar providers for:
- Attendance
- Fees
- Performance
- BMI
- Sessions
- Calendar events

---

### Phase 7: Error Handling & Polish

#### 7.1 Error Handling
- Network error dialogs
- Validation errors
- API error messages
- Retry mechanisms
- Offline mode detection

#### 7.2 Loading States
- Shimmer loading for lists
- Progress indicators for actions
- Skeleton screens for dashboards

#### 7.3 Empty States
- "No students yet" with add button
- "No batches created"
- "No attendance records"

#### 7.4 Success Feedback
- Snackbars for successful actions
- Confirmation dialogs for delete operations
- Animation feedback for button presses

---

## Backend Integration

### API Base URL Configuration
**Development**: `http://localhost:8000`
**Production**: TBD (deploy FastAPI to cloud)

Update [lib/config/constants.dart](Flutter_Frontend/Badminton/lib/config/constants.dart) with API URL.

### Backend Startup
To run the existing FastAPI backend:
```bash
cd Reference/sample
python main.py
```
Server runs on http://localhost:8000

### API Authentication
Most endpoints in the backend require authentication:
- Store JWT token from login response
- Add token to Authorization header: `Bearer {token}`
- Refresh token on expiry
- Clear token on logout

---

## Testing Strategy

### Unit Tests
- Test data models (JSON serialization)
- Test service classes (mock HTTP responses)
- Test providers (state changes)

### Widget Tests
- Test individual widgets render correctly
- Test button interactions
- Test form validation

### Integration Tests
- Test complete user flows
- Test navigation between screens
- Test API integration (with mock server)

---

## Verification Plan

### Development Environment Setup
1. Ensure Flutter SDK is installed (3.10.4+)
2. Run `flutter doctor` to verify setup
3. Install dependencies: `flutter pub get`
4. Start FastAPI backend: `cd Reference/sample && python main.py`
5. Configure API URL in Flutter app
6. Run Flutter app: `flutter run` (select target device/emulator)

### Testing Each Feature
After implementing each screen, verify:

#### Authentication Flow
1. Launch app → Should show Role Selection screen
2. Select "Owner" → Should navigate to Login screen
3. Enter credentials and login → Should show Academy Setup (if first time) or Dashboard
4. Complete academy setup → Should navigate to Owner Dashboard

#### Owner Dashboard - Home Screen
1. Login as owner → Home screen should load
2. Verify statistics cards show correct counts
3. Tap "Student Management" → Should navigate to Student Management screen
4. Tap "Add Student" button → Should show add student form

#### Student Management
1. Navigate to Student Management
2. Verify student list loads (or shows empty state)
3. Tap "Add Student" → Form should appear
4. Fill form and submit → Student should be added to list
5. Tap on student card → Should show student details
6. Edit student details → Changes should be saved
7. Search for student → List should filter

#### Batch Management
1. Navigate to Batches screen
2. Verify batch list loads
3. Add new batch with coach and timing
4. Enroll students in batch
5. Edit batch details
6. Verify batch card shows correct information

#### Attendance Marking
1. Navigate to Attendance screen
2. Select date (today)
3. Select batch
4. Student list should load
5. Mark attendance (present/absent)
6. Add remarks
7. Submit → Attendance should be saved
8. Toggle to "Coach Attendance"
9. Mark coach attendance
10. View attendance history

#### Fee Management
1. Navigate to Fee Management
2. Verify student fee list loads
3. Filter by "Pending" → Should show only pending fees
4. Tap "Record Payment" on a student
5. Enter amount and payment method
6. Submit → Fee status should update

#### Performance Tracking
1. Navigate to Performance Tracking
2. Select student
3. Rate skills (1-5 stars)
4. Add comments
5. Save → Performance record should be created
6. View progress chart

#### BMI Tracking
1. Navigate to BMI Tracking
2. Select student
3. Enter height, weight
4. BMI should auto-calculate
5. Save record
6. View BMI history table

#### Reports
1. Navigate to Reports screen
2. Select report type (Attendance)
3. Select date range
4. Generate report → Report should display
5. Verify data accuracy

#### Calendar
1. Navigate to Calendar
2. Add holiday → Should appear on calendar in red
3. Add tournament → Should appear in blue
4. Add event → Should appear in green
5. Tap on date → Should show events for that date

### End-to-End Testing
Complete user journey:
1. New owner signs up
2. Completes academy setup
3. Adds 3 coaches
4. Creates 5 batches with assigned coaches
5. Adds 20 students and enrolls them in batches
6. Marks attendance for a week
7. Records fee payments
8. Tracks performance for 5 students
9. Generates attendance report
10. Creates announcement
11. Marks holiday on calendar

### Performance Testing
- Test with 100+ students
- Test with 20+ batches
- Verify scroll performance
- Check memory usage
- Test network error scenarios

### Cross-Platform Testing
- Test on Android emulator/device
- Test on iOS simulator/device (if available)
- Verify UI consistency across screen sizes
- Test on different Android versions

---

## Critical Files to Reference

### React UI Components (Reference Implementation)
| Feature | React File | Line Reference |
|---------|-----------|----------------|
| Role Selection | `Reference/Badminton_Academy_Management_App/src/app/components/RoleSelection.tsx` | Full file |
| Login/Signup | `Reference/Badminton_Academy_Management_App/src/app/components/auth/LoginSignup.tsx` | Full file |
| Owner Dashboard | `Reference/Badminton_Academy_Management_App/src/app/components/owner/OwnerDashboard.tsx` | Full file |
| Home Screen | `Reference/Badminton_Academy_Management_App/src/app/components/owner/HomeScreen.tsx` | Lines 1-400 |
| Student Management | `Reference/Badminton_Academy_Management_App/src/app/components/owner/StudentManagement.tsx` | Full file |
| Batch Management | `Reference/Badminton_Academy_Management_App/src/app/components/owner/BatchesScreen.tsx` | Full file |
| Attendance | `Reference/Badminton_Academy_Management_App/src/app/components/owner/AttendanceScreen.tsx` | Full file |
| Fee Management | `Reference/Badminton_Academy_Management_App/src/app/components/owner/FeeManagement.tsx` | Full file |
| Performance Tracking | `Reference/Badminton_Academy_Management_App/src/app/components/owner/PerformanceTracking.tsx` | Full file |
| BMI Tracking | `Reference/Badminton_Academy_Management_App/src/app/components/owner/BMITracking.tsx` | Full file |

### Backend API
| Resource | Backend File | Database Table |
|----------|-------------|----------------|
| Authentication | `Reference/sample/main.py` | coaches, students |
| Students API | `Reference/sample/main.py` | students |
| Coaches API | `Reference/sample/main.py` | coaches |
| Batches API | `Reference/sample/main.py` | batches, batch_students |
| Attendance API | `Reference/sample/main.py` | attendance, coach_attendance |
| Fees API | `Reference/sample/main.py` | fees |
| Performance API | `Reference/sample/main.py` | performance |
| BMI API | `Reference/sample/main.py` | bmi_records |
| Database Schema | `Reference/sample/main.py` | Lines with SQLAlchemy models |

### Flutter Files to Create/Modify
| Component | Flutter File |
|-----------|-------------|
| Main Entry | [Flutter_Frontend/Badminton/lib/main.dart](Flutter_Frontend/Badminton/lib/main.dart) |
| Dependencies | [Flutter_Frontend/Badminton/pubspec.yaml](Flutter_Frontend/Badminton/pubspec.yaml) |
| Theme | [Flutter_Frontend/Badminton/lib/config/theme.dart](Flutter_Frontend/Badminton/lib/config/theme.dart) |
| Routes | [Flutter_Frontend/Badminton/lib/config/routes.dart](Flutter_Frontend/Badminton/lib/config/routes.dart) |
| API Service | [Flutter_Frontend/Badminton/lib/services/api_service.dart](Flutter_Frontend/Badminton/lib/services/api_service.dart) |

---

## Implementation Notes

### Design Consistency
The Flutter app should match the React UI's visual design:
- **Colors**: Use exact hex codes from React CSS
- **Shadows**: Replicate neumorphic effect with multiple shadows
- **Typography**: Use similar font weights and sizes
- **Spacing**: Match padding and margins
- **Animations**: Add subtle transitions for better UX

### Mobile-First Considerations
While React UI is designed for web, Flutter version should be optimized for mobile:
- Touch-friendly tap targets (minimum 48x48 dp)
- Swipe gestures for navigation
- Pull-to-refresh for lists
- Bottom sheets instead of modals where appropriate
- Responsive layouts for different screen sizes

### Data Synchronization
- Fetch fresh data on screen focus
- Implement pull-to-refresh
- Show cached data while loading
- Handle offline scenarios gracefully

### Security
- Store sensitive data (tokens) in flutter_secure_storage
- Validate all user inputs
- Sanitize API responses
- Use HTTPS for production API
- Implement token refresh mechanism

---

## Success Criteria

The Flutter app will be considered complete when:

1. ✅ All authentication flows work (login, signup, academy setup)
2. ✅ Owner dashboard displays all 5 tabs
3. ✅ CRUD operations work for students, coaches, and batches
4. ✅ Attendance marking works for both students and coaches
5. ✅ Fee management allows recording payments
6. ✅ Performance and BMI tracking are functional
7. ✅ Reports can be generated
8. ✅ Calendar displays events correctly
9. ✅ UI matches React reference design
10. ✅ App handles errors gracefully
11. ✅ All API integrations work correctly
12. ✅ App is tested on Android (minimum)

---

## Future Enhancements (Post-MVP)

After completing owner portal:
1. Coach portal implementation
2. Student portal implementation
3. Push notifications
4. Real-time updates (WebSocket)
5. Offline mode with local database
6. Image upload for students/coaches
7. PDF export for reports
8. Multi-academy support
9. Role-based permissions
10. Analytics dashboard

---

## Timeline Estimate

**Total Estimated Time**: 10-12 weeks for complete owner portal implementation

- **Phase 1 (Foundation)**: 1-2 weeks
- **Phase 2 (Authentication)**: 1 week
- **Phase 3 (Dashboard Core)**: 2 weeks
- **Phase 4 (Management Screens)**: 3-4 weeks
- **Phase 5 (UI Components)**: Ongoing throughout phases 2-4
- **Phase 6 (State Management)**: Ongoing throughout phases 2-4
- **Phase 7 (Polish)**: 2 weeks
- **Testing & Bug Fixes**: 1 week

*Note: This is a rough estimate. Actual time may vary based on familiarity with Flutter, complexity of neumorphic design implementation, and backend modifications needed.*

---

## Decisions Made

Based on user input, here are the confirmed decisions:

1. **Target Platform**: Android first (will add iOS support later)
2. **Backend Deployment**: Run FastAPI locally during development on localhost:8000
3. **State Management**: Riverpod (modern, compile-safe, testable)
4. **Backend Enhancements**: Add all missing features:
   - Announcements API endpoint
   - Image upload functionality (profile photos)
   - Notification system (push notifications)
5. **Chart Library**: fl_chart for performance/BMI visualizations
6. **HTTP Client**: Dio with pretty_dio_logger for debugging

---

## Backend Enhancements Required

Since we're adding new features to the backend, we need to enhance the FastAPI backend first:

### 1. Announcements API

**New Database Table** (add to `Reference/sample/main.py`):
```python
class Announcement(Base):
    __tablename__ = "announcements"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    target_audience = Column(String)  # "all", "students", "coaches"
    priority = Column(String)  # "normal", "high", "urgent"
    created_by = Column(Integer)  # coach_id (owner)
    created_at = Column(DateTime, default=datetime.utcnow)
    scheduled_at = Column(DateTime, nullable=True)
    is_sent = Column(Boolean, default=False)
```

**New Endpoints**:
- `POST /api/announcements/` - Create announcement
- `GET /api/announcements/` - List all announcements
- `GET /api/announcements/{id}` - Get announcement details
- `PUT /api/announcements/{id}` - Update announcement
- `DELETE /api/announcements/{id}` - Delete announcement

**File to modify**: [Reference/sample/main.py](Reference/sample/main.py)

### 2. Image Upload API

**New Database Columns** (modify existing tables):
```python
# Add to Student model
profile_photo = Column(String, nullable=True)  # File path/URL

# Add to Coach model
profile_photo = Column(String, nullable=True)  # File path/URL
```

**New Endpoints**:
- `POST /api/upload/image` - Upload image file
- `GET /api/images/{filename}` - Serve uploaded image

**Storage**:
- Create `uploads/` directory in backend
- Save images with unique filenames
- Return file URL/path to store in database

**File to modify**: [Reference/sample/main.py](Reference/sample/main.py)

### 3. Notification System

**New Database Table**:
```python
class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    user_type = Column(String)  # "student", "coach", "owner"
    title = Column(String, nullable=False)
    body = Column(Text, nullable=False)
    type = Column(String)  # "fee_due", "attendance", "announcement", "general"
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    data = Column(JSON, nullable=True)  # Extra metadata
```

**New Endpoints**:
- `GET /api/notifications/{user_id}` - Get user notifications
- `PUT /api/notifications/{id}/read` - Mark as read
- `POST /api/notifications/send` - Send notification (internal use)

**Push Notification Integration**:
- Use Firebase Cloud Messaging (FCM) for push notifications
- Store FCM tokens in database
- Send push when creating notification

**New Database Column** (add to students, coaches tables):
```python
fcm_token = Column(String, nullable=True)  # Firebase token
```

**File to modify**: [Reference/sample/main.py](Reference/sample/main.py)

### 4. Calendar Events API

**New Database Table**:
```python
class CalendarEvent(Base):
    __tablename__ = "calendar_events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    event_type = Column(String)  # "holiday", "tournament", "event"
    date = Column(Date, nullable=False)
    description = Column(Text, nullable=True)
    created_by = Column(Integer)
    created_at = Column(DateTime, default=datetime.utcnow)
```

**New Endpoints**:
- `POST /api/calendar-events/` - Create event
- `GET /api/calendar-events/` - List events (with date filters)
- `GET /api/calendar-events/{id}` - Get event details
- `PUT /api/calendar-events/{id}` - Update event
- `DELETE /api/calendar-events/{id}` - Delete event

**File to modify**: [Reference/sample/main.py](Reference/sample/main.py)

---

## Updated Implementation Plan

### Phase 0: Backend Enhancements (NEW - Do this first!)

**Duration**: 1 week

#### 0.1 Add Announcements API
- Create Announcement model in SQLAlchemy
- Add CRUD endpoints
- Test with Postman/curl

#### 0.2 Add Image Upload API
- Install `python-multipart` for file uploads
- Create uploads directory
- Add profile_photo columns to students and coaches tables
- Create upload and serve endpoints
- Test with sample image

#### 0.3 Add Notifications API
- Create Notification model
- Add fcm_token columns
- Create notification CRUD endpoints
- Set up Firebase project for FCM
- Add FCM integration (optional for MVP, can use local notifications first)

#### 0.4 Add Calendar Events API
- Create CalendarEvent model
- Add CRUD endpoints
- Test with sample events

#### 0.5 Database Migration
- Run Alembic migration or drop/recreate database with new schema
- Add sample data for testing

**Files to modify**:
- [Reference/sample/main.py](Reference/sample/main.py) - Add all new models and endpoints
- [Reference/sample/requirements.txt](Reference/sample/requirements.txt) - Add python-multipart, firebase-admin (if using FCM)
- Create: `Reference/sample/uploads/` directory

**Testing**:
- Test all new endpoints with Postman
- Verify database tables created
- Test image upload and retrieval
- Verify foreign key relationships

---

### Updated Phase 1: Project Foundation

Add these packages to pubspec.yaml:

```yaml
dependencies:
  # ... existing packages ...

  # Image handling
  image_picker: ^1.0.7
  cached_network_image: ^3.3.1

  # Notifications
  firebase_core: ^2.25.4
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^17.0.0
```

Create additional service files:
- [lib/services/notification_service.dart](Flutter_Frontend/Badminton/lib/services/notification_service.dart) - FCM and local notifications
- [lib/services/image_service.dart](Flutter_Frontend/Badminton/lib/services/image_service.dart) - Image upload and caching

---

### Updated Phase 4: Management Screens

#### 4.1 Student Management (Enhanced)
Add image upload capability:
- Profile photo picker (camera or gallery)
- Image preview before upload
- Upload to backend API
- Display cached network image
- Placeholder for students without photos

**Additional API calls**:
- `POST /api/upload/image` - Upload profile photo
- Returns image URL to save in student record

#### 4.2 Coach Management (Enhanced)
Same image upload features as student management.

#### 4.7 Announcement Management (Enhanced)
Now using real backend API instead of local-only:
- Create announcement with target audience and priority
- List all announcements with filters
- Edit/delete announcements
- Send push notification when announcement is created

**API Endpoints**:
- `POST /api/announcements/` - Create
- `GET /api/announcements/` - List
- `PUT /api/announcements/{id}` - Update
- `DELETE /api/announcements/{id}` - Delete

#### 4.8 Calendar View (Enhanced)
Now using backend API for persistent storage:
- Create events that persist across app restarts
- Sync events across devices
- Filter by event type

**API Endpoints**:
- `POST /api/calendar-events/` - Create event
- `GET /api/calendar-events/?start_date={date}&end_date={date}` - Get events for date range
- `PUT /api/calendar-events/{id}` - Update
- `DELETE /api/calendar-events/{id}` - Delete

#### 4.9 Notifications Screen (NEW)
Add new screen to view all notifications:
- List all notifications (unread first)
- Mark as read on tap
- Group by date
- Filter by type
- Clear all read notifications

**Navigation**: Add notification icon to app bar with badge showing unread count

**File**: [lib/screens/owner/notifications_screen.dart](Flutter_Frontend/Badminton/lib/screens/owner/notifications_screen.dart)

**API Endpoints**:
- `GET /api/notifications/{user_id}` - Get notifications
- `PUT /api/notifications/{id}/read` - Mark as read

---

### Updated Phase 5: Reusable UI Components

Add new components:

#### 5.4 Image Components

**ProfileImagePicker**: [lib/widgets/common/profile_image_picker.dart](Flutter_Frontend/Badminton/lib/widgets/common/profile_image_picker.dart)
- Circular avatar with camera icon overlay
- Tap to pick from gallery or camera
- Show loading indicator during upload
- Display uploaded image or placeholder

**CachedProfileImage**: [lib/widgets/common/cached_profile_image.dart](Flutter_Frontend/Badminton/lib/widgets/common/cached_profile_image.dart)
- Circular cached network image
- Placeholder while loading
- Error icon if load fails

#### 5.5 Notification Components

**NotificationBadge**: [lib/widgets/notification_badge.dart](Flutter_Frontend/Badminton/lib/widgets/notification_badge.dart)
- Small red dot or number badge
- Show on notification icon when unread notifications exist

**NotificationCard**: [lib/widgets/notification_card.dart](Flutter_Frontend/Badminton/lib/widgets/notification_card.dart)
- Display notification with icon, title, body, timestamp
- Different styles for read/unread
- Swipe to delete

---

### Updated Phase 6: State Management

Add new providers:

**NotificationProvider**: [lib/providers/notification_provider.dart](Flutter_Frontend/Badminton/lib/providers/notification_provider.dart)
- Notification list state
- Unread count
- Mark as read
- Fetch notifications
- Listen to FCM messages

**CalendarProvider**: [lib/providers/calendar_provider.dart](Flutter_Frontend/Badminton/lib/providers/calendar_provider.dart)
- Calendar events state
- Fetch events by date range
- CRUD operations
- Filter by event type

**AnnouncementProvider**: [lib/providers/announcement_provider.dart](Flutter_Frontend/Badminton/lib/providers/announcement_provider.dart)
- Announcement list state
- CRUD operations
- Send announcement (triggers notification)

---

### Updated Phase 7: Error Handling & Polish

#### 7.5 Firebase Setup (NEW)
1. Create Firebase project
2. Add Android app to Firebase
3. Download `google-services.json`
4. Place in `android/app/`
5. Configure Android app for FCM
6. Test push notifications

#### 7.6 Image Optimization
- Compress images before upload
- Resize to max 1024x1024
- Cache images locally
- Clear cache periodically

---

## Updated Verification Plan

### Testing Backend Enhancements
Before starting Flutter development:

1. **Start backend**: `cd Reference/sample && python main.py`
2. **Test Announcements API**:
   ```bash
   # Create announcement
   curl -X POST http://localhost:8000/api/announcements/ \
     -H "Content-Type: application/json" \
     -d '{"title":"Test","message":"Hello","target_audience":"all","priority":"normal"}'

   # List announcements
   curl http://localhost:8000/api/announcements/
   ```

3. **Test Image Upload**:
   ```bash
   # Upload image
   curl -X POST http://localhost:8000/api/upload/image \
     -F "file=@test_image.jpg"

   # Should return: {"url": "/uploads/xxx.jpg"}
   ```

4. **Test Calendar Events**:
   ```bash
   # Create event
   curl -X POST http://localhost:8000/api/calendar-events/ \
     -H "Content-Type: application/json" \
     -d '{"title":"Holiday","event_type":"holiday","date":"2026-01-15"}'
   ```

5. **Test Notifications**:
   ```bash
   # Create notification
   curl -X POST http://localhost:8000/api/notifications/send \
     -H "Content-Type: application/json" \
     -d '{"user_id":1,"user_type":"student","title":"Test","body":"Notification test"}'
   ```

### Testing Flutter Features

#### Image Upload
1. Navigate to Add Student screen
2. Tap profile photo placeholder
3. Select "Camera" or "Gallery"
4. Choose/take photo
5. Photo should upload and display in circular avatar
6. Save student → Profile photo URL should be saved
7. Navigate back and view student list → Photo should display

#### Announcements
1. Navigate to Announcement Management
2. Create announcement with title, message, audience
3. Submit → Announcement should appear in list
4. Check that notification was created
5. Edit announcement → Changes should save
6. Delete announcement → Should remove from list

#### Calendar Events
1. Navigate to Calendar
2. Add holiday on a date
3. Calendar should show red marker on that date
4. Tap date → Should show event details
5. Close app and reopen → Event should persist
6. Delete event → Should remove from calendar

#### Push Notifications
1. Ensure Firebase is configured
2. Create announcement from another device/Postman
3. Flutter app should receive push notification
4. Tap notification → Should open announcements screen
5. Notification should appear in notifications list

---

## Updated Success Criteria

The Flutter app will be considered complete when:

1. ✅ Backend has all new endpoints (announcements, images, notifications, calendar)
2. ✅ All authentication flows work
3. ✅ Owner dashboard displays all 5 tabs
4. ✅ CRUD operations work for all entities
5. ✅ Image upload works for students and coaches
6. ✅ Announcements can be created and sent
7. ✅ Calendar events persist and sync
8. ✅ Push notifications are received
9. ✅ Notifications screen displays all notifications
10. ✅ Attendance marking works for both roles
11. ✅ Fee management allows recording payments
12. ✅ Performance and BMI tracking are functional
13. ✅ Reports can be generated
14. ✅ UI matches React reference design
15. ✅ App handles errors gracefully
16. ✅ App is tested on Android

---

## Updated Timeline Estimate

**Total Estimated Time**: 11-13 weeks

- **Phase 0 (Backend Enhancements)**: 1 week ← NEW
- **Phase 1 (Foundation)**: 1-2 weeks
- **Phase 2 (Authentication)**: 1 week
- **Phase 3 (Dashboard Core)**: 2 weeks
- **Phase 4 (Management Screens)**: 3-4 weeks (includes new features)
- **Phase 5 (UI Components)**: Ongoing
- **Phase 6 (State Management)**: Ongoing
- **Phase 7 (Polish + Firebase)**: 2 weeks
- **Testing**: 1 week

---

## Conclusion

This updated plan includes all the enhancements you requested:

1. **Backend additions**: Announcements, image uploads, notifications, calendar events
2. **Flutter integration**: Full support for all new backend features
3. **Push notifications**: Firebase Cloud Messaging setup
4. **Image handling**: Profile photos with upload and caching

The implementation will now start with **Phase 0 (Backend Enhancements)** before moving to Flutter development. This ensures the API is ready when we start building the Flutter UI.

Development priority: **Android first**, using **Riverpod** for state management, with backend running **locally** during development.

Ready to start with Phase 0 (Backend Enhancements)!
