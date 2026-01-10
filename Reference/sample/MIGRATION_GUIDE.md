# PostgreSQL Migration & Backend Enhancement Guide

## Prerequisites

✅ PostgreSQL installed (15+ recommended)
✅ Created `badminton_academy` database
✅ Updated `.env` file with your PostgreSQL password
✅ Installed Python dependencies: `pip install -r requirements.txt`

---

## Part 1: Update Database Connection in main.py

### Step 1.1: Add imports at the top of main.py

**Find this line (around line 1-10):**
```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
```

**Add these new imports:**
```python
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, Text, Date, DateTime, ForeignKey, JSON, func
from sqlalchemy.orm import relationship

# Load environment variables
load_dotenv()
```

### Step 1.2: Update database connection (around line 10-14)

**Replace this:**
```python
# Database setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./academy_portal.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
```

**With this:**
```python
# Database setup - PostgreSQL
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

# Fallback to SQLite if DATABASE_URL not set (for backward compatibility during migration)
if not SQLALCHEMY_DATABASE_URL:
    print("WARNING: DATABASE_URL not found in .env, falling back to SQLite")
    SQLALCHEMY_DATABASE_URL = "sqlite:///./academy_portal.db"
    engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
else:
    # PostgreSQL connection with connection pooling
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL,
        pool_size=20,  # Number of connections to keep open
        max_overflow=40,  # Additional connections when pool is full
        pool_pre_ping=True,  # Test connections before using them
        echo=False  # Set to True for SQL query logging (development only)
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
```

---

## Part 2: Add New Database Models

### Step 2.1: Update Student Model (add profile_photo and fcm_token)

**Find the `StudentDB` class (around line 43-56) and add these columns:**
```python
class StudentDB(Base):
    __tablename__ = "students"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    guardian_name = Column(String, nullable=False)
    guardian_phone = Column(String, nullable=False)
    password = Column(String, nullable=False)
    added_by = Column(String, nullable=False)
    date_of_birth = Column(String, nullable=True)
    address = Column(Text, nullable=True)
    status = Column(String, default="active")

    # NEW COLUMNS:
    profile_photo = Column(String(500), nullable=True)  # Profile photo URL/path
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging token
```

### Step 2.2: Update Coach Model (add profile_photo, fcm_token, and relationships)

**Find the `CoachDB` class (around line 18-28) and update it:**
```python
class CoachDB(Base):
    __tablename__ = "coaches"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    phone = Column(String, nullable=False)
    password = Column(String, nullable=False)
    specialization = Column(String, nullable=True)
    experience_years = Column(Integer, nullable=True)
    status = Column(String, default="active")

    # NEW COLUMNS:
    profile_photo = Column(String(500), nullable=True)  # Profile photo URL/path
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging token

    # RELATIONSHIPS (for new tables):
    announcements = relationship("AnnouncementDB", back_populates="creator")
    calendar_events = relationship("CalendarEventDB", back_populates="creator")
```

### Step 2.3: Add Announcement Model

**Add this new model after `InvitationDB` (around line 164):**
```python
class AnnouncementDB(Base):
    __tablename__ = "announcements"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    target_audience = Column(String(50), default="all")  # "all", "students", "coaches"
    priority = Column(String(20), default="normal")  # "normal", "high", "urgent"
    created_by = Column(Integer, ForeignKey("coaches.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    scheduled_at = Column(DateTime(timezone=True), nullable=True)
    is_sent = Column(Boolean, default=False)

    # Relationship
    creator = relationship("CoachDB", back_populates="announcements")
```

### Step 2.4: Add Notification Model

**Add this after AnnouncementDB:**
```python
class NotificationDB(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    user_type = Column(String(20), nullable=False)  # "student", "coach", "owner"
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    type = Column(String(50), default="general")  # "fee_due", "attendance", "announcement", "general"
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    data = Column(JSON, nullable=True)  # Extra metadata as JSON
```

### Step 2.5: Add CalendarEvent Model

