# Coach and Student Screens - Implementation Guide

**Project**: Badminton Academy Management System
**Document Purpose**: Complete implementation guide for Coach and Student portals
**Date**: January 14, 2026
**Status**: Pending Implementation

---

## Table of Contents

1. [Overview](#overview)
2. [Design System Reference](#design-system-reference)
3. [Database Schema & Connections](#database-schema--connections)
4. [Coach Portal - 7 Screens](#coach-portal---7-screens)
5. [Student Portal - 9 Screens](#student-portal---9-screens)
6. [Common Features Across All Portals](#common-features-across-all-portals)
7. [API Integration Guide](#api-integration-guide)
8. [Implementation Checklist](#implementation-checklist)

---

## Overview

This document provides complete specifications for implementing Coach and Student portals, based on the existing Owner portal design and functionality.

### Current State
- ✅ **Owner Portal**: Fully functional (19+ screens)
- ❌ **Coach Portal**: Empty directory, placeholder route only
- ❌ **Student Portal**: Only profile completion screen

### Target State
- ✅ **Owner Portal**: Fully functional (existing)
- ✅ **Coach Portal**: 7 functional screens (TO IMPLEMENT)
- ✅ **Student Portal**: 9 functional screens (TO IMPLEMENT)

### Key Principles
1. **Design Consistency**: Use same neumorphic design as Owner portal
2. **Database Integration**: All data comes from shared backend database
3. **Role-Based Access**: Coaches and Students see only their own data
4. **Feature Parity**: All portals have dark mode, notifications, profile management

---

## Design System Reference

### Extract from Owner Portal

All Coach and Student screens MUST follow these design patterns from the existing Owner portal:

#### 1. Neumorphic Design System

**Colors** (from `lib/core/constants/colors.dart`):
```dart
class AppColors {
  // Background
  static const Color background = Color(0xFF2C2C2E);
  static const Color cardBackground = Color(0xFF3A3A3C);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);

  // Accent
  static const Color accent = Color(0xFF0A84FF);
  static const Color accentDark = Color(0xFF0066CC);

  // Status Colors
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFFD60A);

  // Neumorphic Shadows
  static const Color shadowDark = Color(0xFF1C1C1E);
  static const Color shadowLight = Color(0xFF48484A);
}
```

**Typography** (Poppins font family):
```dart
// Headings
TextStyle heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
TextStyle heading2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
TextStyle heading3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

// Body
TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
```

**Spacing** (from `lib/core/constants/dimensions.dart`):
```dart
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
```

#### 2. Neumorphic Components

**Use Existing Components**:
- `NeumorphicContainer` (from `lib/widgets/common/neumorphic_container.dart`)
- `NeumorphicButton` (from `lib/widgets/common/neumorphic_button.dart`)
- `CustomTextField` (from `lib/widgets/common/custom_text_field.dart`)
- `CustomAppBar` (from `lib/widgets/common/custom_app_bar.dart`)
- `LoadingSpinner` (from `lib/widgets/common/loading_spinner.dart`)

**New Components Available**:
- `BatchCard` (from `lib/widgets/batch_card.dart`)
- `StudentCard` (from `lib/widgets/student_card.dart`)
- `StatisticsCard` (from `lib/widgets/statistics_card.dart`)
- `CachedProfileImage` (from `lib/widgets/common/cached_profile_image.dart`)
- `BottomNavBar` (from `lib/widgets/bottom_nav_bar.dart`)

#### 3. Screen Layout Pattern

**Standard Screen Structure** (follow Owner portal pattern):
```dart
class ExampleScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends ConsumerState<ExampleScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // API calls here
    } catch (e) {
      // Error handling
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Screen Title',
        actions: [/* action buttons */],
      ),
      body: _isLoading
          ? LoadingSpinner()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [/* screen content */],
                ),
              ),
            ),
    );
  }
}
```

---

## Database Schema & Connections

### Database Tables Overview

All three portals (Owner, Coach, Student) share the same PostgreSQL database with these key tables:

#### 1. **users** table (Authentication)
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  user_type VARCHAR(20) NOT NULL, -- 'owner', 'coach', 'student'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. **coaches** table
```sql
CREATE TABLE coaches (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(15),
  specialization VARCHAR(255),
  experience_years INTEGER,
  profile_photo VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 3. **students** table
```sql
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(15),
  age INTEGER,
  guardian_name VARCHAR(255),
  guardian_phone VARCHAR(15),
  date_of_birth DATE,
  address TEXT,
  medical_conditions TEXT,
  t_shirt_size VARCHAR(10),
  profile_photo VARCHAR(255),
  profile_complete BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. **batches** table
```sql
CREATE TABLE batches (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  timing VARCHAR(100),
  days VARCHAR(100),
  coach_id INTEGER REFERENCES coaches(id), -- Links to coach
  location VARCHAR(255),
  max_students INTEGER,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 5. **batch_enrollments** table (Many-to-Many: Students ↔ Batches)
```sql
CREATE TABLE batch_enrollments (
  id SERIAL PRIMARY KEY,
  batch_id INTEGER REFERENCES batches(id),
  student_id INTEGER REFERENCES students(id),
  enrolled_date DATE DEFAULT CURRENT_DATE,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(batch_id, student_id)
);
```

#### 6. **attendance** table
```sql
CREATE TABLE attendance (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  batch_id INTEGER REFERENCES batches(id),
  date DATE NOT NULL,
  status VARCHAR(20) NOT NULL, -- 'present', 'absent'
  remarks TEXT,
  marked_by INTEGER REFERENCES coaches(id), -- Who marked attendance
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 7. **fees** table
```sql
CREATE TABLE fees (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  amount DECIMAL(10,2) NOT NULL,
  due_date DATE NOT NULL,
  month VARCHAR(20),
  status VARCHAR(20) NOT NULL, -- 'paid', 'pending', 'overdue'
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 8. **fee_payments** table
```sql
CREATE TABLE fee_payments (
  id SERIAL PRIMARY KEY,
  fee_id INTEGER REFERENCES fees(id),
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATE NOT NULL,
  payment_method VARCHAR(50),
  transaction_reference VARCHAR(255),
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 9. **performance_records** table
```sql
CREATE TABLE performance_records (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  date DATE NOT NULL,
  serve_rating INTEGER CHECK (serve_rating BETWEEN 1 AND 5),
  smash_rating INTEGER CHECK (smash_rating BETWEEN 1 AND 5),
  footwork_rating INTEGER CHECK (footwork_rating BETWEEN 1 AND 5),
  defense_rating INTEGER CHECK (defense_rating BETWEEN 1 AND 5),
  stamina_rating INTEGER CHECK (stamina_rating BETWEEN 1 AND 5),
  comments TEXT,
  created_by INTEGER REFERENCES coaches(id), -- Who recorded performance
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 10. **bmi_records** table
```sql
CREATE TABLE bmi_records (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  date DATE NOT NULL,
  height DECIMAL(5,2) NOT NULL, -- in cm
  weight DECIMAL(5,2) NOT NULL, -- in kg
  bmi DECIMAL(5,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 11. **schedules** table (Sessions)
```sql
CREATE TABLE schedules (
  id SERIAL PRIMARY KEY,
  batch_id INTEGER REFERENCES batches(id),
  coach_id INTEGER REFERENCES coaches(id),
  activity VARCHAR(50) NOT NULL, -- 'practice', 'tournament', 'camp'
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  location VARCHAR(255),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 12. **announcements** table
```sql
CREATE TABLE announcements (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  target_audience VARCHAR(20) NOT NULL, -- 'all', 'students', 'coaches'
  priority VARCHAR(20) NOT NULL, -- 'low', 'medium', 'high'
  scheduled_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Database Relationships Diagram

```
users (authentication)
  ↓
  ├─→ coaches (profile)
  │     ↓
  │     ├─→ batches (assigned_coach) ← manages batches
  │     ├─→ attendance (marked_by) ← marks attendance
  │     └─→ performance_records (created_by) ← records performance
  │
  └─→ students (profile)
        ↓
        ├─→ batch_enrollments → batches (enrolled in)
        ├─→ attendance (student_id) ← attendance records
        ├─→ fees (student_id) ← fee records
        │     └─→ fee_payments (fee_id) ← payments
        ├─→ performance_records (student_id) ← performance history
        └─→ bmi_records (student_id) ← BMI history
```

### Data Flow Examples

#### Example 1: Coach Marks Attendance
```
1. Coach logs in → auth_service validates → returns coach_id
2. Coach navigates to Attendance screen
3. Screen loads: GET /api/batches/?coach_id={coach_id} → only assigned batches
4. Coach selects batch → GET /api/batches/{batch_id}/students → student list
5. Coach marks Present/Absent for each student
6. Coach saves → POST /api/attendance/ with:
   - student_id (from batch students)
   - batch_id (selected batch)
   - date (selected date)
   - status ('present' or 'absent')
   - marked_by (coach_id from auth)
7. Database inserts attendance records
8. Student can now see this attendance in their portal
```

#### Example 2: Student Views Performance
```
1. Student logs in → auth_service validates → returns student_id
2. Student navigates to Performance screen
3. Screen loads: GET /api/performance/?student_id={student_id}
4. Backend queries:
   SELECT * FROM performance_records
   WHERE student_id = {student_id}
   ORDER BY date DESC
5. Frontend displays:
   - Skill ratings (serve, smash, footwork, defense, stamina)
   - Trend chart (fl_chart)
   - Coach comments
6. All data is READ-ONLY for student (cannot edit)
```

#### Example 3: Student Views Fees
```
1. Student logs in → auth_service validates → returns student_id
2. Student navigates to Fees screen
3. Screen loads: GET /api/fees/?student_id={student_id}
4. Backend queries:
   SELECT f.*,
          COALESCE(SUM(fp.amount), 0) as paid_amount
   FROM fees f
   LEFT JOIN fee_payments fp ON f.id = fp.fee_id
   WHERE f.student_id = {student_id}
   GROUP BY f.id
   ORDER BY f.due_date DESC
5. Frontend calculates:
   - Total pending = amount - paid_amount
   - Status (overdue if due_date < today AND pending > 0)
6. Student sees complete fee history (READ-ONLY)
```

---

## Coach Portal - 7 Screens

### Screen 1: Coach Dashboard (Container)

**File**: `lib/screens/coach/coach_dashboard.dart`

**Purpose**: Main container with bottom navigation (similar to Owner Dashboard)

**Features**:
- Bottom navigation bar with 5 tabs
- Screen switching
- State management for selected tab
- Persistent across sessions

**UI Layout**:
```dart
class CoachDashboard extends StatefulWidget {
  @override
  _CoachDashboardState createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    CoachHomeScreen(),
    CoachBatchesScreen(),
    CoachAttendanceScreen(),
    CoachAnnouncementsScreen(),
    CoachProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Batches'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcements'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

**Design Reference**: Copy exact pattern from [owner_dashboard.dart](../Flutter_Frontend/Badminton/lib/screens/owner/owner_dashboard.dart)

**Database**: No direct database calls (container only)

**Estimated LOC**: ~250

---

### Screen 2: Coach Home Screen

**File**: `lib/screens/coach/coach_home_screen.dart`

**Purpose**: Landing screen showing overview of assigned batches and today's schedule

**Database Queries**:
1. Get coach details: `SELECT * FROM coaches WHERE id = {coach_id}`
2. Get assigned batches: `SELECT * FROM batches WHERE coach_id = {coach_id} AND is_active = TRUE`
3. Get today's sessions: `SELECT * FROM schedules WHERE coach_id = {coach_id} AND date = {today}`
4. Get total students: `SELECT COUNT(DISTINCT be.student_id) FROM batch_enrollments be JOIN batches b ON be.batch_id = b.id WHERE b.coach_id = {coach_id}`

**API Calls**:
```dart
// 1. Get coach info
final coach = await ref.read(coachServiceProvider).getCoach(coachId);

// 2. Get assigned batches
final batches = await ref.read(batchServiceProvider).getBatches(coachId: coachId);

// 3. Get today's schedule
final sessions = await ref.read(scheduleServiceProvider).getSchedules(
  coachId: coachId,
  date: DateTime.now(),
);

// 4. Calculate total students
int totalStudents = 0;
for (var batch in batches) {
  final students = await ref.read(batchServiceProvider).getBatchStudents(batch.id);
  totalStudents += students.length;
}
```

**UI Components**:
```dart
Column(
  children: [
    // Welcome Section
    Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CachedProfileImage(imageUrl: coach.profilePhoto),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${coach.name}', style: heading2),
              Text('${DateFormat('EEEE, MMM d').format(DateTime.now())}'),
            ],
          ),
        ],
      ),
    ),

    // Statistics Cards (2x2 Grid)
    GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        StatisticsCard(
          icon: Icons.people,
          value: '$totalStudents',
          label: 'Total Students',
          color: AppColors.accent,
        ),
        StatisticsCard(
          icon: Icons.grid_view,
          value: '${batches.length}',
          label: 'My Batches',
          color: AppColors.success,
        ),
        StatisticsCard(
          icon: Icons.calendar_today,
          value: '${sessions.length}',
          label: 'Today\'s Sessions',
          color: AppColors.warning,
        ),
        StatisticsCard(
          icon: Icons.check_circle,
          value: '${_getThisMonthAttendance()}%',
          label: 'Avg Attendance',
          color: AppColors.error,
        ),
      ],
    ),

    // Assigned Batches List
    SectionHeader(title: 'My Batches'),
    ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: batches.length,
      itemBuilder: (context, index) {
        return BatchCard(
          batch: batches[index],
          onTap: () => _viewBatchDetails(batches[index]),
        );
      },
    ),

    // Today's Schedule
    SectionHeader(title: 'Today\'s Schedule'),
    ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        return SessionCard(session: sessions[index]);
      },
    ),
  ],
)
```

**Design Reference**: Similar to [owner home_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/home_screen.dart)

**Estimated LOC**: ~400

---

### Screen 3: Coach Batches Screen

**File**: `lib/screens/coach/coach_batches_screen.dart`

**Purpose**: View all assigned batches with student lists (READ-ONLY)

**Database Queries**:
1. Get assigned batches: `SELECT * FROM batches WHERE coach_id = {coach_id} AND is_active = TRUE`
2. Get students per batch: `SELECT s.* FROM students s JOIN batch_enrollments be ON s.id = be.student_id WHERE be.batch_id = {batch_id} AND be.is_active = TRUE`
3. Get attendance stats: `SELECT COUNT(*) as present FROM attendance WHERE batch_id = {batch_id} AND student_id = {student_id} AND status = 'present'`

**API Calls**:
```dart
// Get assigned batches
final batches = await ref.read(batchServiceProvider).getBatches(coachId: coachId);

// For selected batch, get students
final students = await ref.read(batchServiceProvider).getBatchStudents(batchId);

// Get attendance stats for each student
for (var student in students) {
  final attendance = await ref.read(attendanceServiceProvider).getAttendance(
    studentId: student.id,
    batchId: batchId,
  );
  // Calculate percentage
}
```

**UI Components**:
```dart
Column(
  children: [
    // Search Bar
    Padding(
      padding: EdgeInsets.all(16),
      child: CustomTextField(
        hintText: 'Search batches...',
        prefixIcon: Icon(Icons.search),
        onChanged: (value) => _filterBatches(value),
      ),
    ),

    // Batch Cards
    Expanded(
      child: ListView.builder(
        itemCount: _filteredBatches.length,
        itemBuilder: (context, index) {
          final batch = _filteredBatches[index];
          return NeumorphicContainer(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => _showBatchDetails(batch),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.name, style: heading3),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16),
                        SizedBox(width: 4),
                        Text(batch.timing),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 4),
                        Text(batch.days),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16),
                        SizedBox(width: 4),
                        Text(batch.location),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16),
                        SizedBox(width: 4),
                        Text('${batch.enrolledStudents}/${batch.maxStudents} students'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  ],
)
```

**Batch Details Modal** (Bottom Sheet):
```dart
void _showBatchDetails(Batch batch) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Batch Info Header
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(batch.name, style: heading2),
                    Text('${batch.timing} • ${batch.days}'),
                  ],
                ),
              ),

              // Enrolled Students List
              Expanded(
                child: FutureBuilder<List<Student>>(
                  future: _loadStudents(batch.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return StudentCard(
                            student: snapshot.data![index],
                            showAttendance: true,
                          );
                        },
                      );
                    }
                    return LoadingSpinner();
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
```

**Design Reference**: Similar to [batches_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/batches_screen.dart) but READ-ONLY (no add/edit/delete)

**Estimated LOC**: ~500

---

### Screen 4: Coach Attendance Screen

**File**: `lib/screens/coach/coach_attendance_screen.dart`

**Purpose**: Mark attendance for assigned batches only (most critical coach feature)

**Database Queries**:
1. Get assigned batches: `SELECT * FROM batches WHERE coach_id = {coach_id} AND is_active = TRUE`
2. Get students in batch: `SELECT s.* FROM students s JOIN batch_enrollments be ON s.id = be.student_id WHERE be.batch_id = {batch_id}`
3. Check existing attendance: `SELECT * FROM attendance WHERE batch_id = {batch_id} AND date = {date}`
4. Save attendance: `INSERT INTO attendance (student_id, batch_id, date, status, remarks, marked_by) VALUES (...)`

**API Calls**:
```dart
// 1. Get assigned batches (for dropdown)
final batches = await ref.read(batchServiceProvider).getBatches(coachId: coachId);

