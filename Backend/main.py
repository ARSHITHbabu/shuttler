from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, Text, Date, DateTime, ForeignKey, JSON, func
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.exc import IntegrityError
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, date
import json
import os
import shutil
import uuid
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Database setup - PostgreSQL with fallback to SQLite
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

if not SQLALCHEMY_DATABASE_URL:
    print("⚠️  WARNING: DATABASE_URL not found in .env file!")
    print("⚠️  Falling back to SQLite (NOT recommended for production)")
    print("⚠️  Please update your .env file with PostgreSQL connection string")
    SQLALCHEMY_DATABASE_URL = "sqlite:///./academy_portal.db"
    engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
else:
    print(f"✅ Connecting to PostgreSQL database...")
    # PostgreSQL connection with connection pooling for high concurrency
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL,
        pool_size=20,  # Number of permanent connections in the pool
        max_overflow=40,  # Additional connections when pool is full (total 60 max)
        pool_pre_ping=True,  # Verify connections before using (handles dropped connections)
        pool_recycle=3600,  # Recycle connections after 1 hour
        echo=False  # Set to True to see SQL queries (for debugging)
    )
    print("✅ PostgreSQL connection established!")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ==================== Database Models ====================

class CoachDB(Base):
    __tablename__ = "coaches"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    phone = Column(String, nullable=False)
    password = Column(String, nullable=False)
    role = Column(String, default="coach")  # "coach" or "owner"
    specialization = Column(String, nullable=True)
    experience_years = Column(Integer, nullable=True)
    status = Column(String, default="active")  # active, inactive

    # NEW COLUMNS for Phase 0 enhancements:
    profile_photo = Column(String(500), nullable=True)  # Profile photo URL/path
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging token for push notifications

    # RELATIONSHIPS (will be defined after the related models are created):
    announcements = relationship("AnnouncementDB", back_populates="creator", cascade="all, delete-orphan")
    calendar_events = relationship("CalendarEventDB", back_populates="creator", cascade="all, delete-orphan")

class BatchDB(Base):
    __tablename__ = "batches"
    id = Column(Integer, primary_key=True, index=True)
    batch_name = Column(String, nullable=False)
    capacity = Column(Integer, nullable=False)
    fees = Column(String, nullable=False)
    start_date = Column(String, nullable=False)
    timing = Column(String, nullable=False)
    period = Column(String, nullable=False)
    location = Column(String, nullable=True)
    created_by = Column(String, nullable=False)
    assigned_coach_id = Column(Integer, nullable=True)
    assigned_coach_name = Column(String, nullable=True)

class StudentDB(Base):
    __tablename__ = "students"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    guardian_name = Column(String, nullable=True)  # Optional for signup, required for profile completion
    guardian_phone = Column(String, nullable=True)  # Optional for signup, required for profile completion
    password = Column(String, nullable=False)
    added_by = Column(String, nullable=True)  # Optional for signup
    date_of_birth = Column(String, nullable=True)  # Required for profile completion
    address = Column(Text, nullable=True)  # Required for profile completion
    status = Column(String, default="active")
    t_shirt_size = Column(String, nullable=True)  # Required for profile completion

    # NEW COLUMNS for Phase 0 enhancements:
    profile_photo = Column(String(500), nullable=True)  # Profile photo URL/path, required for profile completion
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging token for push notifications

class BatchStudentDB(Base):
    __tablename__ = "batch_students"
    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, nullable=False)
    student_id = Column(Integer, nullable=False)
    status = Column(String, default="pending") 

class AttendanceDB(Base):
    __tablename__ = "attendance"
    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, nullable=False)
    student_id = Column(Integer, nullable=False)
    date = Column(String, nullable=False)
    status = Column(String, nullable=False)  
    marked_by = Column(String, nullable=False)
    remarks = Column(Text, nullable=True)

class CoachAttendanceDB(Base):
    __tablename__ = "coach_attendance"
    id = Column(Integer, primary_key=True, index=True)
    coach_id = Column(Integer, nullable=False)
    date = Column(String, nullable=False)
    status = Column(String, nullable=False)  
    remarks = Column(Text, nullable=True)

class FeeDB(Base):
    __tablename__ = "fees"
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, nullable=False)
    batch_id = Column(Integer, nullable=False)
    amount = Column(Float, nullable=False)
    due_date = Column(String, nullable=False)
    paid_date = Column(String, nullable=True)
    status = Column(String, nullable=False)  
    payment_method = Column(String, nullable=True)
    collected_by = Column(String, nullable=True)

class PerformanceDB(Base):
    __tablename__ = "performance"
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, nullable=False)
    batch_id = Column(Integer, nullable=False)
    date = Column(String, nullable=False)
    skill = Column(String, nullable=False)
    rating = Column(Integer, nullable=False)
    comments = Column(Text, nullable=True)
    recorded_by = Column(String, nullable=False)

class BMIDB(Base):
    __tablename__ = "bmi_records"
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, nullable=False)
    height = Column(Float, nullable=False)  
    weight = Column(Float, nullable=False)  
    bmi = Column(Float, nullable=False)
    date = Column(String, nullable=False)
    recorded_by = Column(String, nullable=False)

class EnquiryDB(Base):
    __tablename__ = "enquiries"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    email = Column(String, nullable=True)
    message = Column(Text, nullable=False)
    status = Column(String, nullable=False) 
    created_at = Column(String, nullable=False)
    followed_up_by = Column(String, nullable=True)
    notes = Column(Text, nullable=True)
    assigned_to = Column(String, nullable=True)

class ScheduleDB(Base):
    __tablename__ = "schedules"
    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, nullable=False)
    date = Column(String, nullable=False)
    activity = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    created_by = Column(String, nullable=False)

class TournamentDB(Base):
    __tablename__ = "tournaments"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    date = Column(String, nullable=False)
    location = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String, nullable=True)

class VideoResourceDB(Base):
    __tablename__ = "video_resources"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    url = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String, nullable=True)

class InvitationDB(Base):
    __tablename__ = "invitations"
    id = Column(Integer, primary_key=True, index=True)
    coach_id = Column(Integer, nullable=False)
    coach_name = Column(String, nullable=False)
    student_phone = Column(String, nullable=False)
    student_email = Column(String, nullable=False)
    batch_id = Column(Integer, nullable=False)
    status = Column(String, default="pending")
    created_at = Column(String, nullable=False)

# ==================== NEW MODELS FOR PHASE 0 ====================

class AnnouncementDB(Base):
    """Announcements for students, coaches, or all users"""
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


class NotificationDB(Base):
    """User notifications with push notification support"""
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


class CalendarEventDB(Base):
    """Calendar events: holidays, tournaments, in-house events"""
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

# ==================== Database Migration Functions ====================