**Add this after NotificationDB:**
```python
class CalendarEventDB(Base):
    __tablename__ = "calendar_events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    event_type = Column(String(50), nullable=False)  # "holiday", "tournament", "event"
    date = Column(Date, nullable=False)
    description = Column(Text, nullable=True)
    created_by = Column(Integer, ForeignKey("coaches.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationship
    creator = relationship("CoachDB", back_populates="calendar_events")
```

---

## Part 3: Add Pydantic Models for New Tables

**Add these after the existing Pydantic models (search for "class InvitationDB" and add after its Pydantic models):**

```python
# ==================== Announcement Models ====================
class AnnouncementCreate(BaseModel):
    title: str
    message: str
    target_audience: str = "all"  # "all", "students", "coaches"
    priority: str = "normal"  # "normal", "high", "urgent"
    created_by: int
    scheduled_at: Optional[str] = None

class Announcement(BaseModel):
    id: int
    title: str
    message: str
    target_audience: str
    priority: str
    created_by: int
    created_at: str
    scheduled_at: Optional[str] = None
    is_sent: bool

    class Config:
        from_attributes = True

class AnnouncementUpdate(BaseModel):
    title: Optional[str] = None
    message: Optional[str] = None
    target_audience: Optional[str] = None
    priority: Optional[str] = None
    scheduled_at: Optional[str] = None
    is_sent: Optional[bool] = None

# ==================== Notification Models ====================
class NotificationCreate(BaseModel):
    user_id: int
    user_type: str  # "student", "coach", "owner"
    title: str
    body: str
    type: str = "general"  # "fee_due", "attendance", "announcement", "general"
    data: Optional[dict] = None

class Notification(BaseModel):
    id: int
    user_id: int
    user_type: str
    title: str
    body: str
    type: str
    is_read: bool
    created_at: str
    data: Optional[dict] = None

    class Config:
        from_attributes = True

class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None

# ==================== CalendarEvent Models ====================
class CalendarEventCreate(BaseModel):
    title: str
    event_type: str  # "holiday", "tournament", "event"
    date: str  # Format: "YYYY-MM-DD"
    description: Optional[str] = None
    created_by: int

class CalendarEvent(BaseModel):
    id: int
    title: str
    event_type: str
    date: str
    description: Optional[str] = None
    created_by: int
    created_at: str

    class Config:
        from_attributes = True

class CalendarEventUpdate(BaseModel):
    title: Optional[str] = None
    event_type: Optional[str] = None
    date: Optional[str] = None
    description: Optional[str] = None
```

---

## Part 4: Add API Endpoints

**Add these endpoints at the end of main.py, before `if __name__ == "__main__":`**

### Announcement Endpoints

```python
# ==================== Announcement Endpoints ====================

@app.post("/api/announcements/", response_model=Announcement)
def create_announcement(announcement: AnnouncementCreate):
    """Create a new announcement"""
    db = SessionLocal()
    try:
        db_announcement = AnnouncementDB(**announcement.dict())
        db.add(db_announcement)
        db.commit()
        db.refresh(db_announcement)
        return db_announcement
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.get("/api/announcements/", response_model=List[Announcement])
def get_announcements(target_audience: Optional[str] = None):
    """Get all announcements, optionally filtered by target audience"""
    db = SessionLocal()
    try:
        query = db.query(AnnouncementDB)
        if target_audience:
            query = query.filter(AnnouncementDB.target_audience.in_([target_audience, "all"]))
        announcements = query.order_by(AnnouncementDB.created_at.desc()).all()
        return announcements
    finally:
        db.close()

@app.get("/api/announcements/{announcement_id}", response_model=Announcement)
def get_announcement(announcement_id: int):
    """Get a specific announcement by ID"""
    db = SessionLocal()
    try:
        announcement = db.query(AnnouncementDB).filter(AnnouncementDB.id == announcement_id).first()
        if not announcement:
            raise HTTPException(status_code=404, detail="Announcement not found")
        return announcement
    finally:
        db.close()

@app.put("/api/announcements/{announcement_id}", response_model=Announcement)
def update_announcement(announcement_id: int, announcement: AnnouncementUpdate):
    """Update an announcement"""
    db = SessionLocal()
    try:
        db_announcement = db.query(AnnouncementDB).filter(AnnouncementDB.id == announcement_id).first()
        if not db_announcement:
            raise HTTPException(status_code=404, detail="Announcement not found")

        for key, value in announcement.dict(exclude_unset=True).items():
            setattr(db_announcement, key, value)

        db.commit()
        db.refresh(db_announcement)
        return db_announcement
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.delete("/api/announcements/{announcement_id}")
def delete_announcement(announcement_id: int):
    """Delete an announcement"""
    db = SessionLocal()
    try:
        db_announcement = db.query(AnnouncementDB).filter(AnnouncementDB.id == announcement_id).first()
        if not db_announcement:
            raise HTTPException(status_code=404, detail="Announcement not found")

        db.delete(db_announcement)
        db.commit()
        return {"message": "Announcement deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()
```