// 2. When batch selected, get students
final students = await ref.read(batchServiceProvider).getBatchStudents(selectedBatchId);

// 3. Check if attendance already marked
final existingAttendance = await ref.read(attendanceServiceProvider).getAttendance(
  batchId: selectedBatchId,
  date: selectedDate,
);

// 4. Save attendance
await ref.read(attendanceServiceProvider).markAttendance(
  attendanceList: attendanceRecords, // List of {student_id, status, remarks}
  batchId: selectedBatchId,
  date: selectedDate,
  markedBy: coachId,
);
```

**UI Components**:
```dart
Column(
  children: [
    // Date Picker
    NeumorphicContainer(
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _selectDate(),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.calendar_today),
              SizedBox(width: 12),
              Text(DateFormat('dd MMM, yyyy').format(_selectedDate)),
              Spacer(),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    ),

    // Batch Selector Dropdown
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(labelText: 'Select Batch'),
        value: _selectedBatchId,
        items: _batches.map((batch) {
          return DropdownMenuItem(
            value: batch.id,
            child: Text(batch.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedBatchId = value);
          _loadStudents();
        },
      ),
    ),

    SizedBox(height: 16),

    // Student Attendance List
    Expanded(
      child: _isLoadingStudents
          ? LoadingSpinner()
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final attendance = _attendanceMap[student.id];

                return NeumorphicContainer(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Info
                        Row(
                          children: [
                            CachedProfileImage(
                              imageUrl: student.profilePhoto,
                              radius: 24,
                            ),
                            SizedBox(width: 12),
                            Text(student.name, style: bodyLarge),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Present/Absent Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _markAttendance(student.id, 'present'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: attendance == 'present'
                                      ? AppColors.success
                                      : AppColors.cardBackground,
                                ),
                                child: Text('Present'),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _markAttendance(student.id, 'absent'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: attendance == 'absent'
                                      ? AppColors.error
                                      : AppColors.cardBackground,
                                ),
                                child: Text('Absent'),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        // Remarks Field
                        CustomTextField(
                          hintText: 'Remarks (optional)',
                          maxLines: 2,
                          onChanged: (value) => _updateRemarks(student.id, value),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    ),

    // Summary Section
    NeumorphicContainer(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Present', _presentCount, AppColors.success),
            _buildSummaryItem('Absent', _absentCount, AppColors.error),
            _buildSummaryItem('Total', _students.length, AppColors.textSecondary),
            _buildSummaryItem(
              'Percentage',
              _students.isEmpty ? 0 : ((_presentCount / _students.length) * 100).round(),
              AppColors.accent,
            ),
          ],
        ),
      ),
    ),

    // Save Button
    Padding(
      padding: EdgeInsets.all(16),
      child: NeumorphicButton(
        onPressed: _saveAttendance,
        child: Text('Save Attendance'),
        isLoading: _isSaving,
      ),
    ),
  ],
)
```

**Save Attendance Logic**:
```dart
Future<void> _saveAttendance() async {
  if (_selectedBatchId == null) {
    _showError('Please select a batch');
    return;
  }

  // Validate all students have attendance marked
  if (_attendanceMap.length != _students.length) {
    _showError('Please mark attendance for all students');
    return;
  }

  setState(() => _isSaving = true);

  try {
    // Prepare attendance records
    final records = _students.map((student) {
      return {
        'student_id': student.id,
        'batch_id': _selectedBatchId,
        'date': _selectedDate.toIso8601String(),
        'status': _attendanceMap[student.id],
        'remarks': _remarksMap[student.id] ?? '',
        'marked_by': widget.coachId,
      };
    }).toList();

    // API call
    await ref.read(attendanceServiceProvider).markAttendance(records);

    // Success
    _showSuccess('Attendance saved successfully');

    // Clear form
    setState(() {
      _attendanceMap.clear();
      _remarksMap.clear();
    });

  } catch (e) {
    _showError('Failed to save attendance: $e');
  } finally {
    setState(() => _isSaving = false);
  }
}
```

**Design Reference**: Similar to [attendance_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/attendance_screen.dart) but simplified (only assigned batches)

**Estimated LOC**: ~600

---

### Screen 5: Coach Announcements Screen

**File**: `lib/screens/coach/coach_announcements_screen.dart`

**Purpose**: View announcements targeted to coaches (READ-ONLY)

**Database Query**:
```sql
SELECT * FROM announcements
WHERE target_audience IN ('all', 'coaches')
ORDER BY created_at DESC
```

**API Call**:
```dart
// Get all announcements
final announcements = await ref.read(announcementServiceProvider).getAnnouncements();