def check_and_add_column(engine, table_name: str, column_name: str, column_type: str, nullable: bool = True, default_value: str = None):
    """Check if a column exists in a table, and add it if missing"""
    from sqlalchemy import inspect, text
    
    try:
        inspector = inspect(engine)
        columns = [col['name'] for col in inspector.get_columns(table_name)]
        
        if column_name not in columns:
            print(f"⚠️  Column '{column_name}' missing in '{table_name}' table. Adding...")
            try:
                with engine.begin() as conn:
                    alter_sql = f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_type}"
                    if not nullable:
                        alter_sql += " NOT NULL"
                    if default_value:
                        alter_sql += f" DEFAULT {default_value}"
                    conn.execute(text(alter_sql))
                print(f"✅ Added column '{column_name}' to '{table_name}' table")
                return True
            except Exception as e:
                print(f"❌ Error adding column '{column_name}': {e}")
                return False
        return False
    except Exception as e:
        print(f"⚠️  Could not check columns for '{table_name}': {e}")
        return False

def migrate_database_schema(engine):
    """Migrate database schema to match current models"""
    from sqlalchemy import inspect, text
    
    try:
        inspector = inspect(engine)
        
        # Check if tables exist
        tables = inspector.get_table_names()
        
        # Migrate coaches table
        if 'coaches' in tables:
            check_and_add_column(engine, 'coaches', 'role', 'VARCHAR', nullable=True, default_value="'coach'")
            check_and_add_column(engine, 'coaches', 'profile_photo', 'VARCHAR(500)', nullable=True)
            check_and_add_column(engine, 'coaches', 'fcm_token', 'VARCHAR(500)', nullable=True)
        
        # Migrate students table
        if 'students' in tables:
            # Check existing columns
            columns = [col['name'] for col in inspector.get_columns('students')]
            
            # Add new columns
            check_and_add_column(engine, 'students', 'profile_photo', 'VARCHAR(500)', nullable=True)
            check_and_add_column(engine, 'students', 'fcm_token', 'VARCHAR(500)', nullable=True)
            check_and_add_column(engine, 'students', 't_shirt_size', 'VARCHAR', nullable=True)
            
            # Make existing columns nullable if they aren't already
            try:
                with engine.begin() as conn:
                    # Check and alter guardian_name
                    if 'guardian_name' in columns:
                        col_info = next((col for col in inspector.get_columns('students') if col['name'] == 'guardian_name'), None)
                        if col_info and not col_info.get('nullable', True):
                            conn.execute(text("ALTER TABLE students ALTER COLUMN guardian_name DROP NOT NULL"))
                    
                    # Check and alter guardian_phone
                    if 'guardian_phone' in columns:
                        col_info = next((col for col in inspector.get_columns('students') if col['name'] == 'guardian_phone'), None)
                        if col_info and not col_info.get('nullable', True):
                            conn.execute(text("ALTER TABLE students ALTER COLUMN guardian_phone DROP NOT NULL"))
                    
                    # Check and alter added_by
                    if 'added_by' in columns:
                        col_info = next((col for col in inspector.get_columns('students') if col['name'] == 'added_by'), None)
                        if col_info and not col_info.get('nullable', True):
                            conn.execute(text("ALTER TABLE students ALTER COLUMN added_by DROP NOT NULL"))
            except Exception as alter_error:
                print(f"⚠️  Warning: Could not alter column constraints: {alter_error}")
        
        print("✅ Database schema migration completed!")
    except Exception as e:
        print(f"⚠️  Migration error: {e}")

# Create tables
Base.metadata.create_all(bind=engine)

# Run migration to add missing columns
migrate_database_schema(engine)

print("✅ Database tables created/verified!")

# ==================== Pydantic Models ====================

# Coach Models
class CoachCreate(BaseModel):
    name: str
    email: str
    phone: str
    password: str
    role: Optional[str] = "coach"  # "coach" or "owner"
    specialization: Optional[str] = None
    experience_years: Optional[int] = None

class Coach(BaseModel):
    id: int
    name: str
    email: str
    phone: str
    password: str
    role: str = "coach"
    specialization: Optional[str] = None
    experience_years: Optional[int] = None
    status: str = "active"
    profile_photo: Optional[str] = None
    fcm_token: Optional[str] = None

    class Config:
        from_attributes = True

class CoachLogin(BaseModel):
    email: str
    password: str

class CoachUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    password: Optional[str] = None
    specialization: Optional[str] = None
    experience_years: Optional[int] = None
    status: Optional[str] = None

# Batch Models
class BatchCreate(BaseModel):
    batch_name: str
    capacity: int
    fees: str
    start_date: str
    timing: str
    period: str
    location: Optional[str] = None
    created_by: str
    assigned_coach_id: Optional[int] = None
    assigned_coach_name: Optional[str] = None

class Batch(BaseModel):
    id: int
    batch_name: str
    capacity: int
    fees: str
    start_date: str
    timing: str
    period: str
    location: Optional[str] = None
    created_by: str
    assigned_coach_id: Optional[int] = None
    assigned_coach_name: Optional[str] = None
    
    class Config:
        from_attributes = True

class BatchUpdate(BaseModel):
    batch_name: Optional[str] = None
    capacity: Optional[int] = None
    fees: Optional[str] = None
    start_date: Optional[str] = None
    timing: Optional[str] = None
    period: Optional[str] = None
    location: Optional[str] = None
    assigned_coach_id: Optional[int] = None
    assigned_coach_name: Optional[str] = None

# Student Models
class StudentCreate(BaseModel):
    name: str
    phone: str
    email: str
    guardian_name: Optional[str] = None  # Optional for signup, required for profile completion
    guardian_phone: Optional[str] = None  # Optional for signup, required for profile completion
    password: str
    added_by: Optional[str] = None  # Optional for signup
    date_of_birth: Optional[str] = None  # Required for profile completion
    address: Optional[str] = None  # Required for profile completion
    t_shirt_size: Optional[str] = None  # Required for profile completion

class Student(BaseModel):
    id: int
    name: str
    phone: str
    email: str
    guardian_name: Optional[str] = None
    guardian_phone: Optional[str] = None
    password: str
    added_by: Optional[str] = None
    date_of_birth: Optional[str] = None
    address: Optional[str] = None
    status: str = "active"
    t_shirt_size: Optional[str] = None
    profile_photo: Optional[str] = None
    fcm_token: Optional[str] = None

    class Config:
        from_attributes = True

class StudentLogin(BaseModel):
    email: str
    password: str

class StudentUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    guardian_name: Optional[str] = None
    guardian_phone: Optional[str] = None
    password: Optional[str] = None
    date_of_birth: Optional[str] = None
    address: Optional[str] = None
    t_shirt_size: Optional[str] = None
    status: Optional[str] = None
    profile_photo: Optional[str] = None

# Attendance Models
class AttendanceCreate(BaseModel):
    batch_id: int
    student_id: int
    date: str
    status: str
    marked_by: str
    remarks: Optional[str] = None

class Attendance(BaseModel):
    id: int
    batch_id: int
    student_id: int
    date: str
    status: str
    marked_by: str
    remarks: Optional[str] = None
    
    class Config:
        from_attributes = True

class CoachAttendanceCreate(BaseModel):
    coach_id: int
    date: str
    status: str
    remarks: Optional[str] = None

class CoachAttendance(BaseModel):
    id: int
    coach_id: int
    date: str
    status: str
    remarks: Optional[str] = None
    
    class Config:
        from_attributes = True