### Notification Endpoints

```python
# ==================== Notification Endpoints ====================

@app.post("/api/notifications/", response_model=Notification)
def create_notification(notification: NotificationCreate):
    """Create a new notification"""
    db = SessionLocal()
    try:
        db_notification = NotificationDB(**notification.dict())
        db.add(db_notification)
        db.commit()
        db.refresh(db_notification)

        # TODO: Send push notification via FCM here (optional for Phase 0)

        return db_notification
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.get("/api/notifications/{user_id}", response_model=List[Notification])
def get_user_notifications(user_id: int, user_type: str):
    """Get all notifications for a specific user"""
    db = SessionLocal()
    try:
        notifications = db.query(NotificationDB).filter(
            NotificationDB.user_id == user_id,
            NotificationDB.user_type == user_type
        ).order_by(NotificationDB.created_at.desc()).all()
        return notifications
    finally:
        db.close()

@app.put("/api/notifications/{notification_id}/read", response_model=Notification)
def mark_notification_read(notification_id: int):
    """Mark a notification as read"""
    db = SessionLocal()
    try:
        db_notification = db.query(NotificationDB).filter(NotificationDB.id == notification_id).first()
        if not db_notification:
            raise HTTPException(status_code=404, detail="Notification not found")

        db_notification.is_read = True
        db.commit()
        db.refresh(db_notification)
        return db_notification
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.delete("/api/notifications/{notification_id}")
def delete_notification(notification_id: int):
    """Delete a notification"""
    db = SessionLocal()
    try:
        db_notification = db.query(NotificationDB).filter(NotificationDB.id == notification_id).first()
        if not db_notification:
            raise HTTPException(status_code=404, detail="Notification not found")

        db.delete(db_notification)
        db.commit()
        return {"message": "Notification deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()
```

### Calendar Event Endpoints

```python
# ==================== Calendar Event Endpoints ====================

@app.post("/api/calendar-events/", response_model=CalendarEvent)
def create_calendar_event(event: CalendarEventCreate):
    """Create a new calendar event"""
    db = SessionLocal()
    try:
        db_event = CalendarEventDB(**event.dict())
        db.add(db_event)
        db.commit()
        db.refresh(db_event)
        return db_event
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.get("/api/calendar-events/", response_model=List[CalendarEvent])
def get_calendar_events(start_date: Optional[str] = None, end_date: Optional[str] = None, event_type: Optional[str] = None):
    """Get calendar events, optionally filtered by date range and event type"""
    db = SessionLocal()
    try:
        query = db.query(CalendarEventDB)

        if start_date:
            query = query.filter(CalendarEventDB.date >= start_date)
        if end_date:
            query = query.filter(CalendarEventDB.date <= end_date)
        if event_type:
            query = query.filter(CalendarEventDB.event_type == event_type)

        events = query.order_by(CalendarEventDB.date).all()
        return events
    finally:
        db.close()

@app.get("/api/calendar-events/{event_id}", response_model=CalendarEvent)
def get_calendar_event(event_id: int):
    """Get a specific calendar event by ID"""
    db = SessionLocal()
    try:
        event = db.query(CalendarEventDB).filter(CalendarEventDB.id == event_id).first()
        if not event:
            raise HTTPException(status_code=404, detail="Calendar event not found")
        return event
    finally:
        db.close()

@app.put("/api/calendar-events/{event_id}", response_model=CalendarEvent)
def update_calendar_event(event_id: int, event: CalendarEventUpdate):
    """Update a calendar event"""
    db = SessionLocal()
    try:
        db_event = db.query(CalendarEventDB).filter(CalendarEventDB.id == event_id).first()
        if not db_event:
            raise HTTPException(status_code=404, detail="Calendar event not found")

        for key, value in event.dict(exclude_unset=True).items():
            setattr(db_event, key, value)

        db.commit()
        db.refresh(db_event)
        return db_event
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.delete("/api/calendar-events/{event_id}")
def delete_calendar_event(event_id: int):
    """Delete a calendar event"""
    db = SessionLocal()
    try:
        db_event = db.query(CalendarEventDB).filter(CalendarEventDB.id == event_id).first()
        if not db_event:
            raise HTTPException(status_code=404, detail="Calendar event not found")

        db.delete(db_event)
        db.commit()
        return {"message": "Calendar event deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()
```