// Filter for coaches (client-side)
final coachAnnouncements = announcements.where((a) {
  return a.targetAudience == 'all' || a.targetAudience == 'coaches';
}).toList();
```

**UI Components**:
```dart
Column(
  children: [
    // Filter Chips
    Padding(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: Text('All'),
            selected: _selectedFilter == 'all',
            onSelected: (selected) => _filterAnnouncements('all'),
          ),
          ChoiceChip(
            label: Text('Urgent'),
            selected: _selectedFilter == 'high',
            onSelected: (selected) => _filterAnnouncements('high'),
          ),
          ChoiceChip(
            label: Text('Normal'),
            selected: _selectedFilter == 'low',
            onSelected: (selected) => _filterAnnouncements('low'),
          ),
        ],
      ),
    ),

    // Announcements List
    Expanded(
      child: RefreshIndicator(
        onRefresh: _loadAnnouncements,
        child: ListView.builder(
          itemCount: _filteredAnnouncements.length,
          itemBuilder: (context, index) {
            final announcement = _filteredAnnouncements[index];

            // Priority color
            Color priorityColor = AppColors.success;
            if (announcement.priority == 'high') priorityColor = AppColors.warning;
            if (announcement.priority == 'urgent') priorityColor = AppColors.error;

            return NeumorphicContainer(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => _showAnnouncementDetails(announcement),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority Indicator & Date
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              announcement.priority.toUpperCase(),
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            _formatDate(announcement.createdAt),
                            style: bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Title
                      Text(
                        announcement.title,
                        style: bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),

                      SizedBox(height: 4),

                      // Message Preview
                      Text(
                        announcement.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  ],
)
```

**Announcement Details Modal**:
```dart
void _showAnnouncementDetails(Announcement announcement) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(announcement.title, style: heading2),
              SizedBox(height: 8),

              // Date & Priority
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14),
                  SizedBox(width: 4),
                  Text(_formatDate(announcement.createdAt)),
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(announcement.priority).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      announcement.priority.toUpperCase(),
                      style: TextStyle(color: _getPriorityColor(announcement.priority)),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Message
              Text(announcement.message, style: bodyMedium),

              SizedBox(height: 24),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

**Design Reference**: Similar to announcement list in [announcement_management_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/announcement_management_screen.dart) but READ-ONLY

**Estimated LOC**: ~400

---

### Screen 6: Coach Profile Screen

**File**: `lib/screens/coach/coach_profile_screen.dart`

**Purpose**: View and edit coach's own profile

**Database Query**:
```sql
-- Get coach profile
SELECT * FROM coaches WHERE id = {coach_id}

-- Update coach profile
UPDATE coaches
SET name = {name}, phone = {phone}, specialization = {specialization},
    experience_years = {years}, profile_photo = {photo_url}
WHERE id = {coach_id}
```

**API Calls**:
```dart
// Get coach profile
final coach = await ref.read(coachServiceProvider).getCoach(coachId);

// Update profile
await ref.read(coachServiceProvider).updateCoach(coachId, {
  'name': _nameController.text,
  'phone': _phoneController.text,
  'specialization': _specializationController.text,
  'experience_years': _experienceYears,
  'profile_photo': _profilePhotoUrl,
});

// Upload profile photo
if (_selectedImage != null) {
  _profilePhotoUrl = await ref.read(apiServiceProvider).uploadImage(_selectedImage);
}
```

**UI Components**:
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      // Profile Photo Section
      Center(
        child: Stack(
          children: [
            CachedProfileImage(
              imageUrl: _profilePhotoUrl,
              radius: 60,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: 32),

      // Personal Information Section
      _buildSectionHeader('Personal Information'),

      CustomTextField(
        controller: _nameController,
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person),
        validator: (value) => value!.isEmpty ? 'Name is required' : null,
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _emailController,
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        enabled: false, // Email cannot be changed
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _phoneController,
        labelText: 'Phone Number',
        prefixIcon: Icon(Icons.phone),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) return 'Phone is required';
          if (value.length != 10) return 'Phone must be 10 digits';
          return null;
        },
      ),

      SizedBox(height: 32),

      // Professional Information Section
      _buildSectionHeader('Professional Information'),

      CustomTextField(
        controller: _specializationController,
        labelText: 'Specialization',
        prefixIcon: Icon(Icons.star),
        hintText: 'e.g., Advanced Training, Beginners',
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _experienceController,
        labelText: 'Experience (Years)',
        prefixIcon: Icon(Icons.work),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) return null;
          final years = int.tryParse(value);
          if (years == null || years < 0 || years > 50) {
            return 'Enter valid experience (0-50 years)';
          }
          return null;
        },
      ),

      SizedBox(height: 32),

      // Statistics Section (Read-only)
      _buildSectionHeader('My Statistics'),

      NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatRow('Total Batches Assigned', '${_totalBatches}'),
              Divider(),
              _buildStatRow('Total Students', '${_totalStudents}'),
              Divider(),
              _buildStatRow('Joined Date', _formatDate(_coach.createdAt)),
            ],
          ),
        ),
      ),

      SizedBox(height: 32),

      // Save Button
      NeumorphicButton(
        onPressed: _saveProfile,
        isLoading: _isSaving,
        child: Text('Save Changes'),
      ),

      SizedBox(height: 16),

      // Change Password Section
      _buildSectionHeader('Change Password'),

      CustomTextField(
        controller: _currentPasswordController,
        labelText: 'Current Password',
        prefixIcon: Icon(Icons.lock),
        obscureText: true,
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _newPasswordController,
        labelText: 'New Password',
        prefixIcon: Icon(Icons.lock_outline),
        obscureText: true,
        validator: (value) {
          if (value!.isEmpty) return null;
          if (value.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _confirmPasswordController,
        labelText: 'Confirm New Password',
        prefixIcon: Icon(Icons.lock_outline),
        obscureText: true,
        validator: (value) {
          if (value != _newPasswordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),

      SizedBox(height: 16),

      NeumorphicButton(
        onPressed: _changePassword,
        isLoading: _isChangingPassword,
        child: Text('Change Password'),
      ),
    ],
  ),
)
```

**Save Profile Logic**:
```dart
Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    // Upload profile photo if changed
    String? photoUrl = _profilePhotoUrl;
    if (_selectedImage != null) {
      photoUrl = await ref.read(apiServiceProvider).uploadImage(_selectedImage);
    }

    // Update profile
    await ref.read(coachServiceProvider).updateCoach(widget.coachId, {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'specialization': _specializationController.text,
      'experience_years': int.tryParse(_experienceController.text) ?? 0,
      'profile_photo': photoUrl,
    });

    _showSuccess('Profile updated successfully');

  } catch (e) {
    _showError('Failed to update profile: $e');
  } finally {
    setState(() => _isSaving = false);
  }
}
```

**Design Reference**: Similar to Profile section in [more_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/more_screen.dart)

**Estimated LOC**: ~450

---

### Screen 7: Coach Schedule Screen (Optional but Recommended)

**File**: `lib/screens/coach/coach_schedule_screen.dart`

**Purpose**: View upcoming and past sessions assigned to coach

**Database Query**:
```sql
SELECT s.*, b.name as batch_name
FROM schedules s
JOIN batches b ON s.batch_id = b.id
WHERE s.coach_id = {coach_id}
ORDER BY s.date DESC, s.start_time DESC
```

**API Call**:
```dart
// Get all sessions for coach
final sessions = await ref.read(scheduleServiceProvider).getSchedules(coachId: coachId);

