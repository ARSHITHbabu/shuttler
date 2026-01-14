# Coach Portal - Final Sections (Append to Main Document)

## Profile, Settings, More Screens, and Implementation Guide

### 8. Coach Profile Screen

**Path**: `lib/screens/coach/coach_profile_screen.dart`

**Purpose**: View and edit coach profile

**Database Tables Used**:
- `users` (user account details)
- `coaches` (coach-specific details)

**API Endpoints**:
- `GET /api/coaches/{coach_id}` - Get coach profile
- `PUT /api/coaches/{coach_id}` - Update coach profile
- `PUT /api/users/{user_id}` - Update user account

**Key Features**:
- Profile image upload
- Edit personal details (name, email, phone, specialization)
- Change password
- View statistics (total students, batches, sessions)
- Profile completion indicator
- Save changes button
- Loading states
- Success/error feedback

**Estimated LOC**: ~400 lines

---

### 9. Coach Settings Screen

**Path**: `lib/screens/coach/coach_settings_screen.dart`

**Purpose**: App settings and preferences (mirrors owner settings)

**Key Features**:
- Push notifications toggle
- Theme toggle (dark mode / light mode with shuttlecock animation)
- App version info
- Help & Support
- Privacy Policy
- Terms & Conditions
- Clear cache
- Logout button

**Similar to Owner Settings**: Refer to owner/settings_screen.dart for implementation

**Estimated LOC**: ~300 lines

---

### 10. Coach More Screen

**Path**: `lib/screens/coach/coach_more_screen.dart`

**Purpose**: Navigation hub for additional features (4th tab in bottom nav)

**Key Features**:
- Section headers (Account, Features, App)
- Menu items with icons and chevrons
- Navigation to Profile, Announcements, Schedule, Settings
- Logout confirmation dialog
- Neumorphic design
- Destructive styling for logout

**Estimated LOC**: ~250 lines

---

## Summary of All Coach Portal Screens

| # | Screen Name | Path | LOC | Status | Priority |
|---|------------|------|-----|--------|----------|
| 1 | Login Screen | lib/screens/auth/login_screen.dart | ~320 | ✓ Exists | - |
| 2 | Coach Dashboard | lib/screens/coach/coach_dashboard.dart | ~150 | Not Impl. | HIGH |
| 3 | Coach Home | lib/screens/coach/coach_home_screen.dart | ~450 | Not Impl. | HIGH |
| 4 | Coach Batches | lib/screens/coach/coach_batches_screen.dart | ~550 | Not Impl. | HIGH |
| 5 | Coach Attendance | lib/screens/coach/coach_attendance_screen.dart | ~700 | Not Impl. | **CRITICAL** |
| 6 | Coach Announcements | lib/screens/coach/coach_announcements_screen.dart | ~450 | Not Impl. | MEDIUM |
| 7 | Coach Schedule | lib/screens/coach/coach_schedule_screen.dart | ~450 | Not Impl. | LOW |
| 8 | Coach Profile | lib/screens/coach/coach_profile_screen.dart | ~400 | Not Impl. | MEDIUM |
| 9 | Coach Settings | lib/screens/coach/coach_settings_screen.dart | ~300 | Not Impl. | MEDIUM |
| 10 | Coach More | lib/screens/coach/coach_more_screen.dart | ~250 | Not Impl. | HIGH |

**Total Estimated LOC**: ~4,020 lines (excluding login screen)

---

## Implementation Timeline

### Total Development Time: 5-6 Weeks

**Week 1**: Infrastructure & Setup (5 days)
- Services, providers, models, routing

**Week 2-3**: Core Screens (10 days)
- Dashboard, Home, Batches, Attendance, More

**Week 4**: Supporting Screens (5 days)
- Announcements, Schedule, Profile, Settings

**Week 5**: Testing & Polish (5 days)
- Unit tests, integration tests, UI polish

**Week 6**: Final Integration & Bug Fixes (5 days)
- Backend integration, end-to-end testing, deployment prep

---

## Critical Features

1. **Attendance Screen** is the MOST IMPORTANT feature
   - Coaches' primary use case is marking attendance
   - Must be reliable, fast, and easy to use
   - Support offline mode (future enhancement)

2. **Batches Screen** is second priority
   - Coaches need to see which batches they're assigned to
   - View student lists

3. **Home Screen** provides quick overview
   - Today's sessions
   - Quick stats
   - Quick actions

---

## READ-ONLY Constraints

Coaches have LIMITED permissions:
- ✅ CAN: View assigned batches
- ✅ CAN: View students in their batches
- ✅ CAN: Mark attendance
- ✅ CAN: View announcements
- ✅ CAN: View schedule
- ✅ CAN: Edit their own profile
- ❌ CANNOT: Create/edit/delete batches
- ❌ CANNOT: Add/remove students
- ❌ CANNOT: Create announcements
- ❌ CANNOT: View fees/payments
- ❌ CANNOT: View other coaches' data

---

## Dependencies Required

Add to `pubspec.yaml`:

```yaml
dependencies:
  # Calendar for Schedule Screen
  table_calendar: ^3.0.9
```

---

## Conclusion

This document provides complete implementation details for all 10 coach portal screens following the exact neumorphic design system from the owner portal.

**Total LOC**: ~4,020 lines
**Development Time**: 5-6 weeks
**Priority Order**: Attendance > Dashboard > Home > Batches > More > Others

All screens follow uniform design patterns ensuring visual consistency across the app.
