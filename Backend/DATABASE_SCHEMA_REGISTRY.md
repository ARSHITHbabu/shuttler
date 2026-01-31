# Database Schema Registry

> **IMPORTANT**: This file tracks ALL database tables in the project, including those that may be temporarily commented out or archived. Before creating a new table, check this registry to see if a similar table already exists.

**Last Updated**: 2026-01-31 (Auto-generated)  
**Database**: PostgreSQL (`badminton_academy`)  
**ORM**: SQLAlchemy (models in `Backend/main.py`)

---

## Orphaned Tables (Exist in DB but NOT in Code)

> **These tables exist in the database but have no corresponding model in `main.py`.**
> **They may have been created during development and then the code was reverted.**
> **Consider reusing these tables instead of creating new ones!**

- **`requests`** - **ORPHANED**: Exists in database but no model in code

**Action Required**: Either:
1. Add a model for these tables in `main.py` if you want to use them
2. Drop these tables if they're no longer needed
3. Move them to 'Archived Tables' section if temporarily disabled

---

## Active Tables (Defined in Code)

### Core User Tables

### Core User Tables
- **`coaches`** - No description
- **`owners`** - Separate table for academy owners
- **`students`** - No description

### Session & Batch Management
- **`sessions`** - Session/Season entity that groups multiple batches
- **`batches`** - No description
- **`batch_students`** - No description
- **`batch_coaches`** - No description

### Attendance & Performance
- **`attendance`** - No description
- **`coach_attendance`** - No description
- **`performance`** - No description
- **`bmi_records`** - No description

### Financial
- **`fees`** - No description
- **`fee_payments`** - No description

### Communication & Invitations
- **`invitations`** - No description
- **`coach_invitations`** - Invitations for coaches - sent by owners
- **`announcements`** - Announcements for students, coaches, or all users
- **`notifications`** - User notifications with push notification support

### Calendar & Events
- **`calendar_events`** - Calendar events: holidays, tournaments, in-house events, leave
- **`leave_requests`** - Leave requests from coaches

### Content & Resources
- **`schedules`** - No description
- **`tournaments`** - No description
- **`video_resources`** - No description
- **`enquiries`** - No description

### Registration & Requests
- **`student_registration_requests`** - Student registration requests awaiting owner approval

---

## Archived/Temporary Tables

> Tables listed here were created during development but may be temporarily disabled or archived. They can be reused instead of creating new ones.

*(Manually add archived tables here when you temporarily disable them)*

**Example:**
- ~~`old_notifications`~~ - Archived 2026-01-15, replaced by `notifications` table

---

## Quick Reference

| Table Name | Purpose | Model Class | Status |
|-----------|---------|-------------|--------|
| `announcements` | Announcements for students, coaches, or all users | `AnnouncementDB` | Active |
| `attendance` | No description | `AttendanceDB` | Active |
| `batch_coaches` | No description | `BatchCoachDB` | Active |
| `batch_students` | No description | `BatchStudentDB` | Active |
| `batches` | No description | `BatchDB` | Active |
| `bmi_records` | No description | `BMIDB` | Active |
| `calendar_events` | Calendar events: holidays, tournaments, in-hous... | `CalendarEventDB` | Active |
| `coach_attendance` | No description | `CoachAttendanceDB` | Active |
| `coach_invitations` | Invitations for coaches - sent by owners | `CoachInvitationDB` | Active |
| `coaches` | No description | `CoachDB` | Active |
| `enquiries` | No description | `EnquiryDB` | Active |
| `fee_payments` | No description | `FeePaymentDB` | Active |
| `fees` | No description | `FeeDB` | Active |
| `invitations` | No description | `InvitationDB` | Active |
| `leave_requests` | Leave requests from coaches | `LeaveRequestDB` | Active |
| `notifications` | User notifications with push notification support | `NotificationDB` | Active |
| `owners` | Separate table for academy owners | `OwnerDB` | Active |
| `performance` | No description | `PerformanceDB` | Active |
| `schedules` | No description | `ScheduleDB` | Active |
| `sessions` | Session/Season entity that groups multiple batches | `SessionDB` | Active |
| `student_registration_requests` | Student registration requests awaiting owner ap... | `StudentRegistrationRequestDB` | Active |
| `students` | No description | `StudentDB` | Active |
| `tournaments` | No description | `TournamentDB` | Active |
| `video_resources` | No description | `VideoResourceDB` | Active |
| `requests` | Orphaned (no model) | *None* | Orphaned |

---

## Usage Guidelines

1. **Before creating a new table**: 
   - Search this registry for similar tables
   - Check the "Orphaned Tables" section - you might be able to reuse one!

2. **When archiving a table**: 
   - Move it to the "Archived/Temporary Tables" section with a date
   - Comment out the model in `main.py` but keep the table in DB

3. **When re-enabling a table**: 
   - Move it back to "Active Tables" and update the date
   - Uncomment the model in `main.py`

4. **For orphaned tables**:
   - If you want to use them: Add a model in `main.py` and move to "Active Tables"
   - If not needed: Drop the table from database
   - If temporarily disabled: Move to "Archived Tables" section

5. **Keep this file updated**: 
   - Run `python generate_schema_registry.py` after schema changes
   - Or manually update when you create/modify tables

---

## Statistics

- **Total tables in database**: 25
- **Tables with models in code**: 24
- **Orphaned tables**: 1

**WARNING**: 1 table(s) exist in database but have no model in code!