# Fee Models
class FeeCreate(BaseModel):
    student_id: int
    batch_id: int
    amount: float
    due_date: str
    status: str
    payment_method: Optional[str] = None
    collected_by: Optional[str] = None

class Fee(BaseModel):
    id: int
    student_id: int
    batch_id: int
    amount: float
    due_date: str
    paid_date: Optional[str] = None
    status: str
    payment_method: Optional[str] = None
    collected_by: Optional[str] = None
    
    class Config:
        from_attributes = True

class FeeUpdate(BaseModel):
    paid_date: Optional[str] = None
    status: Optional[str] = None
    payment_method: Optional[str] = None
    collected_by: Optional[str] = None

# Performance Models
class PerformanceCreate(BaseModel):
    student_id: int
    batch_id: int
    date: str
    skill: str
    rating: int
    comments: Optional[str] = None
    recorded_by: str

class Performance(BaseModel):
    id: int
    student_id: int
    batch_id: int
    date: str
    skill: str
    rating: int
    comments: Optional[str] = None
    recorded_by: str
    
    class Config:
        from_attributes = True

# BMI Models
class BMICreate(BaseModel):
    student_id: int
    height: float
    weight: float
    date: str
    recorded_by: str

class BMI(BaseModel):
    id: int
    student_id: int
    height: float
    weight: float
    bmi: float
    date: str
    recorded_by: str
    
    class Config:
        from_attributes = True

# Enquiry Models
class EnquiryCreate(BaseModel):
    name: str
    phone: str
    email: Optional[str] = None
    message: str
    status: str
    assigned_to: Optional[str] = None

class Enquiry(BaseModel):
    id: int
    name: str
    phone: str
    email: Optional[str] = None
    message: str
    status: str
    created_at: str
    followed_up_by: Optional[str] = None
    notes: Optional[str] = None
    assigned_to: Optional[str] = None
    
    class Config:
        from_attributes = True

class EnquiryUpdate(BaseModel):
    status: Optional[str] = None
    followed_up_by: Optional[str] = None
    notes: Optional[str] = None
    assigned_to: Optional[str] = None

# Schedule Models
class ScheduleCreate(BaseModel):
    batch_id: int
    date: str
    activity: str
    description: Optional[str] = None
    created_by: str

class Schedule(BaseModel):
    id: int
    batch_id: int
    date: str
    activity: str
    description: Optional[str] = None
    created_by: str
    
    class Config:
        from_attributes = True

# Tournament Models
class TournamentCreate(BaseModel):
    name: str
    date: str
    location: str
    description: Optional[str] = None
    category: Optional[str] = None

class Tournament(BaseModel):
    id: int
    name: str
    date: str
    location: str
    description: Optional[str] = None
    category: Optional[str] = None
    
    class Config:
        from_attributes = True

# Video Resource Models
class VideoResourceCreate(BaseModel):
    title: str
    url: str
    description: Optional[str] = None
    category: Optional[str] = None

class VideoResource(BaseModel):
    id: int
    title: str
    url: str
    description: Optional[str] = None
    category: Optional[str] = None
    
    class Config:
        from_attributes = True

# Invitation Models
class InvitationCreate(BaseModel):
    coach_id: int
    coach_name: str
    student_phone: str
    student_email: str
    batch_id: int

class Invitation(BaseModel):
    id: int
    coach_id: int
    coach_name: str
    student_phone: str
    student_email: str
    batch_id: int
    status: str
    created_at: str
    
    class Config:
        from_attributes = True

class InvitationUpdate(BaseModel):
    status: str  # approved, rejected

# Other Models
class BatchStudentAssign(BaseModel):
    batch_id: int
    student_id: int

# ==================== NEW PYDANTIC MODELS FOR PHASE 0 ====================

# Announcement Models
class AnnouncementCreate(BaseModel):
    title: str
    message: str
    target_audience: str = "all"
    priority: str = "normal"
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

# Notification Models
class NotificationCreate(BaseModel):
    user_id: int
    user_type: str
    title: str
    body: str
    type: str = "general"
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

# CalendarEvent Models
class CalendarEventCreate(BaseModel):
    title: str
    event_type: str
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

# ==================== FastAPI App ====================

app = FastAPI(title="Badminton Academy Management System")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create uploads directory for image storage
UPLOAD_DIR = Path("./uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
print(f"✅ Upload directory ready at: {UPLOAD_DIR.absolute()}")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==================== Routes ====================

@app.get("/")
def read_root():
    return {"message": "Badminton Academy Management System API", "version": "2.0"}

# ==================== Coach Routes ====================

@app.post("/coaches/", response_model=Coach)
def create_coach(coach: CoachCreate):
    db = SessionLocal()
    try:
        db_coach = CoachDB(**coach.dict())
        db.add(db_coach)
        db.commit()
        db.refresh(db_coach)
        return db_coach
    except IntegrityError as e:
        db.rollback()
        error_msg = str(e.orig) if hasattr(e, 'orig') else str(e)
        if 'email' in error_msg.lower() or 'unique' in error_msg.lower():
            raise HTTPException(status_code=400, detail="Email already registered")
        raise HTTPException(status_code=400, detail=f"Database constraint violation: {error_msg}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating coach: {str(e)}")
    finally:
        db.close()

@app.get("/coaches/", response_model=List[Coach])
def get_coaches():
    db = SessionLocal()
    try:
        coaches = db.query(CoachDB).all()
        return coaches
    finally:
        db.close()

@app.get("/coaches/{coach_id}", response_model=Coach)
def get_coach(coach_id: int):
    db = SessionLocal()
    try:
        coach = db.query(CoachDB).filter(CoachDB.id == coach_id).first()
        if not coach:
            raise HTTPException(status_code=404, detail="Coach not found")
        return coach
    finally:
        db.close()

@app.put("/coaches/{coach_id}", response_model=Coach)
def update_coach(coach_id: int, coach_update: CoachUpdate):
    db = SessionLocal()
    try:
        coach = db.query(CoachDB).filter(CoachDB.id == coach_id).first()
        if not coach:
            raise HTTPException(status_code=404, detail="Coach not found")
        
        update_data = coach_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(coach, key, value)
        
        db.commit()
        db.refresh(coach)
        return coach
    finally:
        db.close()

@app.delete("/coaches/{coach_id}")
def delete_coach(coach_id: int):
    db = SessionLocal()
    try:
        coach = db.query(CoachDB).filter(CoachDB.id == coach_id).first()
        if not coach:
            raise HTTPException(status_code=404, detail="Coach not found")
        db.delete(coach)
        db.commit()
        return {"message": "Coach deleted"}
    finally:
        db.close()

@app.post("/coaches/login")
def login_coach(login_data: CoachLogin):
    db = SessionLocal()
    try:
        coach = db.query(CoachDB).filter(
            CoachDB.email == login_data.email,
            CoachDB.password == login_data.password
        ).first()
        
        if coach:
            if coach.status == "inactive":
                return {
                    "success": False,
                    "message": "Your account has been deactivated. Please contact the owner."
                }
            
            return {
                "success": True,
                "message": "Login successful",
                "coach": {
                    "id": coach.id,
                    "name": coach.name,
                    "email": coach.email,
                    "phone": coach.phone,
                    "specialization": coach.specialization,
                    "experience_years": coach.experience_years,
                    "status": coach.status
                }
            }
        else:
            return {
                "success": False,
                "message": "Invalid credentials"
            }
    finally:
        db.close()

# ==================== Batch Routes ====================

@app.post("/batches/", response_model=Batch)
def create_batch(batch: BatchCreate):
    db = SessionLocal()
    try:
        db_batch = BatchDB(**batch.dict())
        db.add(db_batch)
        db.commit()
        db.refresh(db_batch)
        return db_batch
    finally:
        db.close()

@app.get("/batches/", response_model=List[Batch])
def get_batches():
    db = SessionLocal()
    try:
        batches = db.query(BatchDB).all()
        return batches
    finally:
        db.close()

@app.get("/batches/coach/{coach_id}", response_model=List[Batch])
def get_coach_batches(coach_id: int):
    db = SessionLocal()
    try:
        batches = db.query(BatchDB).filter(BatchDB.assigned_coach_id == coach_id).all()
        return batches
    finally:
        db.close()

@app.put("/batches/{batch_id}", response_model=Batch)
def update_batch(batch_id: int, batch_update: BatchUpdate):
    db = SessionLocal()
    try:
        batch = db.query(BatchDB).filter(BatchDB.id == batch_id).first()
        if not batch:
            raise HTTPException(status_code=404, detail="Batch not found")
        
        update_data = batch_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(batch, key, value)
        
        db.commit()
        db.refresh(batch)
        return batch
    finally:
        db.close()

@app.delete("/batches/{batch_id}")
def delete_batch(batch_id: int):
    db = SessionLocal()
    try:
        batch = db.query(BatchDB).filter(BatchDB.id == batch_id).first()
        if not batch:
            raise HTTPException(status_code=404, detail="Batch not found")
        db.delete(batch)
        db.commit()
        return {"message": "Batch deleted"}
    finally:
        db.close()

@app.get("/batches/{batch_id}/available-students")
def get_available_students_for_batch(batch_id: int):
    """Get students not yet assigned to this batch"""
    db = SessionLocal()
    try:
        # Get all students
        all_students = db.query(StudentDB).filter(StudentDB.status == "active").all()
        
        # Get students already in this batch
        assigned_students = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == batch_id,
            BatchStudentDB.status == "approved"
        ).all()
        assigned_student_ids = [bs.student_id for bs in assigned_students]
        
        # Filter out already assigned students
        available_students = [s for s in all_students if s.id not in assigned_student_ids]
        
        return available_students
    finally:
        db.close()