// Separate into upcoming and past
final now = DateTime.now();
final upcomingSessions = sessions.where((s) => s.date.isAfter(now)).toList();
final pastSessions = sessions.where((s) => s.date.isBefore(now)).toList();
```

**UI Components**:
```dart
DefaultTabController(
  length: 2,
  child: Column(
    children: [
      // Tabs
      TabBar(
        tabs: [
          Tab(text: 'Upcoming (${_upcomingSessions.length})'),
          Tab(text: 'Past (${_pastSessions.length})'),
        ],
      ),

      // Tab Views
      Expanded(
        child: TabBarView(
          children: [
            // Upcoming Sessions
            _buildSessionList(_upcomingSessions),

            // Past Sessions
            _buildSessionList(_pastSessions),
          ],
        ),
      ),
    ],
  ),
)
```

**Session Card**:
```dart
Widget _buildSessionCard(Schedule session) {
  // Session type color
  Color typeColor = AppColors.accent;
  if (session.activity == 'tournament') typeColor = AppColors.warning;
  if (session.activity == 'camp') typeColor = AppColors.success;

  return NeumorphicContainer(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Type Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.activity.toUpperCase(),
              style: TextStyle(
                color: typeColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 12),

          // Date & Time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16),
              SizedBox(width: 4),
              Text(DateFormat('dd MMM, yyyy').format(session.date)),
              SizedBox(width: 16),
              Icon(Icons.access_time, size: 16),
              SizedBox(width: 4),
              Text('${session.startTime} - ${session.endTime}'),
            ],
          ),

          SizedBox(height: 8),

          // Batch Name
          Row(
            children: [
              Icon(Icons.grid_view, size: 16),
              SizedBox(width: 4),
              Text(session.batchName, style: bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),

          SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(Icons.location_on, size: 16),
              SizedBox(width: 4),
              Text(session.location ?? 'Academy'),
            ],
          ),

          if (session.description != null && session.description!.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              session.description!,
              style: bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    ),
  );
}
```

**Design Reference**: Similar to [session_management_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/session_management_screen.dart) but READ-ONLY

**Estimated LOC**: ~500

---

## Student Portal - 9 Screens

### Screen 1: Student Dashboard (Container)

**File**: `lib/screens/student/student_dashboard.dart`

**Purpose**: Main container with bottom navigation (similar to Owner and Coach dashboards)

**Features**:
- Bottom navigation bar with 6 tabs
- Screen switching
- State management for selected tab
- Persistent across sessions

**UI Layout**:
```dart
class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    StudentHomeScreen(),
    StudentAttendanceScreen(),
    StudentFeesScreen(),
    StudentPerformanceScreen(),
    StudentAnnouncementsScreen(),
    StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Fees'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Performance'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcements'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

**Design Reference**: Same pattern as coach_dashboard.dart and owner_dashboard.dart

**Database**: No direct database calls (container only)

**Estimated LOC**: ~250

---

### Screen 2: Student Home Screen

**File**: `lib/screens/student/student_home_screen.dart`

**Purpose**: Landing screen showing overview of enrolled batches, attendance, fees, and performance

**Database Queries**:
1. Get student details: `SELECT * FROM students WHERE id = {student_id}`
2. Get enrolled batches: `SELECT b.* FROM batches b JOIN batch_enrollments be ON b.id = be.batch_id WHERE be.student_id = {student_id}`
3. Get this month's attendance: `SELECT COUNT(*) as present FROM attendance WHERE student_id = {student_id} AND date >= {first_day_of_month} AND status = 'present'`
4. Get latest fee status: `SELECT * FROM fees WHERE student_id = {student_id} ORDER BY due_date DESC LIMIT 1`
5. Get latest performance: `SELECT * FROM performance_records WHERE student_id = {student_id} ORDER BY date DESC LIMIT 1`
6. Get latest BMI: `SELECT * FROM bmi_records WHERE student_id = {student_id} ORDER BY date DESC LIMIT 1`

**API Calls**:
```dart
// Student info
final student = await ref.read(studentServiceProvider).getStudent(studentId);

// Enrolled batches
final batches = await ref.read(batchServiceProvider).getStudentBatches(studentId);

// This month's attendance
final thisMonth = DateTime.now();
final attendance = await ref.read(attendanceServiceProvider).getAttendance(
  studentId: studentId,
  startDate: DateTime(thisMonth.year, thisMonth.month, 1),
  endDate: thisMonth,
);
final attendanceRate = _calculateAttendanceRate(attendance);

// Latest fee
final fees = await ref.read(feeServiceProvider).getFees(studentId: studentId);
final latestFee = fees.isNotEmpty ? fees.first : null;

// Latest performance
final performance = await ref.read(performanceServiceProvider).getPerformance(studentId: studentId);
final latestPerformance = performance.isNotEmpty ? performance.first : null;

// Latest BMI
final bmiRecords = await ref.read(bmiServiceProvider).getBmiRecords(studentId: studentId);
final latestBmi = bmiRecords.isNotEmpty ? bmiRecords.first : null;

// Upcoming sessions
final sessions = await ref.read(scheduleServiceProvider).getUpcomingSessions(batchIds: batches.map((b) => b.id).toList());
```

**UI Components**:
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Welcome Section with Profile Photo
      Row(
        children: [
          CachedProfileImage(
            imageUrl: student.profilePhoto,
            radius: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${student.name}', style: heading2),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),

      SizedBox(height: 24),

      // Quick Stats Grid (2x2)
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          StatisticsCard(
            icon: Icons.check_circle,
            value: '$attendanceRate%',
            label: 'Attendance',
            color: AppColors.success,
            onTap: () => _navigateToAttendance(),
          ),
          StatisticsCard(
            icon: Icons.payment,
            value: latestFee?.status == 'paid' ? 'Paid' : '₹${latestFee?.amount ?? 0}',
            label: 'Fee Status',
            color: latestFee?.status == 'paid' ? AppColors.success : AppColors.error,
            onTap: () => _navigateToFees(),
          ),
          StatisticsCard(
            icon: Icons.star,
            value: latestPerformance != null
                ? '${_calculateAverageRating(latestPerformance)}/5'
                : 'N/A',
            label: 'Performance',
            color: AppColors.warning,
            onTap: () => _navigateToPerformance(),
          ),
          StatisticsCard(
            icon: Icons.fitness_center,
            value: latestBmi?.bmi.toStringAsFixed(1) ?? 'N/A',
            label: 'BMI',
            color: AppColors.accent,
            onTap: () => _navigateToBmi(),
          ),
        ],
      ),

      SizedBox(height: 24),

      // Enrolled Batches Section
      _buildSectionHeader('My Batches'),
      SizedBox(height: 12),

      batches.isEmpty
          ? _buildEmptyState('No batches enrolled')
          : ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: batches.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return BatchCard(batch: batches[index]);
              },
            ),

      SizedBox(height: 24),

      // Upcoming Sessions Section
      _buildSectionHeader('Upcoming Sessions'),
      SizedBox(height: 12),

      sessions.isEmpty
          ? _buildEmptyState('No upcoming sessions')
          : ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sessions.take(3).length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionCard(session);
              },
            ),

      if (sessions.length > 3) ...[
        SizedBox(height: 12),
        TextButton(
          onPressed: () => _navigateToSchedule(),
          child: Text('View All Sessions'),
        ),
      ],
    ],
  ),
)
```

**Design Reference**: Similar to [coach_home_screen.dart](#screen-2-coach-home-screen) but personalized for student

**Estimated LOC**: ~500

---

### Screen 3: Student Attendance Screen

**File**: `lib/screens/student/student_attendance_screen.dart`

**Purpose**: View attendance history with statistics and charts (READ-ONLY)

**Database Query**:
```sql
SELECT a.*, b.name as batch_name
FROM attendance a
JOIN batches b ON a.batch_id = b.id
WHERE a.student_id = {student_id}
ORDER BY a.date DESC
```

**API Calls**:
```dart
// Get all attendance records
final attendance = await ref.read(attendanceServiceProvider).getAttendance(
  studentId: studentId,
);

// Get batches for filtering
final batches = await ref.read(batchServiceProvider).getStudentBatches(studentId);

// Calculate statistics
final totalDays = attendance.length;
final presentDays = attendance.where((a) => a.status == 'present').length;
final absentDays = totalDays - presentDays;
final attendanceRate = totalDays > 0 ? (presentDays / totalDays * 100).round() : 0;