---

##  Part 5: Image Upload API

**Add these imports at the top if not already there:**
```python
from fastapi import File, UploadFile
import shutil
import uuid
from pathlib import Path
```

**Add this endpoint:**
```python
# ==================== Image Upload Endpoints ====================

# Create uploads directory if it doesn't exist
UPLOAD_DIR = Path("./uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

@app.post("/api/upload/image")
async def upload_image(file: UploadFile = File(...)):
    """Upload an image file (for profile photos, etc.)"""
    try:
        # Validate file type
        allowed_extensions = ["jpg", "jpeg", "png", "gif", "webp"]
        file_extension = file.filename.split(".")[-1].lower()

        if file_extension not in allowed_extensions:
            raise HTTPException(status_code=400, detail=f"File type not allowed. Allowed types: {', '.join(allowed_extensions)}")

        # Generate unique filename
        unique_filename = f"{uuid.uuid4()}.{file_extension}"
        file_path = UPLOAD_DIR / unique_filename

        # Save file
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Return relative URL
        return {"url": f"/uploads/{unique_filename}", "filename": unique_filename}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/uploads/{filename}")
async def get_uploaded_image(filename: str):
    """Serve uploaded images"""
    from fastapi.responses import FileResponse
    file_path = UPLOAD_DIR / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Image not found")

    return FileResponse(file_path)
```

---

## Part 6: Test the Setup

### 6.1 Install Dependencies
```bash
cd "d:\laptop new\f\Personal Projects\badminton\abhi_colab\shuttler\Reference\sample"
pip install -r requirements.txt
```

### 6.2 Update .env File
Edit `.env` and replace `password` with your actual PostgreSQL password.

### 6.3 Create Database
Run the SQL from `create_database.sql` in pgAdmin or psql.

### 6.4 Start the Server
```bash
python main.py
```

### 6.5 Check if it's working
- Server should start without errors
- Visit http://localhost:8000/docs to see the Swagger UI
- All new endpoints should appear in the documentation

### 6.6 Verify Database Tables
Open pgAdmin and check that all tables were created in the `badminton_academy` database.

---

## Next Steps

After completing these changes and verifying the server starts successfully:
1. Set up Alembic for migrations (see ALEMBIC_SETUP.md)
2. Create seed data script (see seed_data.py)
3. Test all endpoints with Postman/Swagger UI

---

## Troubleshooting

### Error: "could not connect to server"
- Ensure PostgreSQL service is running
- Check DATABASE_URL in .env has correct password
- Verify port 5432 is not blocked

### Error: "relation does not exist"
- Tables haven't been created yet
- Make sure `Base.metadata.create_all(bind=engine)` is called in main.py
- Or use Alembic migrations

### Error: "module not found"
- Run `pip install -r requirements.txt`
- Ensure you're in the correct virtual environment

### Error: "UNIQUE constraint failed"
- Trying to add duplicate email/phone
- Check existing data in SQLite before migration