@app.get("/batches/{batch_id}/students")
def get_batch_students(batch_id: int):
    """Get all students assigned to this batch"""
    db = SessionLocal()
    try:
        batch_students = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == batch_id,
            BatchStudentDB.status == "approved"
        ).all()
        
        students = []
        for bs in batch_students:
            student = db.query(StudentDB).filter(StudentDB.id == bs.student_id).first()
            if student:
                students.append({
                    "id": student.id,
                    "name": student.name,
                    "email": student.email,
                    "phone": student.phone,
                    "guardian_name": student.guardian_name,
                    "guardian_phone": student.guardian_phone
                })
        
        return students
    finally:
        db.close()

@app.post("/batches/{batch_id}/students/{student_id}")
def assign_student_to_batch(batch_id: int, student_id: int):
    """Assign a student to a batch"""
    db = SessionLocal()
    try:
        # Check if already assigned
        existing = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == batch_id,
            BatchStudentDB.student_id == student_id
        ).first()
        
        if existing:
            raise HTTPException(status_code=400, detail="Student already assigned to this batch")
        
        # Create assignment
        db_assignment = BatchStudentDB(
            batch_id=batch_id,
            student_id=student_id,
            status="approved"
        )
        db.add(db_assignment)
        db.commit()
        
        return {"message": "Student assigned successfully"}
    finally:
        db.close()

@app.delete("/batches/{batch_id}/students/{student_id}")
def remove_student_from_batch(batch_id: int, student_id: int):
    """Remove a student from a batch"""
    db = SessionLocal()
    try:
        assignment = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == batch_id,
            BatchStudentDB.student_id == student_id
        ).first()
        
        if not assignment:
            raise HTTPException(status_code=404, detail="Student not found in this batch")
        
        db.delete(assignment)
        db.commit()
        
        return {"message": "Student removed successfully"}
    finally:
        db.close()

# ==================== Student Routes ====================

@app.post("/students/", response_model=Student)
def create_student(student: StudentCreate):
    db = SessionLocal()
    try:
        # Prepare student data with defaults
        student_data = student.model_dump()
        
        # Set default values for optional fields
        if not student_data.get('added_by'):
            student_data['added_by'] = 'self'
        
        if not student_data.get('status'):
            student_data['status'] = 'active'
        
        db_student = StudentDB(**student_data)
        db.add(db_student)
        db.commit()
        db.refresh(db_student)
        return db_student
    finally:
        db.close()

@app.get("/students/", response_model=List[Student])
def get_students():
    db = SessionLocal()
    try:
        students = db.query(StudentDB).all()
        return students
    finally:
        db.close()

@app.get("/students/{student_id}", response_model=Student)
def get_student(student_id: int):
    db = SessionLocal()
    try:
        student = db.query(StudentDB).filter(StudentDB.id == student_id).first()
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        return student
    finally:
        db.close()

@app.put("/students/{student_id}", response_model=Student)
def update_student(student_id: int, student_update: StudentUpdate):
    db = SessionLocal()
    try:
        student = db.query(StudentDB).filter(StudentDB.id == student_id).first()
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        
        update_data = student_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(student, key, value)
        
        db.commit()
        db.refresh(student)
        return student
    finally:
        db.close()

@app.delete("/students/{student_id}")
def delete_student(student_id: int):
    db = SessionLocal()
    try:
        student = db.query(StudentDB).filter(StudentDB.id == student_id).first()
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        db.delete(student)
        db.commit()
        return {"message": "Student deleted"}
    finally:
        db.close()

@app.get("/students/{student_id}/profile-complete")
def check_profile_complete(student_id: int):
    """
    Check if student profile is complete.
    Returns True if all required profile fields are filled.
    """
    db = SessionLocal()
    try:
        student = db.query(StudentDB).filter(StudentDB.id == student_id).first()
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        
        # Required fields for profile completion
        required_fields = {
            'guardian_name': student.guardian_name,
            'guardian_phone': student.guardian_phone,
            'date_of_birth': student.date_of_birth,
            'address': student.address,
            'profile_photo': student.profile_photo,
            't_shirt_size': student.t_shirt_size,
        }
        
        # Check if all required fields are filled
        is_complete = all(
            value is not None and str(value).strip() != ''
            for value in required_fields.values()
        )
        
        missing_fields = [
            field for field, value in required_fields.items()
            if value is None or str(value).strip() == ''
        ]
        
        return {
            "is_complete": is_complete,
            "missing_fields": missing_fields
        }
    finally:
        db.close()

