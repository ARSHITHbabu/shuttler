# Backend Setup Guide

## What's in This Folder?

This is the **production-ready backend** for the Badminton Academy Management System, enhanced with:
- ✅ PostgreSQL database (supports 10k+ users)
- ✅ Announcements API
- ✅ Notifications system
- ✅ Calendar events
- ✅ Image upload for profile photos
- ✅ All existing features from the original backend

---

## Quick Start (5 Steps)

### Step 1: Install PostgreSQL
1. Download: https://www.postgresql.org/download/windows/
2. Install with default settings
3. Remember the password you set for `postgres` user
4. Open pgAdmin or psql and run:
   ```sql
   CREATE DATABASE badminton_academy;
   ```

### Step 2: Update .env File
Open `.env` and replace `password` with your PostgreSQL password:
```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD_HERE@localhost:5432/badminton_academy
```

### Step 3: Install Python Dependencies
```bash
cd Backend
pip install -r requirements.txt
```

### Step 4: Start the Server
```bash
python main.py
```

The server will start at: http://localhost:8000

### Step 5: Test the API
Open your browser: http://localhost:8000/docs

You should see the Swagger UI with all API endpoints!

---

## File Structure

```
Backend/
├── main.py                  # FastAPI application (ENHANCED)
├── requirements.txt         # Python dependencies
├── .env                     # Your environment variables (UPDATE THIS!)
├── .env.example             # Template for .env
├── .gitignore               # Git ignore rules
├── create_database.sql      # SQL script to create database
├── MIGRATION_GUIDE.md       # Detailed migration instructions
├── README.md                # This file
└── uploads/                 # Created automatically for image uploads
```

---

## What's New?

### 1. PostgreSQL Instead of SQLite
- **Before**: SQLite (single file, no concurrency)
- **After**: PostgreSQL (10k+ users, full concurrency)
- **Benefit**: Production-ready, scalable, cloud-ready

### 2. New Features Added

#### Announcements
- Create, view, edit, delete announcements
- Target specific audiences (all, students, coaches)
- Priority levels (normal, high, urgent)
- Schedule announcements for later

**API Endpoints:**
- `POST /api/announcements/` - Create
- `GET /api/announcements/` - List all
- `GET /api/announcements/{id}` - Get one
- `PUT /api/announcements/{id}` - Update
- `DELETE /api/announcements/{id}` - Delete

#### Notifications
- Send notifications to users
- Mark as read/unread
- Support for push notifications (FCM tokens)
- Notification types (fee_due, attendance, etc.)

**API Endpoints:**
- `POST /api/notifications/` - Create
- `GET /api/notifications/{user_id}` - Get user notifications
- `PUT /api/notifications/{id}/read` - Mark as read
- `DELETE /api/notifications/{id}` - Delete

#### Calendar Events
- Add holidays, tournaments, in-house events
- Color-coded by type
- Date-based filtering

**API Endpoints:**
- `POST /api/calendar-events/` - Create
- `GET /api/calendar-events/` - List (with date filters)
- `GET /api/calendar-events/{id}` - Get one
- `PUT /api/calendar-events/{id}` - Update
- `DELETE /api/calendar-events/{id}` - Delete

#### Image Upload
- Upload profile photos for students and coaches
- Automatic file validation
- Unique filenames to prevent conflicts

**API Endpoints:**
- `POST /api/upload/image` - Upload image
- `GET /uploads/{filename}` - Get uploaded image

### 3. Database Changes

**New Tables:**
- `announcements` - Store announcements
- `notifications` - Store user notifications
- `calendar_events` - Store events

**Updated Tables:**
- `students` - Added `profile_photo`, `fcm_token` columns
- `coaches` - Added `profile_photo`, `fcm_token` columns

---

## Testing the API

### Test Announcement
```bash
curl -X POST http://localhost:8000/api/announcements/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Welcome to the Academy!",
    "message": "We are excited to have you here.",
    "target_audience": "all",
    "priority": "normal",
    "created_by": 1
  }'
```

### Test Calendar Event
```bash
curl -X POST http://localhost:8000/api/calendar-events/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Republic Day",
    "event_type": "holiday",
    "date": "2026-01-26",
    "description": "National Holiday",
    "created_by": 1
  }'
```

### Test Image Upload
Use Postman or Swagger UI to upload an image to `/api/upload/image`

---

## Environment Variables

Edit `.env` file:

```env
# Database (REQUIRED - Update with your password!)
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/badminton_academy

# JWT (Optional - for authentication)
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Uploads (Optional - defaults shown)
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880
ALLOWED_EXTENSIONS=jpg,jpeg,png,gif,webp

# Server (Optional)
HOST=0.0.0.0
PORT=8000
DEBUG=True
```

---

## Troubleshooting

### Error: "could not connect to server"
**Solution**:
1. Make sure PostgreSQL service is running
2. Check password in `.env` file
3. Verify database name is `badminton_academy`

### Error: "No module named 'psycopg2'"
**Solution**: Run `pip install -r requirements.txt`

### Error: "relation does not exist"
**Solution**: Tables haven't been created yet
1. Make sure you're connected to PostgreSQL (check console output)
2. The tables should be created automatically on first run
3. If not, check for errors in the console

### Port 8000 already in use
**Solution**:
- Stop the other process using port 8000
- Or change PORT in `.env` file to something else (e.g., 8001)

---

## Production Deployment

### Cloud Database Options:
1. **AWS RDS PostgreSQL** - Fully managed, auto-scaling
2. **Google Cloud SQL** - Easy setup, high availability
3. **Railway.app** - Simple, $5/month
4. **Supabase** - PostgreSQL + real-time features, free tier

### Deployment Steps:
1. Create cloud PostgreSQL instance
2. Update `DATABASE_URL` in `.env` with cloud database URL
3. Deploy backend to:
   - **Railway** - `railway up`
   - **Heroku** - `git push heroku main`
   - **AWS/GCP** - Use Docker container

---

## API Documentation

Once the server is running:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

All endpoints are automatically documented!

---

## Need Help?

1. Check `MIGRATION_GUIDE.md` for detailed instructions
2. Look at code comments in `main.py`
3. Test endpoints in Swagger UI (http://localhost:8000/docs)

---

## Development Tips

### Enable SQL Query Logging
In `main.py`, change:
```python
echo=False  # Change to True
```

### Test with Sample Data
After backend is running, you can:
1. Use Swagger UI to create test data manually
2. Or we'll create a `seed_data.py` script to populate the database automatically

---

## Success Checklist

- [ ] PostgreSQL installed
- [ ] Database `badminton_academy` created
- [ ] `.env` file updated with correct password
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Server starts without errors
- [ ] http://localhost:8000/docs shows all endpoints
- [ ] Can create announcement via Swagger UI
- [ ] Can upload image via Swagger UI
- [ ] Can create calendar event via Swagger UI

---

## What's Next?

After backend is working:
1. **Phase 1**: Build Flutter frontend
2. **Phase 2**: Connect Flutter app to this backend
3. **Phase 3**: Deploy to production
4. **Phase 4**: Add coach and student portals

You're all set! 🚀