// Group by month for chart
final monthlyData = _groupByMonth(attendance);
```

**UI Components**:
```dart
Column(
  children: [
    // Overall Statistics Card
    NeumorphicContainer(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Overall Attendance', style: heading3),
            SizedBox(height: 16),

            // Circular Progress Indicator
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: attendanceRate / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.cardBackground,
                    valueColor: AlwaysStoppedAnimation(AppColors.success),
                  ),
                  Center(
                    child: Text(
                      '$attendanceRate%',
                      style: heading1.copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Present/Absent Counts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCountItem('Present', presentDays, AppColors.success),
                _buildCountItem('Absent', absentDays, AppColors.error),
                _buildCountItem('Total', totalDays, AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    ),

    // Filters
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Batch Filter
          Expanded(
            child: DropdownButtonFormField<int?>(
              decoration: InputDecoration(labelText: 'Filter by Batch'),
              value: _selectedBatchId,
              items: [
                DropdownMenuItem(value: null, child: Text('All Batches')),
                ...batches.map((batch) {
                  return DropdownMenuItem(
                    value: batch.id,
                    child: Text(batch.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() => _selectedBatchId = value);
                _filterAttendance();
              },
            ),
          ),

          SizedBox(width: 12),

          // Month Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Month'),
              value: _selectedMonth,
              items: _months.map((month) {
                return DropdownMenuItem(value: month, child: Text(month));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedMonth = value!);
                _filterAttendance();
              },
            ),
          ),
        ],
      ),
    ),

    SizedBox(height: 16),

    // Attendance Trend Chart
    if (_filteredAttendance.isNotEmpty)
      NeumorphicContainer(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance Trend', style: heading3),
              SizedBox(height: 16),

              // Line Chart using fl_chart
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getChartSpots(),
                        isCurved: true,
                        colors: [AppColors.success],
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    SizedBox(height: 16),

    // Attendance History List
    Expanded(
      child: _filteredAttendance.isEmpty
          ? _buildEmptyState('No attendance records')
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredAttendance.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final record = _filteredAttendance[index];
                  final isPresent = record.status == 'present';

                  return NeumorphicContainer(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Status Icon
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isPresent ? AppColors.success : AppColors.error).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPresent ? Icons.check : Icons.close,
                              color: isPresent ? AppColors.success : AppColors.error,
                              size: 20,
                            ),
                          ),

                          SizedBox(width: 12),

                          // Date & Batch
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMM, yyyy').format(record.date),
                                  style: bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  record.batchName,
                                  style: bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                                if (record.remarks != null && record.remarks!.isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    record.remarks!,
                                    style: bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isPresent ? AppColors.success : AppColors.error).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPresent ? 'PRESENT' : 'ABSENT',
                              style: TextStyle(
                                color: isPresent ? AppColors.success : AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    ),
  ],
)
```

**Chart Data Preparation**:
```dart
List<FlSpot> _getChartSpots() {
  final monthlyData = <DateTime, double>{};

  for (var record in _filteredAttendance) {
    final month = DateTime(record.date.year, record.date.month);
    monthlyData[month] = (monthlyData[month] ?? 0) + (record.status == 'present' ? 1 : 0);
  }

  final spots = monthlyData.entries.map((entry) {
    final monthIndex = entry.key.month.toDouble();
    final attendanceCount = entry.value;
    return FlSpot(monthIndex, attendanceCount);
  }).toList();

  spots.sort((a, b) => a.x.compareTo(b.x));
  return spots;
}
```

**Design Reference**: Combine statistics from [attendance_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/attendance_screen.dart) with chart visualization

**Estimated LOC**: ~700

---

### Screen 4: Student Fees Screen

**File**: `lib/screens/student/student_fees_screen.dart`

**Purpose**: View fee status, payment history, and pending amounts (READ-ONLY)

**Database Queries**:
```sql
-- Get all fees for student
SELECT f.*,
       COALESCE(SUM(fp.amount), 0) as paid_amount
FROM fees f
LEFT JOIN fee_payments fp ON f.id = fp.fee_id
WHERE f.student_id = {student_id}
GROUP BY f.id
ORDER BY f.due_date DESC

-- Get payment history for a fee
SELECT * FROM fee_payments
WHERE fee_id = {fee_id}
ORDER BY payment_date DESC
```

**API Calls**:
```dart
// Get all fees
final fees = await ref.read(feeServiceProvider).getFees(studentId: studentId);

// Calculate totals
double totalFees = 0;
double totalPaid = 0;
double totalPending = 0;
double totalOverdue = 0;