@app.post("/students/login")
def login_student(login_data: StudentLogin):
    db = SessionLocal()
    try:
        student = db.query(StudentDB).filter(
            StudentDB.email == login_data.email,
            StudentDB.password == login_data.password
        ).first()
        
        if student:
            # Check if student has any approved batches
            approved_batches = db.query(BatchStudentDB).filter(
                BatchStudentDB.student_id == student.id,
                BatchStudentDB.status == "approved"
            ).all()
            
            # Check profile completeness
            required_profile_fields = {
                'guardian_name': student.guardian_name,
                'guardian_phone': student.guardian_phone,
                'date_of_birth': student.date_of_birth,
                'address': student.address,
                'profile_photo': student.profile_photo,
                't_shirt_size': student.t_shirt_size,
            }
            
            profile_complete = all(
                value is not None and str(value).strip() != ''
                for value in required_profile_fields.values()
            )
            
            return {
                "success": True,
                "message": "Login successful",
                "student": {
                    "id": student.id,
                    "name": student.name,
                    "email": student.email,
                    "phone": student.phone,
                    "guardian_name": student.guardian_name,
                    "guardian_phone": student.guardian_phone,
                    "date_of_birth": student.date_of_birth,
                    "address": student.address,
                    "t_shirt_size": student.t_shirt_size,
                    "status": student.status,
                    "profile_photo": student.profile_photo,
                    "is_linked": len(approved_batches) > 0
                },
                "profile_complete": profile_complete
            }
        else:
            return {
                "success": False,
                "message": "Invalid credentials"
            }
    finally:
        db.close()

# ==================== Batch-Student Assignment Routes ====================

@app.post("/batch-students/")
def assign_student_to_batch(assignment: BatchStudentAssign):
    db = SessionLocal()
    try:
        existing = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == assignment.batch_id,
            BatchStudentDB.student_id == assignment.student_id
        ).first()
        
        if existing:
            return {"message": "Student already assigned to this batch"}
        
        db_assignment = BatchStudentDB(**assignment.dict(), status="approved")
        db.add(db_assignment)
        db.commit()
        return {"message": "Student assigned to batch successfully"}
    finally:
        db.close()

@app.get("/batch-students/{batch_id}")
def get_batch_students(batch_id: int):
    db = SessionLocal()
    try:
        assignments = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == batch_id,
            BatchStudentDB.status == "approved"
        ).all()
        student_ids = [a.student_id for a in assignments]
        students = db.query(StudentDB).filter(StudentDB.id.in_(student_ids)).all()
        return students
    finally:
        db.close()

@app.get("/student-batches/{student_id}")
def get_student_batches(student_id: int):
    db = SessionLocal()
    try:
        assignments = db.query(BatchStudentDB).filter(
            BatchStudentDB.student_id == student_id,
            BatchStudentDB.status == "approved"
        ).all()
        batch_ids = [a.batch_id for a in assignments]
        batches = db.query(BatchDB).filter(BatchDB.id.in_(batch_ids)).all()
        return batches
    finally:
        db.close()

@app.delete("/batch-students/{batch_id}/{student_id}")
def remove_student_from_batch(batch_id: int, student_id: int):
    db = SessionLocal()
    try:
        assignment = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == batch_id,
            BatchStudentDB.student_id == student_id
        ).first()
        
        if not assignment:
            raise HTTPException(status_code=404, detail="Assignment not found")
        
        db.delete(assignment)
        db.commit()
        return {"message": "Student removed from batch"}
    finally:
        db.close()

# ==================== Attendance Routes ====================

@app.post("/attendance/", response_model=Attendance)
def mark_attendance(attendance: AttendanceCreate):
    db = SessionLocal()
    try:
        existing = db.query(AttendanceDB).filter(
            AttendanceDB.batch_id == attendance.batch_id,
            AttendanceDB.student_id == attendance.student_id,
            AttendanceDB.date == attendance.date
        ).first()
        
        if existing:
            for key, value in attendance.dict().items():
                setattr(existing, key, value)
            db.commit()
            db.refresh(existing)
            return existing
        else:
            db_attendance = AttendanceDB(**attendance.dict())
            db.add(db_attendance)
            db.commit()
            db.refresh(db_attendance)
            return db_attendance
    finally:
        db.close()

@app.get("/attendance/batch/{batch_id}/date/{date}")
def get_batch_attendance(batch_id: int, date: str):
    db = SessionLocal()
    try:
        attendance = db.query(AttendanceDB).filter(
            AttendanceDB.batch_id == batch_id,
            AttendanceDB.date == date
        ).all()
        return attendance
    finally:
        db.close()

@app.get("/attendance/student/{student_id}")
def get_student_attendance(student_id: int):
    db = SessionLocal()
    try:
        attendance = db.query(AttendanceDB).filter(AttendanceDB.student_id == student_id).all()
        return attendance
    finally:
        db.close()

# Coach Attendance Routes
@app.post("/coach-attendance/", response_model=CoachAttendance)
def mark_coach_attendance(attendance: CoachAttendanceCreate):
    db = SessionLocal()
    try:
        existing = db.query(CoachAttendanceDB).filter(
            CoachAttendanceDB.coach_id == attendance.coach_id,
            CoachAttendanceDB.date == attendance.date
        ).first()
        
        if existing:
            for key, value in attendance.dict().items():
                setattr(existing, key, value)
            db.commit()
            db.refresh(existing)
            return existing
        else:
            db_attendance = CoachAttendanceDB(**attendance.dict())
            db.add(db_attendance)
            db.commit()
            db.refresh(db_attendance)
            return db_attendance
    finally:
        db.close()

@app.get("/coach-attendance/coach/{coach_id}")
def get_coach_attendance_history(coach_id: int):
    db = SessionLocal()
    try:
        attendance = db.query(CoachAttendanceDB).filter(CoachAttendanceDB.coach_id == coach_id).all()
        return attendance
    finally:
        db.close()

@app.get("/coach-attendance/date/{date}")
def get_all_coach_attendance(date: str):
    db = SessionLocal()
    try:
        attendance = db.query(CoachAttendanceDB).filter(CoachAttendanceDB.date == date).all()
        return attendance
    finally:
        db.close()

# ==================== Fee Routes ====================

@app.post("/fees/", response_model=Fee)
def create_fee(fee: FeeCreate):
    db = SessionLocal()
    try:
        db_fee = FeeDB(**fee.dict())
        db.add(db_fee)
        db.commit()
        db.refresh(db_fee)
        return db_fee
    finally:
        db.close()

@app.get("/fees/student/{student_id}")
def get_student_fees(student_id: int):
    db = SessionLocal()
    try:
        fees = db.query(FeeDB).filter(FeeDB.student_id == student_id).all()
        return fees
    finally:
        db.close()

@app.get("/fees/batch/{batch_id}")
def get_batch_fees(batch_id: int):
    db = SessionLocal()
    try:
        fees = db.query(FeeDB).filter(FeeDB.batch_id == batch_id).all()
        return fees
    finally:
        db.close()

@app.put("/fees/{fee_id}", response_model=Fee)
def update_fee(fee_id: int, fee_update: FeeUpdate):
    db = SessionLocal()
    try:
        fee = db.query(FeeDB).filter(FeeDB.id == fee_id).first()
        if not fee:
            raise HTTPException(status_code=404, detail="Fee not found")
        
        update_data = fee_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(fee, key, value)
        
        db.commit()
        db.refresh(fee)
        return fee
    finally:
        db.close()

