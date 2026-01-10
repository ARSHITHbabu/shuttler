# Quick Start: PostgreSQL Migration

## What You Need to Do

### 1. Install PostgreSQL (if not done yet)
1. Download from: https://www.postgresql.org/download/windows/
2. Install with default settings
3. **Remember the password** you set for `postgres` user
4. After installation, open **pgAdmin 4**

### 2. Create Database
In pgAdmin or psql, run:
```sql
CREATE DATABASE badminton_academy;
```

### 3. Update .env File
Open `Reference/sample/.env` and change `password` to your actual PostgreSQL password:
```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD_HERE@localhost:5432/badminton_academy
```

### 4. Install Python Dependencies
Open terminal in `Reference/sample/` folder:
```bash
pip install -r requirements.txt
```

### 5. Update main.py
Follow the detailed instructions in `MIGRATION_GUIDE.md` to update:
- Database connection (Part 1)
- Add new models (Part 2)
- Add Pydantic models (Part 3)
- Add API endpoints (Part 4)
- Add image upload (Part 5)

**OR** I can create a completely new `main_updated.py` file for you to review before replacing the old one.

### 6. Test the Server
```bash
python main.py
```

Visit: http://localhost:8000/docs

---

## Files Created

✅ `requirements.txt` - Python dependencies
✅ `.env` - Your environment variables (UPDATE with your password!)
✅ `.env.example` - Template for others
✅ `.gitignore` - Prevents committing sensitive files
✅ `create_database.sql` - SQL script to create database
✅ `MIGRATION_GUIDE.md` - Detailed step-by-step migration instructions

---

## What Changed

### Database
- ❌ SQLite (single file, no concurrency)
- ✅ PostgreSQL (production-ready, 10k+ users)

### New Features Added
- ✅ Announcements (create, view, edit, delete)
- ✅ Notifications (push notification support)
- ✅ Calendar Events (holidays, tournaments, events)
- ✅ Profile Photos (students & coaches)
- ✅ Image Upload API

### New Database Tables
1. `announcements` - Announcements for students/coaches
2. `notifications` - User notifications
3. `calendar_events` - Holidays, tournaments, events

### Updated Tables
- `students` - Added `profile_photo`, `fcm_token` columns
- `coaches` - Added `profile_photo`, `fcm_token` columns

---

## Quick Test

After starting the server, test the new endpoints:

### Test Announcement API
```bash
curl -X POST http://localhost:8000/api/announcements/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Welcome",
    "message": "Hello everyone!",
    "target_audience": "all",
    "priority": "normal",
    "created_by": 1
  }'
```

### Test Calendar Event API
```bash
curl -X POST http://localhost:8000/api/calendar-events/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Holiday",
    "event_type": "holiday",
    "date": "2026-01-15",
    "description": "National Holiday",
    "created_by": 1
  }'
```

### Test Image Upload
Use Postman or Swagger UI to upload an image file to `/api/upload/image`

---

## Need Help?

Check `MIGRATION_GUIDE.md` for:
- Detailed code changes with line numbers
- Complete model definitions
- All endpoint implementations
- Troubleshooting section

---

## What's Next?

After migration is complete:
1. Set up Alembic for database migrations
2. Create seed data script
3. Test all endpoints thoroughly
4. Deploy to production (AWS RDS, Railway, etc.)