for (var fee in fees) {
  totalFees += fee.amount;

  // Get payments for this fee
  final payments = await ref.read(feeServiceProvider).getPayments(feeId: fee.id);
  final paidAmount = payments.fold<double>(0, (sum, payment) => sum + payment.amount);
  totalPaid += paidAmount;

  final pending = fee.amount - paidAmount;
  if (pending > 0) {
    totalPending += pending;
    if (fee.dueDate.isBefore(DateTime.now())) {
      totalOverdue += pending;
    }
  }
}
```

**UI Components**:
```dart
Column(
  children: [
    // Fee Summary Card
    NeumorphicContainer(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Fee Summary', style: heading3),
            SizedBox(height: 16),

            // Total Fees
            _buildSummaryRow('Total Fees', '₹${totalFees.toStringAsFixed(2)}', AppColors.textPrimary),
            Divider(),
            _buildSummaryRow('Total Paid', '₹${totalPaid.toStringAsFixed(2)}', AppColors.success),
            Divider(),
            _buildSummaryRow('Pending', '₹${totalPending.toStringAsFixed(2)}', AppColors.warning),
            Divider(),
            _buildSummaryRow('Overdue', '₹${totalOverdue.toStringAsFixed(2)}', AppColors.error),
          ],
        ),
      ),
    ),

    // Overdue Alert (if any)
    if (totalOverdue > 0)
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'You have ₹${totalOverdue.toStringAsFixed(2)} in overdue fees. Please pay as soon as possible.',
                style: bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),

    SizedBox(height: 16),

    // Fee Records List
    Expanded(
      child: fees.isEmpty
          ? _buildEmptyState('No fee records')
          : RefreshIndicator(
              onRefresh: _loadFees,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: fees.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final fee = fees[index];
                  return _buildFeeCard(fee);
                },
              ),
            ),
    ),
  ],
)
```

**Fee Card Component**:
```dart
Widget _buildFeeCard(Fee fee) {
  return NeumorphicContainer(
    child: InkWell(
      onTap: () => _showFeeDetails(fee),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fee.month, style: heading3),
                _buildStatusBadge(fee.status),
              ],
            ),

            SizedBox(height: 12),

            // Amount
            Row(
              children: [
                Icon(Icons.currency_rupee, size: 16),
                SizedBox(width: 4),
                Text(
                  '${fee.amount.toStringAsFixed(2)}',
                  style: bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Due Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: fee.dueDate.isBefore(DateTime.now()) && fee.status != 'paid'
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
                SizedBox(width: 4),
                Text(
                  'Due: ${DateFormat('dd MMM, yyyy').format(fee.dueDate)}',
                  style: bodyMedium.copyWith(
                    color: fee.dueDate.isBefore(DateTime.now()) && fee.status != 'paid'
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Payment Progress (if partially paid)
            FutureBuilder<List<FeePayment>>(
              future: ref.read(feeServiceProvider).getPayments(feeId: fee.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final payments = snapshot.data!;
                  final paidAmount = payments.fold<double>(0, (sum, p) => sum + p.amount);
                  final pending = fee.amount - paidAmount;

                  if (paidAmount > 0 && pending > 0) {
                    return Column(
                      children: [
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: paidAmount / fee.amount,
                          backgroundColor: AppColors.cardBackground,
                          valueColor: AlwaysStoppedAnimation(AppColors.success),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Paid: ₹${paidAmount.toStringAsFixed(2)}', style: bodySmall),
                            Text('Pending: ₹${pending.toStringAsFixed(2)}', style: bodySmall),
                          ],
                        ),
                      ],
                    );
                  }
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Fee Details Modal**:
```dart
void _showFeeDetails(Fee fee) async {
  final payments = await ref.read(feeServiceProvider).getPayments(feeId: fee.id);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Fee Details - ${fee.month}', style: heading2),
                SizedBox(height: 8),
                _buildStatusBadge(fee.status),

                SizedBox(height: 24),

                // Fee Info
                _buildDetailRow('Amount', '₹${fee.amount.toStringAsFixed(2)}'),
                _buildDetailRow('Due Date', DateFormat('dd MMM, yyyy').format(fee.dueDate)),
                if (fee.remarks != null && fee.remarks!.isNotEmpty)
                  _buildDetailRow('Remarks', fee.remarks!),

                SizedBox(height: 24),

                // Payment History
                Text('Payment History', style: heading3),
                SizedBox(height: 12),

                Expanded(
                  child: payments.isEmpty
                      ? Center(child: Text('No payments made yet'))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: payments.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final payment = payments[index];
                            return ListTile(
                              leading: Icon(Icons.check_circle, color: AppColors.success),
                              title: Text('₹${payment.amount.toStringAsFixed(2)}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd MMM, yyyy').format(payment.paymentDate)),
                                  Text('via ${payment.paymentMethod}'),
                                  if (payment.transactionReference != null)
                                    Text('Ref: ${payment.transactionReference}'),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
```

**Design Reference**: Similar to [fees_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/fees_screen.dart) but READ-ONLY for student

**Estimated LOC**: ~600

---

### Screen 5: Student Performance Screen

**File**: `lib/screens/student/student_performance_screen.dart`

**Purpose**: View performance records, skill ratings, progress charts, and coach comments (READ-ONLY)

**Database Query**:
```sql
SELECT * FROM performance_records
WHERE student_id = {student_id}
ORDER BY date DESC
```

**API Call**:
```dart
// Get all performance records
final performanceRecords = await ref.read(performanceServiceProvider).getPerformance(
  studentId: studentId,
);

// Calculate average ratings
double averageServe = 0, averageSmash = 0, averageFootwork = 0, averageDefense = 0, averageStamina = 0;
if (performanceRecords.isNotEmpty) {
  averageServe = performanceRecords.map((r) => r.serveRating).reduce((a, b) => a + b) / performanceRecords.length;
  averageSmash = performanceRecords.map((r) => r.smashRating).reduce((a, b) => a + b) / performanceRecords.length;
  averageFootwork = performanceRecords.map((r) => r.footworkRating).reduce((a, b) => a + b) / performanceRecords.length;
  averageDefense = performanceRecords.map((r) => r.defenseRating).reduce((a, b) => a + b) / performanceRecords.length;
  averageStamina = performanceRecords.map((r) => r.staminaRating).reduce((a, b) => a + b) / performanceRecords.length;
}
```

**UI Components**:
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Overall Performance Card
      NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Overall Performance', style: heading3),
              SizedBox(height: 16),

              // Average Rating (out of 5)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _calculateOverallAverage().toStringAsFixed(1),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                  Text('/5', style: heading2),
                ],
              ),

              SizedBox(height: 8),

              // 5-star visual
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < _calculateOverallAverage().round() ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 32,
                  );
                }),
              ),
            ],
          ),
        ),
      ),

      SizedBox(height: 24),

      // Skill Breakdown Section
      Text('Skill Ratings', style: heading3),
      SizedBox(height: 12),

      // Individual Skills
      _buildSkillCard('Serve', averageServe, Icons.sports_tennis, AppColors.accent),
      SizedBox(height: 12),
      _buildSkillCard('Smash', averageSmash, Icons.flash_on, AppColors.error),
      SizedBox(height: 12),
      _buildSkillCard('Footwork', averageFootwork, Icons.directions_run, AppColors.success),
      SizedBox(height: 12),
      _buildSkillCard('Defense', averageDefense, Icons.shield, AppColors.warning),
      SizedBox(height: 12),
      _buildSkillCard('Stamina', averageStamina, Icons.fitness_center, AppColors.purple),

      SizedBox(height: 24),

      // Progress Chart Section
      Text('Progress Trend', style: heading3),
      SizedBox(height: 12),

      NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Legend
              Wrap(
                spacing: 16,
                children: [
                  _buildLegendItem('Serve', AppColors.accent),
                  _buildLegendItem('Smash', AppColors.error),
                  _buildLegendItem('Footwork', AppColors.success),
                  _buildLegendItem('Defense', AppColors.warning),
                  _buildLegendItem('Stamina', AppColors.purple),
                ],
              ),

              SizedBox(height: 16),

              // Multi-line Chart using fl_chart
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(
                        showTitles: true,
                        getTitles: (value) => value.toInt().toString(),
                        reservedSize: 30,
                      ),
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (value) => _getDateLabel(value.toInt()),
                        reservedSize: 30,
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minY: 0,
                    maxY: 5,
                    lineBarsData: [
                      // Serve line
                      LineChartBarData(
                        spots: _getSkillSpots('serve'),
                        isCurved: true,
                        colors: [AppColors.accent],
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      // Smash line
                      LineChartBarData(
                        spots: _getSkillSpots('smash'),
                        isCurved: true,
                        colors: [AppColors.error],
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      // Footwork line
                      LineChartBarData(
                        spots: _getSkillSpots('footwork'),
                        isCurved: true,
                        colors: [AppColors.success],
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      // Defense line
                      LineChartBarData(
                        spots: _getSkillSpots('defense'),
                        isCurved: true,
                        colors: [AppColors.warning],
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      // Stamina line
                      LineChartBarData(
                        spots: _getSkillSpots('stamina'),
                        isCurved: true,
                        colors: [AppColors.purple],
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      SizedBox(height: 24),

      // Performance History Section
      Text('Performance History', style: heading3),
      SizedBox(height: 12),

      performanceRecords.isEmpty
          ? _buildEmptyState('No performance records yet')
          : ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: performanceRecords.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildPerformanceHistoryCard(performanceRecords[index]);
              },
            ),
    ],
  ),
)
```

**Skill Card Component**:
```dart
Widget _buildSkillCard(String skillName, double rating, IconData icon, Color color) {
  final trend = _calculateTrend(skillName);  // Compare last 2 records

  return NeumorphicContainer(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          SizedBox(width: 16),

          // Skill Name & Stars
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skillName, style: bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.round() ? Icons.star : Icons.star_border,
                      color: color,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
          ),

          // Rating Value & Trend
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: heading2.copyWith(color: color),
              ),
              if (trend != 0) ...[
                Row(
                  children: [
                    Icon(
                      trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: trend > 0 ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                    Text(
                      '${trend.abs().toStringAsFixed(1)}',
                      style: bodySmall.copyWith(
                        color: trend > 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
```

**Performance History Card**:
```dart
Widget _buildPerformanceHistoryCard(PerformanceRecord record) {
  return NeumorphicContainer(
    child: InkWell(
      onTap: () => _showPerformanceDetails(record),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Average
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM, yyyy').format(record.date),
                  style: bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_calculateRecordAverage(record).toStringAsFixed(1)}/5',
                  style: heading3.copyWith(color: AppColors.success),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Skill ratings (compact view)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildSkillChip('S', record.serveRating, AppColors.accent),
                _buildSkillChip('Sm', record.smashRating, AppColors.error),
                _buildSkillChip('F', record.footworkRating, AppColors.success),
                _buildSkillChip('D', record.defenseRating, AppColors.warning),
                _buildSkillChip('St', record.staminaRating, AppColors.purple),
              ],
            ),

            if (record.comments != null && record.comments!.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Coach\'s Comments:',
                style: bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 4),
              Text(
                record.comments!,
                style: bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
```

**Design Reference**: Combine visualization from [performance_tracking_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/performance_tracking_screen.dart) with student-focused READ-ONLY view

**Estimated LOC**: ~800

---

### Screen 6: Student BMI Screen

**File**: `lib/screens/student/student_bmi_screen.dart`

**Purpose**: View BMI history, health status, and trend chart (READ-ONLY)

**Database Query**:
```sql
SELECT * FROM bmi_records
WHERE student_id = {student_id}
ORDER BY date DESC
```

**API Call**:
```dart
// Get all BMI records
final bmiRecords = await ref.read(bmiServiceProvider).getBmiRecords(
  studentId: studentId,
);

// Latest BMI
final latestBmi = bmiRecords.isNotEmpty ? bmiRecords.first : null;

// Health status determination
String healthStatus = 'Normal';
Color statusColor = AppColors.success;
if (latestBmi != null) {
  if (latestBmi.bmi < 18.5) {
    healthStatus = 'Underweight';
    statusColor = AppColors.warning;
  } else if (latestBmi.bmi >= 25 && latestBmi.bmi < 30) {
    healthStatus = 'Overweight';
    statusColor = AppColors.warning;
  } else if (latestBmi.bmi >= 30) {
    healthStatus = 'Obese';
    statusColor = AppColors.error;
  }
}
```

**UI Components**:
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Latest BMI Card
      NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Current BMI', style: heading3),
              SizedBox(height: 16),

              // BMI Value
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    latestBmi?.bmi.toStringAsFixed(1) ?? '--',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Health Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  healthStatus.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Last Recorded
              if (latestBmi != null)
                Text(
                  'Recorded on ${DateFormat('dd MMM, yyyy').format(latestBmi.date)}',
                  style: bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ),

      SizedBox(height: 24),

      // Health Guidelines Card
      NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WHO BMI Guidelines', style: heading3),
              SizedBox(height: 12),

              _buildGuidelineRow('Underweight', '< 18.5', AppColors.warning),
              _buildGuidelineRow('Normal', '18.5 - 24.9', AppColors.success),
              _buildGuidelineRow('Overweight', '25 - 29.9', AppColors.warning),
              _buildGuidelineRow('Obese', '≥ 30', AppColors.error),
            ],
          ),
        ),
      ),

      SizedBox(height: 24),

      // BMI Trend Chart
      Text('BMI Trend', style: heading3),
      SizedBox(height: 12),

      NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 250,
            child: bmiRecords.isEmpty
                ? Center(child: Text('No BMI records yet'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => value.toInt().toString(),
                          reservedSize: 35,
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => _getDateLabel(value.toInt()),
                          reservedSize: 30,
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      minY: 15,
                      maxY: 35,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getBmiSpots(),
                          isCurved: true,
                          colors: [AppColors.accent],
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      // Add horizontal lines for BMI thresholds
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(y: 18.5, color: AppColors.warning.withOpacity(0.5)),
                          HorizontalLine(y: 25, color: AppColors.warning.withOpacity(0.5)),
                          HorizontalLine(y: 30, color: AppColors.error.withOpacity(0.5)),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),

      SizedBox(height: 24),

      // BMI History Table
      Text('BMI History', style: heading3),
      SizedBox(height: 12),

      bmiRecords.isEmpty
          ? _buildEmptyState('No BMI records yet')
          : NeumorphicContainer(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Height (cm)')),
                    DataColumn(label: Text('Weight (kg)')),
                    DataColumn(label: Text('BMI')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: bmiRecords.map((record) {
                    final status = _getHealthStatus(record.bmi);
                    final statusColor = _getStatusColor(record.bmi);

                    return DataRow(
                      cells: [
                        DataCell(Text(DateFormat('dd MMM').format(record.date))),
                        DataCell(Text(record.height.toStringAsFixed(1))),
                        DataCell(Text(record.weight.toStringAsFixed(1))),
                        DataCell(
                          Text(
                            record.bmi.toStringAsFixed(1),
                            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

      SizedBox(height: 24),

      // Health Recommendations
      if (latestBmi != null) ...[
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Health Recommendations', style: heading3),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  _getRecommendations(latestBmi.bmi),
                  style: bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
)
```

**Helper Methods**:
```dart
String _getRecommendations(double bmi) {
  if (bmi < 18.5) {
    return 'You are underweight. Consider:\n'
        '• Increasing calorie intake with nutritious foods\n'
        '• Consulting a nutritionist for a proper diet plan\n'
        '• Regular strength training exercises';
  } else if (bmi >= 18.5 && bmi < 25) {
    return 'Your BMI is in the healthy range. Keep up the good work!\n'
        '• Maintain a balanced diet\n'
        '• Continue regular physical activity\n'
        '• Stay hydrated';
  } else if (bmi >= 25 && bmi < 30) {
    return 'You are slightly overweight. Consider:\n'
        '• Adopting a balanced, calorie-controlled diet\n'
        '• Increasing physical activity (30 mins daily)\n'
        '• Avoiding sugary and processed foods';
  } else {
    return 'Your BMI indicates obesity. Recommendations:\n'
        '• Consult a healthcare professional\n'
        '• Create a structured diet and exercise plan\n'
        '• Focus on gradual, sustainable weight loss';
  }
}

List<FlSpot> _getBmiSpots() {
  return bmiRecords.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), entry.value.bmi);
  }).toList().reversed.toList();
}
```

**Design Reference**: Similar to [bmi_tracking_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/bmi_tracking_screen.dart) but READ-ONLY with health recommendations

**Estimated LOC**: ~600

---

### Screen 7: Student Announcements Screen

**File**: `lib/screens/student/student_announcements_screen.dart`

**Purpose**: View announcements targeted to students (same as Coach Announcements)

**Database Query**:
```sql
SELECT * FROM announcements
WHERE target_audience IN ('all', 'students')
ORDER BY created_at DESC
```

**API Call**:
```dart
// Get all announcements
final announcements = await ref.read(announcementServiceProvider).getAnnouncements();

// Filter for students (client-side)
final studentAnnouncements = announcements.where((a) {
  return a.targetAudience == 'all' || a.targetAudience == 'students';
}).toList();
```

**UI Components**: Same as [Coach Announcements Screen](#screen-5-coach-announcements-screen), just filter for "students" instead of "coaches"

**Design Reference**: Exact copy of coach_announcements_screen.dart with audience filter changed

**Estimated LOC**: ~450

---

### Screen 8: Student Schedule Screen

**File**: `lib/screens/student/student_schedule_screen.dart`

**Purpose**: View upcoming sessions for enrolled batches

**Database Query**:
```sql
-- Get student's enrolled batches
SELECT b.id FROM batches b
JOIN batch_enrollments be ON b.id = be.batch_id
WHERE be.student_id = {student_id} AND be.is_active = TRUE

-- Get sessions for those batches
SELECT s.*, b.name as batch_name, c.name as coach_name
FROM schedules s
JOIN batches b ON s.batch_id = b.id
JOIN coaches c ON s.coach_id = c.id
WHERE s.batch_id IN (student_batch_ids)
ORDER BY s.date, s.start_time
```

**API Calls**:
```dart
// Get enrolled batches
final student = await ref.read(studentServiceProvider).getStudent(studentId);
final batches = await ref.read(batchServiceProvider).getStudentBatches(studentId);
final batchIds = batches.map((b) => b.id).toList();

// Get sessions for all enrolled batches
List<Schedule> allSessions = [];
for (var batchId in batchIds) {
  final sessions = await ref.read(scheduleServiceProvider).getSchedules(batchId: batchId);
  allSessions.addAll(sessions);
}

// Separate upcoming and past
final now = DateTime.now();
final upcomingSessions = allSessions.where((s) => s.date.isAfter(now) || s.date.isAtSameMomentAs(now)).toList();
final pastSessions = allSessions.where((s) => s.date.isBefore(now)).toList();

// Sort
upcomingSessions.sort((a, b) => a.date.compareTo(b.date));
pastSessions.sort((a, b) => b.date.compareTo(a.date));
```

**UI Components**: Same structure as [Coach Schedule Screen](#screen-7-coach-schedule-screen-optional-but-recommended)

**Design Reference**: Exact copy of coach_schedule_screen.dart but with student's enrolled batches

**Estimated LOC**: ~500

---

### Screen 9: Student Profile Screen

**File**: `lib/screens/student/student_profile_screen.dart`

**Purpose**: View and edit student profile (extends profile_completion_screen.dart)

**Database Query**:
```sql
-- Get student profile
SELECT * FROM students WHERE id = {student_id}

-- Update student profile
UPDATE students
SET name = {name}, phone = {phone}, date_of_birth = {dob},
    address = {address}, guardian_name = {guardian_name},
    guardian_phone = {guardian_phone}, medical_conditions = {medical},
    t_shirt_size = {size}, profile_photo = {photo_url}
WHERE id = {student_id}
```

**API Calls**:
```dart
// Get student profile
final student = await ref.read(studentServiceProvider).getStudent(studentId);

// Update profile
await ref.read(studentServiceProvider).updateStudent(studentId, {
  'name': _nameController.text,
  'phone': _phoneController.text,
  'date_of_birth': _selectedDob.toIso8601String(),
  'age': _calculateAge(_selectedDob),
  'address': _addressController.text,
  'guardian_name': _guardianNameController.text,
  'guardian_phone': _guardianPhoneController.text,
  'medical_conditions': _medicalController.text,
  't_shirt_size': _selectedSize,
  'profile_photo': _profilePhotoUrl,
});

// Upload profile photo
if (_selectedImage != null) {
  _profilePhotoUrl = await ref.read(apiServiceProvider).uploadImage(_selectedImage);
}
```

**UI Components**: Extended version of [profile_completion_screen.dart](../Flutter_Frontend/Badminton/lib/screens/student/profile_completion_screen.dart)

```dart
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      // Profile Photo
      Center(
        child: Stack(
          children: [
            CachedProfileImage(imageUrl: _profilePhotoUrl, radius: 60),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: 32),

      // Personal Information
      _buildSectionHeader('Personal Information'),

      CustomTextField(
        controller: _nameController,
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person),
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _emailController,
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        enabled: false, // Read-only
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _phoneController,
        labelText: 'Phone Number',
        prefixIcon: Icon(Icons.phone),
        keyboardType: TextInputType.phone,
      ),

      SizedBox(height: 16),

      // Date of Birth Picker
      InkWell(
        onTap: _selectDob,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: Icon(Icons.cake),
          ),
          child: Text(
            _selectedDob != null
                ? DateFormat('dd MMM, yyyy').format(_selectedDob!)
                : 'Select date',
          ),
        ),
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _addressController,
        labelText: 'Address',
        prefixIcon: Icon(Icons.home),
        maxLines: 3,
      ),

      SizedBox(height: 32),

      // Guardian Information
      _buildSectionHeader('Guardian Information'),

      CustomTextField(
        controller: _guardianNameController,
        labelText: 'Guardian Name',
        prefixIcon: Icon(Icons.person_outline),
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _guardianPhoneController,
        labelText: 'Guardian Phone',
        prefixIcon: Icon(Icons.phone_android),
        keyboardType: TextInputType.phone,
      ),

      SizedBox(height: 32),

      // Medical Information
      _buildSectionHeader('Medical Information'),

      CustomTextField(
        controller: _medicalController,
        labelText: 'Medical Conditions (if any)',
        prefixIcon: Icon(Icons.local_hospital),
        maxLines: 3,
        hintText: 'e.g., Asthma, Allergies',
      ),

      SizedBox(height: 32),

      // Other Details
      _buildSectionHeader('Other Details'),

      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'T-Shirt Size',
          prefixIcon: Icon(Icons.checkroom),
        ),
        value: _selectedSize,
        items: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'].map((size) {
          return DropdownMenuItem(value: size, child: Text(size));
        }).toList(),
        onChanged: (value) => setState(() => _selectedSize = value),
      ),

      SizedBox(height: 32),

      // Enrollment Information (Read-only)
      _buildSectionHeader('Enrollment Information'),

      NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoRow('Enrolled Batches', '${_enrolledBatches.length}'),
              Divider(),
              _buildInfoRow('Member Since', _formatDate(_student.createdAt)),
              Divider(),
              _buildInfoRow('Student ID', '${_student.id}'),
            ],
          ),
        ),
      ),

      SizedBox(height: 32),

      // Save Button
      NeumorphicButton(
        onPressed: _saveProfile,
        isLoading: _isSaving,
        child: Text('Save Changes'),
      ),

      SizedBox(height: 16),

      // Change Password
      _buildSectionHeader('Change Password'),

      CustomTextField(
        controller: _currentPasswordController,
        labelText: 'Current Password',
        prefixIcon: Icon(Icons.lock),
        obscureText: true,
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _newPasswordController,
        labelText: 'New Password',
        prefixIcon: Icon(Icons.lock_outline),
        obscureText: true,
      ),

      SizedBox(height: 16),

      CustomTextField(
        controller: _confirmPasswordController,
        labelText: 'Confirm New Password',
        prefixIcon: Icon(Icons.lock_outline),
        obscureText: true,
      ),

      SizedBox(height: 16),

      NeumorphicButton(
        onPressed: _changePassword,
        isLoading: _isChangingPassword,
        child: Text('Change Password'),
      ),
    ],
  ),
)
```

**Design Reference**: Extends [profile_completion_screen.dart](../Flutter_Frontend/Badminton/lib/screens/student/profile_completion_screen.dart) with additional sections and change password

**Estimated LOC**: ~500

---

## Common Features Across All Portals

These features must be implemented consistently across Owner, Coach, and Student portals:

### 1. Dark Mode / Light Mode Toggle

**Implementation**: Already exists in Owner portal via `theme_provider.dart`

**Location**: Settings or Profile screen (More menu)

**Database**: Store preference in `local_storage` (shared_preferences)

**Code**:
```dart
// In profile/settings screen
class ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return SwitchListTile(
      title: Text('Dark Mode'),
      subtitle: Text('Switch between light and dark themes'),
      value: isDarkMode,
      onChanged: (value) {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
    );
  }
}
```

**Apply to**:
- Owner Portal: ✅ Already implemented
- Coach Portal: ❌ Need to add
- Student Portal: ❌ Need to add

---

### 2. Push Notifications (FCM)

**Implementation**: Firebase Cloud Messaging integration

**Database**: Store FCM token in `coaches` and `students` tables

**Table Updates**:
```sql
ALTER TABLE coaches ADD COLUMN fcm_token VARCHAR(255);
ALTER TABLE students ADD COLUMN fcm_token VARCHAR(255);
```

**Code**:
```dart
// Initialize FCM
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize(int userId, String userType) async {
    // Request permission
    await _fcm.requestPermission();

    // Get token
    String? token = await _fcm.getToken();

    // Save to backend
    if (token != null) {
      if (userType == 'coach') {
        await apiService.put('/api/coaches/$userId', data: {'fcm_token': token});
      } else if (userType == 'student') {
        await apiService.put('/api/students/$userId', data: {'fcm_token': token});
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  void _showNotification(RemoteMessage message) {
    // Show in-app notification banner
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate based on notification type
    final type = message.data['type'];
    if (type == 'announcement') {
      Get.toNamed('/announcements');
    } else if (type == 'fee_due') {
      Get.toNamed('/fees');
    }
  }
}
```

**Notification Types**:
1. **Announcements**: When new announcement is created
2. **Fee Due**: When fee due date approaches
3. **Attendance**: When attendance is marked
4. **Performance**: When performance record is added
5. **Session**: Reminder for upcoming session

**Apply to**:
- Owner Portal: ✅ Token storage exists
- Coach Portal: ❌ Need to implement FCM
- Student Portal: ❌ Need to implement FCM

---

### 3. Pull-to-Refresh

**Implementation**: `RefreshIndicator` widget on all list views

**Code**:
```dart
RefreshIndicator(
  onRefresh: _loadData,
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ItemCard(item: items[index]),
  ),
)

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    // API call
    final data = await ref.read(serviceProvider).getData();
    setState(() => _items = data);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**Apply to**:
- Owner Portal: ✅ Partially implemented
- Coach Portal: ❌ Need to add everywhere
- Student Portal: ❌ Need to add everywhere

---

### 4. Loading States

**Implementation**: Show spinner during API calls

**Code**:
```dart
// Full-screen loading
if (_isLoading) {
  return LoadingSpinner();
}

// Inline loading
NeumorphicButton(
  onPressed: _isSaving ? null : _save,
  isLoading: _isSaving,
  child: Text('Save'),
)
```

**Apply to**:
- Owner Portal: ✅ Implemented
- Coach Portal: ❌ Need to add
- Student Portal: ❌ Need to add

---

### 5. Empty States

**Implementation**: Show message when no data

**Code**:
```dart
Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 64, color: AppColors.textSecondary),
        SizedBox(height: 16),
        Text(message, style: bodyLarge.copyWith(color: AppColors.textSecondary)),
      ],
    ),
  );
}

// Usage
items.isEmpty
  ? _buildEmptyState('No batches found')
  : ListView.builder(...)
```

**Apply to**:
- Owner Portal: ✅ Partially implemented
- Coach Portal: ❌ Need to add everywhere
- Student Portal: ❌ Need to add everywhere

---

### 6. Error Handling

**Implementation**: Show error messages with retry

**Code**:
```dart
// Error state
if (_hasError) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: AppColors.error),
        SizedBox(height: 16),
        Text('Failed to load data', style: bodyLarge),
        SizedBox(height: 8),
        Text(_errorMessage, style: bodySmall.copyWith(color: AppColors.textSecondary)),
        SizedBox(height: 16),
        NeumorphicButton(
          onPressed: _retry,
          child: Text('Retry'),
        ),
      ],
    ),
  );
}