# ==================== Performance Routes ====================

@app.post("/performance/", response_model=Performance)
def create_performance(performance: PerformanceCreate):
    db = SessionLocal()
    try:
        db_performance = PerformanceDB(**performance.dict())
        db.add(db_performance)
        db.commit()
        db.refresh(db_performance)
        return db_performance
    finally:
        db.close()

@app.get("/performance/student/{student_id}")
def get_student_performance(student_id: int):
    db = SessionLocal()
    try:
        performance = db.query(PerformanceDB).filter(PerformanceDB.student_id == student_id).all()
        return performance
    finally:
        db.close()

@app.get("/performance/grouped/student/{student_id}")
def get_student_performance_grouped(student_id: int):
    """Get student performance records grouped by date"""
    db = SessionLocal()
    try:
        performance_records = db.query(PerformanceDB).filter(
            PerformanceDB.student_id == student_id
        ).order_by(PerformanceDB.date.desc()).all()
        
        # Group by date and batch
        grouped = {}
        for record in performance_records:
            key = f"{record.date}_{record.batch_id}_{record.recorded_by}"
            if key not in grouped:
                # Get student and batch info
                student = db.query(StudentDB).filter(StudentDB.id == record.student_id).first()
                batch = db.query(BatchDB).filter(BatchDB.id == record.batch_id).first()
                
                grouped[key] = {
                    "id": record.id,
                    "date": record.date,
                    "batch_id": record.batch_id,
                    "batch_name": batch.batch_name if batch else "Unknown",
                    "student_id": record.student_id,
                    "student_name": student.name if student else "Unknown",
                    "recorded_by": record.recorded_by,
                    "skills": []
                }
            
            grouped[key]["skills"].append({
                "skill": record.skill,
                "rating": record.rating,
                "comments": record.comments
            })
        
        return list(grouped.values())
    finally:
        db.close()

@app.get("/performance/grouped/all")
def get_all_performance_grouped():
    """Get all performance records grouped by date for owner/coach view"""
    db = SessionLocal()
    try:
        performance_records = db.query(PerformanceDB).order_by(PerformanceDB.date.desc()).all()
        
        # Group by date, student, and batch
        grouped = {}
        for record in performance_records:
            key = f"{record.date}_{record.student_id}_{record.batch_id}_{record.recorded_by}"
            if key not in grouped:
                # Get student and batch info
                student = db.query(StudentDB).filter(StudentDB.id == record.student_id).first()
                batch = db.query(BatchDB).filter(BatchDB.id == record.batch_id).first()
                
                grouped[key] = {
                    "id": record.id,
                    "date": record.date,
                    "batch_id": record.batch_id,
                    "batch_name": batch.batch_name if batch else "Unknown",
                    "student_id": record.student_id,
                    "student_name": student.name if student else "Unknown",
                    "recorded_by": record.recorded_by,
                    "skills": []
                }
            
            grouped[key]["skills"].append({
                "skill": record.skill,
                "rating": record.rating,
                "comments": record.comments
            })
        
        return list(grouped.values())
    finally:
        db.close()

@app.get("/performance/grouped/coach/{coach_name}")
def get_coach_performance_grouped(coach_name: str):
    """Get performance records created by a specific coach"""
    db = SessionLocal()
    try:
        performance_records = db.query(PerformanceDB).filter(
            PerformanceDB.recorded_by == coach_name
        ).order_by(PerformanceDB.date.desc()).all()
        
        # Group by date, student, and batch
        grouped = {}
        for record in performance_records:
            key = f"{record.date}_{record.student_id}_{record.batch_id}"
            if key not in grouped:
                # Get student and batch info
                student = db.query(StudentDB).filter(StudentDB.id == record.student_id).first()
                batch = db.query(BatchDB).filter(BatchDB.id == record.batch_id).first()
                
                grouped[key] = {
                    "id": record.id,
                    "date": record.date,
                    "batch_id": record.batch_id,
                    "batch_name": batch.batch_name if batch else "Unknown",
                    "student_id": record.student_id,
                    "student_name": student.name if student else "Unknown",
                    "recorded_by": record.recorded_by,
                    "skills": []
                }
            
            grouped[key]["skills"].append({
                "skill": record.skill,
                "rating": record.rating,
                "comments": record.comments
            })
        
        return list(grouped.values())
    finally:
        db.close()

# ==================== BMI Routes ====================

@app.post("/bmi/", response_model=BMI)
def create_bmi_record(bmi_data: BMICreate):
    db = SessionLocal()
    try:
        # Calculate BMI
        height_m = bmi_data.height / 100
        bmi_value = bmi_data.weight / (height_m ** 2)
        
        db_bmi = BMIDB(
            **bmi_data.dict(),
            bmi=round(bmi_value, 2)
        )
        db.add(db_bmi)
        db.commit()
        db.refresh(db_bmi)
        return db_bmi
    finally:
        db.close()

@app.get("/bmi/student/{student_id}")
def get_student_bmi(student_id: int):
    db = SessionLocal()
    try:
        bmi_records = db.query(BMIDB).filter(BMIDB.student_id == student_id).all()
        return bmi_records
    finally:
        db.close()

# ==================== Enquiry Routes ====================

@app.post("/enquiries/", response_model=Enquiry)
def create_enquiry(enquiry: EnquiryCreate):
    db = SessionLocal()
    try:
        db_enquiry = EnquiryDB(
            **enquiry.dict(),
            created_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        )
        db.add(db_enquiry)
        db.commit()
        db.refresh(db_enquiry)
        return db_enquiry
    finally:
        db.close()

@app.get("/enquiries/", response_model=List[Enquiry])
def get_enquiries():
    db = SessionLocal()
    try:
        enquiries = db.query(EnquiryDB).all()
        return enquiries
    finally:
        db.close()

@app.get("/enquiries/assigned/{assigned_to}")
def get_assigned_enquiries(assigned_to: str):
    db = SessionLocal()
    try:
        enquiries = db.query(EnquiryDB).filter(EnquiryDB.assigned_to == assigned_to).all()
        return enquiries
    finally:
        db.close()

@app.put("/enquiries/{enquiry_id}", response_model=Enquiry)
def update_enquiry(enquiry_id: int, enquiry_update: EnquiryUpdate):
    db = SessionLocal()
    try:
        enquiry = db.query(EnquiryDB).filter(EnquiryDB.id == enquiry_id).first()
        if not enquiry:
            raise HTTPException(status_code=404, detail="Enquiry not found")
        
        update_data = enquiry_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(enquiry, key, value)
        
        db.commit()
        db.refresh(enquiry)
        return enquiry
    finally:
        db.close()

@app.delete("/enquiries/{enquiry_id}")
def delete_enquiry(enquiry_id: int):
    db = SessionLocal()
    try:
        enquiry = db.query(EnquiryDB).filter(EnquiryDB.id == enquiry_id).first()
        if not enquiry:
            raise HTTPException(status_code=404, detail="Enquiry not found")
        db.delete(enquiry)
        db.commit()
        return {"message": "Enquiry deleted"}
    finally:
        db.close()

# ==================== Schedule Routes ====================

@app.post("/schedules/", response_model=Schedule)
def create_schedule(schedule: ScheduleCreate):
    db = SessionLocal()
    try:
        db_schedule = ScheduleDB(**schedule.dict())
        db.add(db_schedule)
        db.commit()
        db.refresh(db_schedule)
        return db_schedule
    finally:
        db.close()

@app.get("/schedules/batch/{batch_id}")
def get_batch_schedules(batch_id: int):
    db = SessionLocal()
    try:
        schedules = db.query(ScheduleDB).filter(ScheduleDB.batch_id == batch_id).all()
        return schedules
    finally:
        db.close()

@app.get("/schedules/date/{date}")
def get_schedules_by_date(date: str):
    db = SessionLocal()
    try:
        schedules = db.query(ScheduleDB).filter(ScheduleDB.date == date).all()
        return schedules
    finally:
        db.close()

@app.delete("/schedules/{schedule_id}")
def delete_schedule(schedule_id: int):
    db = SessionLocal()
    try:
        schedule = db.query(ScheduleDB).filter(ScheduleDB.id == schedule_id).first()
        if not schedule:
            raise HTTPException(status_code=404, detail="Schedule not found")
        db.delete(schedule)
        db.commit()
        return {"message": "Schedule deleted"}
    finally:
        db.close()

# ==================== Tournament Routes ====================

@app.post("/tournaments/", response_model=Tournament)
def create_tournament(tournament: TournamentCreate):
    db = SessionLocal()
    try:
        db_tournament = TournamentDB(**tournament.dict())
        db.add(db_tournament)
        db.commit()
        db.refresh(db_tournament)
        return db_tournament
    finally:
        db.close()

@app.get("/tournaments/", response_model=List[Tournament])
def get_tournaments():
    db = SessionLocal()
    try:
        tournaments = db.query(TournamentDB).all()
        return tournaments
    finally:
        db.close()

@app.get("/tournaments/upcoming")
def get_upcoming_tournaments():
    db = SessionLocal()
    try:
        today = datetime.now().strftime("%Y-%m-%d")
        tournaments = db.query(TournamentDB).filter(TournamentDB.date >= today).all()
        return tournaments
    finally:
        db.close()

@app.delete("/tournaments/{tournament_id}")
def delete_tournament(tournament_id: int):
    db = SessionLocal()
    try:
        tournament = db.query(TournamentDB).filter(TournamentDB.id == tournament_id).first()
        if not tournament:
            raise HTTPException(status_code=404, detail="Tournament not found")
        db.delete(tournament)
        db.commit()
        return {"message": "Tournament deleted"}
    finally:
        db.close()

# ==================== Video Resource Routes ====================

@app.post("/videos/", response_model=VideoResource)
def create_video(video: VideoResourceCreate):
    db = SessionLocal()
    try:
        db_video = VideoResourceDB(**video.dict())
        db.add(db_video)
        db.commit()
        db.refresh(db_video)
        return db_video
    finally:
        db.close()

@app.get("/videos/", response_model=List[VideoResource])
def get_videos():
    db = SessionLocal()
    try:
        videos = db.query(VideoResourceDB).all()
        return videos
    finally:
        db.close()

@app.get("/videos/category/{category}")
def get_videos_by_category(category: str):
    db = SessionLocal()
    try:
        videos = db.query(VideoResourceDB).filter(VideoResourceDB.category == category).all()
        return videos
    finally:
        db.close()

@app.delete("/videos/{video_id}")
def delete_video(video_id: int):
    db = SessionLocal()
    try:
        video = db.query(VideoResourceDB).filter(VideoResourceDB.id == video_id).first()
        if not video:
            raise HTTPException(status_code=404, detail="Video not found")
        db.delete(video)
        db.commit()
        return {"message": "Video deleted"}
    finally:
        db.close()

# ==================== Invitation Routes ====================

@app.post("/invitations/", response_model=Invitation)
def create_invitation(invitation: InvitationCreate):
    db = SessionLocal()
    try:
        db_invitation = InvitationDB(
            **invitation.dict(),
            created_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        )
        db.add(db_invitation)
        db.commit()
        db.refresh(db_invitation)
        return db_invitation
    finally:
        db.close()

@app.get("/invitations/student/{student_email}")
def get_student_invitations(student_email: str):
    db = SessionLocal()
    try:
        invitations = db.query(InvitationDB).filter(
            InvitationDB.student_email == student_email
        ).all()
        return invitations
    finally:
        db.close()

@app.get("/invitations/coach/{coach_id}")
def get_coach_invitations(coach_id: int):
    db = SessionLocal()
    try:
        invitations = db.query(InvitationDB).filter(InvitationDB.coach_id == coach_id).all()
        return invitations
    finally:
        db.close()

@app.put("/invitations/{invitation_id}")
def update_invitation(invitation_id: int, invitation_update: InvitationUpdate):
    db = SessionLocal()
    try:
        invitation = db.query(InvitationDB).filter(InvitationDB.id == invitation_id).first()
        if not invitation:
            raise HTTPException(status_code=404, detail="Invitation not found")
        
        invitation.status = invitation_update.status
        
        # If approved, add student to batch
        if invitation_update.status == "approved":
            # Find student by email
            student = db.query(StudentDB).filter(
                StudentDB.email == invitation.student_email
            ).first()
            
            if student:
                # Check if already assigned
                existing = db.query(BatchStudentDB).filter(
                    BatchStudentDB.batch_id == invitation.batch_id,
                    BatchStudentDB.student_id == student.id
                ).first()
                
                if not existing:
                    db_assignment = BatchStudentDB(
                        batch_id=invitation.batch_id,
                        student_id=student.id,
                        status="approved"
                    )
                    db.add(db_assignment)
        
        db.commit()
        db.refresh(invitation)
        return invitation
    finally:
        db.close()

# ==================== Analytics Routes ====================