// Error toast
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
    ),
  );
}

// Success toast
void _showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.success,
    ),
  );
}
```

**Apply to**:
- Owner Portal: ✅ Partially implemented
- Coach Portal: ❌ Need to add everywhere
- Student Portal: ❌ Need to add everywhere

---

### 7. Logout Functionality

**Implementation**: Clear auth state and navigate to login

**Code**:
```dart
Future<void> _logout() async {
  // Show confirmation dialog
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Logout'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    // Clear auth
    await ref.read(authProvider.notifier).logout();

    // Navigate to role selection
    context.go('/role-selection');
  }
}

// In Profile/More screen
ListTile(
  leading: Icon(Icons.logout, color: AppColors.error),
  title: Text('Logout', style: TextStyle(color: AppColors.error)),
  onTap: _logout,
)
```

**Apply to**:
- Owner Portal: ✅ Implemented
- Coach Portal: ❌ Need to add in profile screen
- Student Portal: ❌ Need to add in profile screen

---

## API Integration Guide

### API Service Structure

All portals use the same `ApiService` with automatic token management:

```dart
class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: 30000,
    receiveTimeout: 30000,
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token
        final token = await StorageService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          // Token expired, logout
          await authProvider.logout();
        }
        handler.next(error);
      },
    ));
  }

  // Generic methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