@app.get("/analytics/dashboard")
def get_analytics_dashboard():
    db = SessionLocal()
    try:
        total_students = db.query(StudentDB).count()
        active_students = db.query(StudentDB).filter(StudentDB.status == "active").count()
        total_batches = db.query(BatchDB).count()
        total_coaches = db.query(CoachDB).count()
        active_coaches = db.query(CoachDB).filter(CoachDB.status == "active").count()
        
        # Fee analytics
        total_fees = db.query(FeeDB).all()
        total_revenue = sum([f.amount for f in total_fees if f.status == "Paid"])
        pending_fees = sum([f.amount for f in total_fees if f.status == "Pending"])
        overdue_fees = sum([f.amount for f in total_fees if f.status == "Overdue"])
        
        # Attendance stats
        today = datetime.now().strftime("%Y-%m-%d")
        today_attendance = db.query(AttendanceDB).filter(AttendanceDB.date == today).all()
        present_today = len([a for a in today_attendance if a.status == "Present"])
        absent_today = len([a for a in today_attendance if a.status == "Absent"])
        
        # Coach attendance today
        today_coach_attendance = db.query(CoachAttendanceDB).filter(CoachAttendanceDB.date == today).all()
        coaches_present_today = len([a for a in today_coach_attendance if a.status == "Present"])
        
        # Enquiry stats
        enquiries = db.query(EnquiryDB).all()
        new_enquiries = len([e for e in enquiries if e.status == "New"])
        converted_enquiries = len([e for e in enquiries if e.status == "Converted"])
        
        # Calculate attendance percentage
        total_attendance_records = db.query(AttendanceDB).count()
        present_records = db.query(AttendanceDB).filter(AttendanceDB.status == "Present").count()
        attendance_percentage = (present_records / total_attendance_records * 100) if total_attendance_records > 0 else 0
        
        return {
            "total_students": total_students,
            "active_students": active_students,
            "total_batches": total_batches,
            "total_coaches": total_coaches,
            "active_coaches": active_coaches,
            "total_revenue": total_revenue,
            "pending_fees": pending_fees,
            "overdue_fees": overdue_fees,
            "present_today": present_today,
            "absent_today": absent_today,
            "coaches_present_today": coaches_present_today,
            "new_enquiries": new_enquiries,
            "converted_enquiries": converted_enquiries,
            "attendance_percentage": round(attendance_percentage, 2)
        }
    finally:
        db.close()

@app.get("/analytics/coach/{coach_id}")
def get_coach_analytics(coach_id: int):
    db = SessionLocal()
    try:
        # Get coach's batches
        batches = db.query(BatchDB).filter(BatchDB.assigned_coach_id == coach_id).all()
        batch_ids = [b.id for b in batches]
        
        # Get total students under this coach
        total_students = 0
        for batch_id in batch_ids:
            count = db.query(BatchStudentDB).filter(
                BatchStudentDB.batch_id == batch_id,
                BatchStudentDB.status == "approved"
            ).count()
            total_students += count
        
        # Get attendance stats for coach's batches
        attendance_records = db.query(AttendanceDB).filter(AttendanceDB.batch_id.in_(batch_ids)).all()
        present = len([a for a in attendance_records if a.status == "Present"])
        total_records = len(attendance_records)
        attendance_percentage = (present / total_records * 100) if total_records > 0 else 0
        
        # Get fee stats for coach's students
        fees = []
        for batch_id in batch_ids:
            batch_fees = db.query(FeeDB).filter(FeeDB.batch_id == batch_id).all()
            fees.extend(batch_fees)
        
        pending_fees = sum([f.amount for f in fees if f.status == "Pending"])
        collected_fees = sum([f.amount for f in fees if f.status == "Paid"])
        
        return {
            "total_batches": len(batches),
            "total_students": total_students,
            "attendance_percentage": round(attendance_percentage, 2),
            "pending_fees": pending_fees,
            "collected_fees": collected_fees
        }
    finally:
        db.close()

# ==================== NEW ENDPOINTS FOR PHASE 0 ====================

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
        # if fcm_token exists for user, send push notification

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

# ==================== Calendar Event Endpoints ====================

def _db_event_to_pydantic(db_event: CalendarEventDB) -> CalendarEvent:
    """Convert database event to Pydantic model with proper date/datetime serialization"""
    return CalendarEvent(
        id=db_event.id,
        title=db_event.title,
        event_type=db_event.event_type,
        date=db_event.date.isoformat() if isinstance(db_event.date, date) else str(db_event.date),
        description=db_event.description,
        created_by=db_event.created_by,
        created_at=db_event.created_at.isoformat() if hasattr(db_event.created_at, 'isoformat') else str(db_event.created_at),
    )

@app.post("/api/calendar-events/", response_model=CalendarEvent)
def create_calendar_event(event: CalendarEventCreate):
    """Create a new calendar event"""
    db = SessionLocal()
    try:
        # Validate that the creator (coach/owner) exists
        coach = db.query(CoachDB).filter(CoachDB.id == event.created_by).first()
        if not coach:
            raise HTTPException(
                status_code=400, 
                detail=f"Invalid created_by user ID. User with ID {event.created_by} does not exist in coaches table."
            )
        
        # Convert date string to date object
        event_date = datetime.strptime(event.date, "%Y-%m-%d").date()
        
        # Create database event with proper date conversion
        db_event = CalendarEventDB(
            title=event.title,
            event_type=event.event_type,
            date=event_date,
            description=event.description,
            created_by=event.created_by,
        )
        db.add(db_event)
        db.commit()
        db.refresh(db_event)
        return _db_event_to_pydantic(db_event)
    except HTTPException:
        db.rollback()
        raise
    except ValueError as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Invalid date format: {str(e)}")
    except IntegrityError as e:
        db.rollback()
        # Check if it's a foreign key constraint violation
        error_msg = str(e.orig) if hasattr(e, 'orig') else str(e)
        if 'foreign key' in error_msg.lower() or 'created_by' in error_msg.lower():
            raise HTTPException(
                status_code=400, 
                detail=f"Invalid created_by user ID. User with ID {event.created_by} does not exist in coaches table."
            )
        raise HTTPException(status_code=400, detail=f"Database constraint violation: {error_msg}")
    except Exception as e:
        db.rollback()
        # Log the full error for debugging
        import traceback
        error_trace = traceback.format_exc()
        print(f"❌ Error creating calendar event: {error_trace}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    finally:
        db.close()

@app.get("/api/calendar-events/", response_model=List[CalendarEvent])
def get_calendar_events(start_date: Optional[str] = None, end_date: Optional[str] = None, event_type: Optional[str] = None):
    """Get calendar events, optionally filtered by date range and event type"""
    db = SessionLocal()
    try:
        query = db.query(CalendarEventDB)

        if start_date:
            # Convert string to date object for comparison
            start_date_obj = datetime.strptime(start_date, "%Y-%m-%d").date()
            query = query.filter(CalendarEventDB.date >= start_date_obj)
        if end_date:
            # Convert string to date object for comparison
            end_date_obj = datetime.strptime(end_date, "%Y-%m-%d").date()
            query = query.filter(CalendarEventDB.date <= end_date_obj)
        if event_type:
            query = query.filter(CalendarEventDB.event_type == event_type)

        events = query.order_by(CalendarEventDB.date).all()
        # Convert database objects to Pydantic models with proper date serialization
        return [_db_event_to_pydantic(event) for event in events]
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
        return _db_event_to_pydantic(event)
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

        # Handle date conversion if date is being updated
        event_dict = event.dict(exclude_unset=True)
        if 'date' in event_dict and isinstance(event_dict['date'], str):
            event_dict['date'] = datetime.strptime(event_dict['date'], "%Y-%m-%d").date()
        
        for key, value in event_dict.items():
            setattr(db_event, key, value)

        db.commit()
        db.refresh(db_event)
        return _db_event_to_pydantic(db_event)
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

# ==================== Image Upload Endpoints ====================

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
    file_path = UPLOAD_DIR / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Image not found")

    return FileResponse(file_path)

# ==================== Server ====================

if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting Badminton Academy Management System API...")
    print("📖 API Documentation: http://127.0.0.1:8000/docs")
    print("📊 Alternative Docs: http://127.0.0.1:8000/redoc")
    uvicorn.run(app, host="127.0.0.1", port=8000)