```

### API Endpoints Reference

**Base URL**: `http://localhost:8000` (development) / `https://api.yourdomain.com` (production)

#### Authentication
- POST `/coaches/login` - Coach login
- POST `/students/login` - Student login
- POST `/api/coaches/` - Register coach
- POST `/api/students/` - Register student

#### Coaches
- GET `/api/coaches/` - List all coaches
- GET `/api/coaches/{id}` - Get coach by ID
- PUT `/api/coaches/{id}` - Update coach
- DELETE `/api/coaches/{id}` - Delete coach

#### Students
- GET `/api/students/` - List all students
- GET `/api/students/{id}` - Get student by ID
- PUT `/api/students/{id}` - Update student
- DELETE `/api/students/{id}` - Delete student

#### Batches
- GET `/api/batches/` - List all batches
- GET `/api/batches/?coach_id={id}` - Get coach's batches
- GET `/api/batches/{id}/students` - Get students in batch

#### Attendance
- GET `/api/attendance/?student_id={id}` - Student's attendance
- GET `/api/attendance/?batch_id={id}&date={date}` - Batch attendance for date
- POST `/api/attendance/` - Mark attendance

#### Fees
- GET `/api/fees/?student_id={id}` - Student's fees
- GET `/api/fee-payments/?fee_id={id}` - Payments for fee

#### Performance
- GET `/api/performance/?student_id={id}` - Student's performance records

#### BMI
- GET `/api/bmi-records/?student_id={id}` - Student's BMI records

#### Schedules
- GET `/api/schedules/?coach_id={id}` - Coach's sessions
- GET `/api/schedules/?batch_id={id}` - Batch sessions

#### Announcements
- GET `/api/announcements/` - All announcements

---

## Implementation Checklist

### Coach Portal

- [ ] **Screen 1**: Coach Dashboard (container with bottom nav)
- [ ] **Screen 2**: Coach Home Screen (overview)
- [ ] **Screen 3**: Coach Batches Screen (view assigned batches)
- [ ] **Screen 4**: Coach Attendance Screen (mark attendance) 🔥 **CRITICAL**
- [ ] **Screen 5**: Coach Announcements Screen (view announcements)
- [ ] **Screen 6**: Coach Profile Screen (edit profile)
- [ ] **Screen 7**: Coach Schedule Screen (view sessions) [Optional]
- [ ] **Common**: Dark mode toggle
- [ ] **Common**: Push notifications (FCM)
- [ ] **Common**: Pull-to-refresh on all lists
- [ ] **Common**: Loading/empty/error states
- [ ] **Common**: Logout functionality

**Estimated Total**: 7 screens, ~3,100 LOC, 2-3 weeks

---

### Student Portal

- [ ] **Screen 1**: Student Dashboard (container with bottom nav)
- [ ] **Screen 2**: Student Home Screen (overview)
- [ ] **Screen 3**: Student Attendance Screen (view history with charts)
- [ ] **Screen 4**: Student Fees Screen (view fee status)
- [ ] **Screen 5**: Student Performance Screen (view performance with charts) 🔥 **CRITICAL**
- [ ] **Screen 6**: Student BMI Screen (view BMI with trend chart)
- [ ] **Screen 7**: Student Announcements Screen (view announcements)
- [ ] **Screen 8**: Student Schedule Screen (view upcoming sessions)
- [ ] **Screen 9**: Student Profile Screen (edit profile)
- [ ] **Common**: Dark mode toggle
- [ ] **Common**: Push notifications (FCM)
- [ ] **Common**: Pull-to-refresh on all lists
- [ ] **Common**: Loading/empty/error states
- [ ] **Common**: Logout functionality

**Estimated Total**: 9 screens, ~4,900 LOC, 3-4 weeks

---

### Testing Checklist

After implementation, test these scenarios:

#### Coach Portal
- [ ] Coach login → lands on dashboard
- [ ] View assigned batches (not all batches)
- [ ] Mark attendance for own batch
- [ ] Try to mark attendance for unassigned batch (should fail)
- [ ] View today's schedule
- [ ] View announcements
- [ ] Edit profile and change password
- [ ] Logout and re-login

#### Student Portal
- [ ] Student login → lands on dashboard
- [ ] View attendance history and percentage
- [ ] View fee status (paid/pending/overdue)
- [ ] View performance records with charts
- [ ] View BMI history with trend
- [ ] View announcements
- [ ] View upcoming sessions
- [ ] Edit profile
- [ ] Logout and re-login

#### Cross-Role Testing
- [ ] Owner marks attendance → Student sees it
- [ ] Owner records performance → Student sees it
- [ ] Owner adds announcement (to students) → Student sees it
- [ ] Owner adds announcement (to coaches) → Coach sees it
- [ ] Owner creates session → Coach and Student see it
- [ ] Coach marks attendance → Student sees it
- [ ] Database updates reflect across all portals

---

## Summary

### Total Screens to Implement

| Portal | Screens | LOC | Time Estimate |
|--------|---------|-----|---------------|
| **Coach Portal** | 7 | ~3,100 | 2-3 weeks |
| **Student Portal** | 9 | ~4,900 | 3-4 weeks |
| **TOTAL** | **16** | **~8,000** | **5-7 weeks** |

### Key Design Principles

1. **Consistency**: Use exact same neumorphic design as Owner portal
2. **Database**: All data from shared PostgreSQL database
3. **Role-Based**: Coaches see only assigned batches, Students see only their data
4. **Features**: Dark mode, notifications, pull-to-refresh, error handling
5. **API**: All backend endpoints ready and tested

### Priority Order

**Week 1-3**: Coach Portal
- Start with dashboard and home screen
- **Week 2 priority**: Attendance screen (most critical)
- Then batches, profile, announcements

**Week 4-7**: Student Portal
- Start with dashboard and home screen
- **Week 5 priority**: Attendance and fees screens
- **Week 6 priority**: Performance and BMI screens (with charts)
- Finish with announcements, schedule, profile

### Next Steps

1. ✅ Read this document thoroughly
2. ⏭️ Set up development environment
3. ⏭️ Start with Coach Dashboard container
4. ⏭️ Implement Coach screens one by one
5. ⏭️ Test thoroughly with real data
6. ⏭️ Move to Student Portal
7. ⏭️ Final integration testing

---

**Document Version**: 1.0
**Last Updated**: January 14, 2026
**Author**: Claude Sonnet 4.5
**Project**: Badminton Academy Management System

**Status**: Ready for Implementation 🚀