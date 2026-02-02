from fastapi import FastAPI, HTTPException, File, UploadFile, Query, Form
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, Text, Date, DateTime, ForeignKey, JSON, func, and_
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.exc import IntegrityError
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, date, timedelta
import json
import os
import shutil
import uuid
import secrets
import traceback
from pathlib import Path
from dotenv import load_dotenv
from passlib.context import CryptContext
import bcrypt

# Password hashing context - use bcrypt directly to avoid passlib initialization issues
# Fallback to passlib if direct bcrypt fails
try:
    # Test bcrypt directly first
    test_hash = bcrypt.hashpw(b"test", bcrypt.gensalt())
    USE_DIRECT_BCRYPT = True
except Exception as e:
    print(f"⚠️  Direct bcrypt test failed: {e}, using passlib")
    USE_DIRECT_BCRYPT = False

if USE_DIRECT_BCRYPT:
    # Use direct bcrypt for better compatibility
    pwd_context = None
else:
    # Fallback to passlib
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash a password using bcrypt"""
    # Validate password length (bcrypt limit is 72 bytes)
    password_bytes = password.encode('utf-8')
    if len(password_bytes) > 72:
        raise ValueError("Password cannot be longer than 72 bytes")
    
    try:
        if USE_DIRECT_BCRYPT:
            # Use direct bcrypt
            salt = bcrypt.gensalt()
            hashed = bcrypt.hashpw(password_bytes, salt)
            result = hashed.decode('utf-8')
        else:
            # Use passlib
            result = pwd_context.hash(password)
        return result
    except Exception as e:
        raise

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash"""
    try:
        if USE_DIRECT_BCRYPT:
            # Use direct bcrypt
            result = bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
        else:
            # Use passlib
            result = pwd_context.verify(plain_password, hashed_password)
        return result
    except Exception as e:
        raise

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
    specialization = Column(String, nullable=True)
    experience_years = Column(Integer, nullable=True)
    status = Column(String, default="active")  # active, inactive

    # NEW COLUMNS for Phase 0 enhancements:
    profile_photo = Column(String(500), nullable=True)  # Profile photo URL/path
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging token for push notifications

    # RELATIONSHIPS (will be defined after the related models are created):
    # Note: Announcements and calendar events now support both coaches and owners via polymorphic relationships

class OwnerDB(Base):
    """Separate table for academy owners"""
    __tablename__ = "owners"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    phone = Column(String, nullable=False)
    password = Column(String, nullable=False)
    specialization = Column(String, nullable=True)
    experience_years = Column(Integer, nullable=True)
    status = Column(String, default="active")  # active, inactive
    
    # Profile enhancements:
    profile_photo = Column(String(500), nullable=True)  # Profile photo URL/path
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging token for push notifications
    
    # Academy Details:
    academy_name = Column(String(255), nullable=True)
    academy_address = Column(Text, nullable=True)
    academy_contact = Column(String(50), nullable=True)
    academy_email = Column(String(100), nullable=True)
    
    # Ownership and Permissions:
    role = Column(String(20), default="owner")  # "owner" (primary), "co_owner"
    must_change_password = Column(Boolean, default=False)
    
    # RELATIONSHIPS (will be defined after the related models are created):
    # Note: Announcements and calendar events now support both coaches and owners via polymorphic relationships

class SessionDB(Base):
    """Session/Season entity that groups multiple batches"""
    __tablename__ = "sessions"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)  # e.g., "Fall 2026", "Winter 2026"
    start_date = Column(String, nullable=False)
    end_date = Column(String, nullable=False)
    status = Column(String, default="active")  # "active" or "archived"
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

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
    session_id = Column(Integer, ForeignKey("sessions.id"), nullable=True)  # Link to session

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
    blood_group = Column(String, nullable=True)

    # NEW COLUMNS for Phase 0 enhancements:
    profile_photo = Column(String(500), nullable=True)  # Profile photo URL/path, required for profile completion
    fcm_token = Column(String(500), nullable=True)  # Firebase Cloud Messaging token for push notifications

class BatchStudentDB(Base):
    __tablename__ = "batch_students"
    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, nullable=False)
    student_id = Column(Integer, nullable=False)
    status = Column(String, default="pending") 

class BatchCoachDB(Base):
    __tablename__ = "batch_coaches"
    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, ForeignKey("batches.id", ondelete="CASCADE"), nullable=False)
    coach_id = Column(Integer, ForeignKey("coaches.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

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
    status = Column(String, nullable=False)
    payee_student_id = Column(Integer, ForeignKey("students.id"), nullable=True)  # Student from batch who is payee
    payments = relationship("FeePaymentDB", back_populates="fee", cascade="all, delete-orphan")

class FeePaymentDB(Base):
    __tablename__ = "fee_payments"
    id = Column(Integer, primary_key=True, index=True)
    fee_id = Column(Integer, ForeignKey("fees.id"), nullable=False)
    amount = Column(Float, nullable=False)
    paid_date = Column(String, nullable=False)
    payee_student_id = Column(Integer, ForeignKey("students.id"), nullable=True)
    payee_name = Column(String, nullable=True)  # For non-student payees (parents, siblings, etc.)
    payment_method = Column(String, nullable=True)
    collected_by = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    fee = relationship("FeeDB", back_populates="payments")

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
    capacity = Column(Integer, nullable=True)
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
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    title = Column(String, nullable=True)
    url = Column(String, nullable=False)
    remarks = Column(Text, nullable=True)
    uploaded_by = Column(Integer, nullable=True)  # Owner ID who uploaded
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class InvitationDB(Base):
    __tablename__ = "invitations"
    id = Column(Integer, primary_key=True, index=True)
    coach_id = Column(Integer, nullable=False)
    coach_name = Column(String, nullable=False)
    student_phone = Column(String, nullable=True)
    student_email = Column(String, nullable=True)
    batch_id = Column(Integer, nullable=True)
    invite_token = Column(String, nullable=False, unique=True, index=True)
    status = Column(String, default="pending")
    created_at = Column(String, nullable=False)

class CoachInvitationDB(Base):
    """Invitations for coaches - sent by owners"""
    __tablename__ = "coach_invitations"
    id = Column(Integer, primary_key=True, index=True)
    owner_id = Column(Integer, nullable=False)  # Owner who sent the invitation
    owner_name = Column(String, nullable=False)  # Owner name
    coach_name = Column(String, nullable=True)  # Optional coach name
    coach_phone = Column(String, nullable=True)  # At least one of phone or email required
    coach_email = Column(String, nullable=True)  # At least one of phone or email required
    experience_years = Column(Integer, nullable=True)  # Optional experience years
    invite_token = Column(String, nullable=False, unique=True, index=True)
    status = Column(String, default="pending")  # pending, approved, rejected
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
    created_by = Column(Integer, nullable=True)  # Can be coach or owner ID
    creator_type = Column(String(20), default="coach")  # "coach" or "owner"
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    scheduled_at = Column(DateTime(timezone=True), nullable=True)
    is_sent = Column(Boolean, default=False)

    # Note: Relationships are handled via creator_type field - use creator_type to determine if created_by refers to coach or owner


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
    """Calendar events: holidays, tournaments, in-house events, leave"""
    __tablename__ = "calendar_events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    event_type = Column(String(50), nullable=False)  # "holiday", "tournament", "event", "leave"
    date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)  # For date ranges (e.g., multi-day leave)
    description = Column(Text, nullable=True)
    created_by = Column(Integer, nullable=True)  # Can be coach or owner ID
    creator_type = Column(String(20), default="coach")  # "coach" or "owner"
    related_leave_request_id = Column(Integer, nullable=True)  # Link to leave_requests table if this is a leave event
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Note: Relationships are handled via creator_type field - use creator_type to determine if created_by refers to coach or owner

class LeaveRequestDB(Base):
    """Leave requests from coaches"""
    __tablename__ = "leave_requests"

    id = Column(Integer, primary_key=True, index=True)
    coach_id = Column(Integer, nullable=False, index=True)
    coach_name = Column(String, nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    leave_type = Column(String(50), nullable=False)  # "sick", "personal", "emergency", "other"
    reason = Column(Text, nullable=False)
    status = Column(String(20), default="pending")  # "pending", "approved", "rejected"
    submitted_at = Column(DateTime(timezone=True), server_default=func.now())
    reviewed_by = Column(Integer, nullable=True)  # Owner ID who reviewed
    reviewed_at = Column(DateTime(timezone=True), nullable=True)
    review_notes = Column(Text, nullable=True)
    
    # Modification request columns (sub-request)
    modification_start_date = Column(Date, nullable=True)
    modification_end_date = Column(Date, nullable=True)
    modification_reason = Column(Text, nullable=True)
    modification_status = Column(String(20), nullable=True)  # "pending", "approved", "rejected"

class StudentRegistrationRequestDB(Base):
    """Student registration requests awaiting owner approval"""
    __tablename__ = "student_registration_requests"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    phone = Column(String, nullable=False)
    password = Column(String, nullable=False)  # Hashed password
    status = Column(String, default="pending")  # "pending", "approved", "rejected"
    submitted_at = Column(DateTime(timezone=True), server_default=func.now())
    reviewed_by = Column(Integer, nullable=True)  # Owner ID who reviewed
    reviewed_at = Column(DateTime(timezone=True), nullable=True)
    review_notes = Column(Text, nullable=True)
    # Store registration data temporarily
    guardian_name = Column(String, nullable=True)
    guardian_phone = Column(String, nullable=True)
    date_of_birth = Column(String, nullable=True)
    address = Column(Text, nullable=True)
    t_shirt_size = Column(String, nullable=True)
    blood_group = Column(String, nullable=True)
    
    # Invitation tracking
    invitation_id = Column(Integer, ForeignKey("invitations.id"), nullable=True)
    invited_by_coach_id = Column(Integer, ForeignKey("coaches.id"), nullable=True)

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
            check_and_add_column(engine, 'coaches', 'profile_photo', 'VARCHAR(500)', nullable=True)
            check_and_add_column(engine, 'coaches', 'fcm_token', 'VARCHAR(500)', nullable=True)
        
        # Migrate owners table
        if 'owners' in tables:
            check_and_add_column(engine, 'owners', 'academy_name', 'VARCHAR(255)', nullable=True)
            check_and_add_column(engine, 'owners', 'academy_address', 'TEXT', nullable=True)
            check_and_add_column(engine, 'owners', 'academy_contact', 'VARCHAR(50)', nullable=True)
            check_and_add_column(engine, 'owners', 'academy_email', 'VARCHAR(100)', nullable=True)
            check_and_add_column(engine, 'owners', 'role', 'VARCHAR(20)', nullable=True, default_value="'owner'")
            check_and_add_column(engine, 'owners', 'must_change_password', 'BOOLEAN', nullable=True, default_value="FALSE")
        
        # Migrate students table
        if 'students' in tables:
            # Check existing columns
            columns = [col['name'] for col in inspector.get_columns('students')]
            
            # Add new columns
            check_and_add_column(engine, 'students', 'profile_photo', 'VARCHAR(500)', nullable=True)
            check_and_add_column(engine, 'students', 'fcm_token', 'VARCHAR(500)', nullable=True)
            check_and_add_column(engine, 'students', 't_shirt_size', 'VARCHAR', nullable=True)
            check_and_add_column(engine, 'students', 'blood_group', 'VARCHAR(20)', nullable=True)
            
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
        
        # Migrate announcements table - add creator_type and make created_by nullable
        if 'announcements' in tables:
            check_and_add_column(engine, 'announcements', 'creator_type', 'VARCHAR(20)', nullable=True, default_value="'coach'")
            # Make created_by nullable and remove foreign key constraint (since it can reference either coaches or owners)
            try:
                with engine.begin() as conn:
                    # Check if created_by is NOT NULL and make it nullable
                    col_info = next((col for col in inspector.get_columns('announcements') if col['name'] == 'created_by'), None)
                    if col_info and not col_info.get('nullable', True):
                        conn.execute(text("ALTER TABLE announcements ALTER COLUMN created_by DROP NOT NULL"))
                    
                    # Drop foreign key constraint if it exists (since created_by can reference either coaches or owners)
                    # Check for common foreign key constraint names
                    fk_constraints = [
                        'announcements_created_by_fkey',
                        'announcements_created_by_coaches_id_fkey',
                        'fk_announcements_created_by'
                    ]
                    
                    for fk_name in fk_constraints:
                        fk_check = text(f"""
                            SELECT COUNT(*) 
                            FROM information_schema.table_constraints 
                            WHERE table_name = 'announcements' 
                            AND constraint_name = '{fk_name}'
                        """)
                        result = conn.execute(fk_check).scalar()
                        if result > 0:
                            # Drop the foreign key constraint
                            drop_fk_sql = text(f"ALTER TABLE announcements DROP CONSTRAINT IF EXISTS {fk_name}")
                            conn.execute(drop_fk_sql)
                            print(f"✅ Dropped foreign key constraint {fk_name} from announcements.created_by")
                            break
                    
                    # Also try to find and drop any foreign key constraint on created_by column
                    # This handles cases where constraint name might be different
                    fk_check_all = text("""
                        SELECT tc.constraint_name 
                        FROM information_schema.table_constraints tc
                        JOIN information_schema.key_column_usage kcu 
                            ON tc.constraint_name = kcu.constraint_name
                        WHERE tc.table_name = 'announcements' 
                        AND kcu.column_name = 'created_by'
                        AND tc.constraint_type = 'FOREIGN KEY'
                    """)
                    fk_results = conn.execute(fk_check_all).fetchall()
                    for fk_row in fk_results:
                        fk_name = fk_row[0]
                        drop_fk_sql = text(f"ALTER TABLE announcements DROP CONSTRAINT IF EXISTS {fk_name}")
                        conn.execute(drop_fk_sql)
                        print(f"✅ Dropped foreign key constraint {fk_name} from announcements.created_by")
            except Exception as alter_error:
                print(f"⚠️  Warning: Could not alter announcements.created_by constraint: {alter_error}")
        
        # Migrate calendar_events table - add creator_type and make created_by nullable
        if 'calendar_events' in tables:
            check_and_add_column(engine, 'calendar_events', 'creator_type', 'VARCHAR(20)', nullable=True, default_value="'coach'")
            # Make created_by nullable and remove foreign key constraint (since it can reference either coaches or owners)
            try:
                with engine.begin() as conn:
                    # Check if created_by is NOT NULL and make it nullable
                    col_info = next((col for col in inspector.get_columns('calendar_events') if col['name'] == 'created_by'), None)
                    if col_info and not col_info.get('nullable', True):
                        conn.execute(text("ALTER TABLE calendar_events ALTER COLUMN created_by DROP NOT NULL"))
                    
                    # Drop foreign key constraint if it exists (since created_by can reference either coaches or owners)
                    fk_constraints = [
                        'calendar_events_created_by_fkey',
                        'calendar_events_created_by_coaches_id_fkey',
                        'fk_calendar_events_created_by'
                    ]
                    
                    for fk_name in fk_constraints:
                        fk_check = text(f"""
                            SELECT COUNT(*) 
                            FROM information_schema.table_constraints 
                            WHERE table_name = 'calendar_events' 
                            AND constraint_name = '{fk_name}'
                        """)
                        result = conn.execute(fk_check).scalar()
                        if result > 0:
                            # Drop the foreign key constraint
                            drop_fk_sql = text(f"ALTER TABLE calendar_events DROP CONSTRAINT IF EXISTS {fk_name}")
                            conn.execute(drop_fk_sql)
                            print(f"✅ Dropped foreign key constraint {fk_name} from calendar_events.created_by")
                            break
                    
                    # Also try to find and drop any foreign key constraint on created_by column
                    fk_check_all = text("""
                        SELECT tc.constraint_name 
                        FROM information_schema.table_constraints tc
                        JOIN information_schema.key_column_usage kcu 
                            ON tc.constraint_name = kcu.constraint_name
                        WHERE tc.table_name = 'calendar_events' 
                        AND kcu.column_name = 'created_by'
                        AND tc.constraint_type = 'FOREIGN KEY'
                    """)
                    fk_results = conn.execute(fk_check_all).fetchall()
                    for fk_row in fk_results:
                        fk_name = fk_row[0]
                        drop_fk_sql = text(f"ALTER TABLE calendar_events DROP CONSTRAINT IF EXISTS {fk_name}")
                        conn.execute(drop_fk_sql)
                        print(f"✅ Dropped foreign key constraint {fk_name} from calendar_events.created_by")
            except Exception as alter_error:
                print(f"⚠️  Warning: Could not alter calendar_events.created_by constraint: {alter_error}")

        # Migrate student_registration_requests table
        if 'student_registration_requests' in tables:
            check_and_add_column(engine, 'student_registration_requests', 't_shirt_size', 'VARCHAR', nullable=True)
            check_and_add_column(engine, 'student_registration_requests', 'blood_group', 'VARCHAR', nullable=True)
            check_and_add_column(engine, 'student_registration_requests', 'invitation_id', 'INTEGER', nullable=True)
            check_and_add_column(engine, 'student_registration_requests', 'invited_by_coach_id', 'INTEGER', nullable=True)

        # Migrate leave_requests table - add modification columns
        if 'leave_requests' in tables:
            check_and_add_column(engine, 'leave_requests', 'modification_start_date', 'DATE', nullable=True)
            check_and_add_column(engine, 'leave_requests', 'modification_end_date', 'DATE', nullable=True)
            check_and_add_column(engine, 'leave_requests', 'modification_reason', 'TEXT', nullable=True)
            check_and_add_column(engine, 'leave_requests', 'modification_status', 'VARCHAR(20)', nullable=True)

        
        # Migrate fees table - add payee_student_id column
        if 'fees' in tables:
            check_and_add_column(engine, 'fees', 'payee_student_id', 'INTEGER', nullable=True)
            # Add foreign key constraint if column was just added
            try:
                with engine.begin() as conn:
                    # Check if foreign key constraint exists
                    fk_check = text("""
                        SELECT COUNT(*) 
                        FROM information_schema.table_constraints 
                        WHERE table_name = 'fees' 
                        AND constraint_name = 'fees_payee_student_id_fkey'
                    """)
                    result = conn.execute(fk_check).scalar()
                    if result == 0:
                        # Add foreign key constraint
                        fk_sql = text("""
                            ALTER TABLE fees 
                            ADD CONSTRAINT fees_payee_student_id_fkey 
                            FOREIGN KEY (payee_student_id) 
                            REFERENCES students(id)
                        """)
                        conn.execute(fk_sql)
                        print("✅ Added foreign key constraint for fees.payee_student_id")
            except Exception as fk_error:
                # Foreign key might already exist or constraint name might be different
                print(f"⚠️  Note: Foreign key constraint check: {fk_error}")
        
        # Verify fee_payments table exists (should be created by Base.metadata.create_all)
        if 'fee_payments' not in tables:
            print("⚠️  fee_payments table not found. It should be created automatically.")
            print("⚠️  If this persists, check that FeePaymentDB model is properly defined.")
        else:
            print("✅ fee_payments table exists")
            # Migrate fee_payments table - add payee_name column
            check_and_add_column(engine, 'fee_payments', 'payee_name', 'VARCHAR(255)', nullable=True)
        
        # Migrate schedules table - add capacity column
        if 'schedules' in tables:
            check_and_add_column(engine, 'schedules', 'capacity', 'INTEGER', nullable=True)
        
        # Migrate sessions table - create if it doesn't exist
        if 'sessions' not in tables:
            print("⚠️  Table 'sessions' missing. Creating...")
            try:
                with engine.begin() as conn:
                    sessions_table_sql = text("""
                        CREATE TABLE sessions (
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(255) NOT NULL,
                            start_date VARCHAR(50) NOT NULL,
                            end_date VARCHAR(50) NOT NULL,
                            status VARCHAR(20) DEFAULT 'active',
                            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                            updated_at TIMESTAMP WITH TIME ZONE
                        )
                    """)
                    conn.execute(sessions_table_sql)
                print("✅ Created table 'sessions'")
            except Exception as e:
                print(f"⚠️  Error creating sessions table: {e}")
        else:
            print("✅ Table 'sessions' already exists")
        
        # Migrate batches table - add session_id column
        if 'batches' in tables:
            columns = [col['name'] for col in inspector.get_columns('batches')]
            if 'session_id' not in columns:
                print("⚠️  Column 'session_id' missing in 'batches' table. Adding...")
                try:
                    with engine.begin() as conn:
                        # First, ensure sessions table exists (should already be created above)
                        # Add session_id column with foreign key
                        alter_sql = text("""
                            ALTER TABLE batches 
                            ADD COLUMN session_id INTEGER 
                            REFERENCES sessions(id) ON DELETE SET NULL
                        """)
                        conn.execute(alter_sql)
                        print("✅ Added column 'session_id' to 'batches' table")
                        
                        # Create index on session_id for better query performance
                        index_check = text("""
                            SELECT COUNT(*) 
                            FROM pg_indexes 
                            WHERE tablename = 'batches' 
                            AND indexname = 'idx_batches_session_id'
                        """)
                        index_result = conn.execute(index_check).scalar()
                        if index_result == 0:
                            create_index_sql = text("CREATE INDEX idx_batches_session_id ON batches(session_id)")
                            conn.execute(create_index_sql)
                            print("✅ Created index 'idx_batches_session_id' on 'batches' table")
                except Exception as e:
                    print(f"⚠️  Error adding session_id column: {e}")
            else:
                print("✅ Column 'session_id' already exists in 'batches' table")
        
        # Migrate invitations table - add invite_token and make columns nullable
        if 'invitations' in tables:
            columns = [col['name'] for col in inspector.get_columns('invitations')]
            
            # Add invite_token column if missing
            if 'invite_token' not in columns:
                try:
                    with engine.begin() as conn:
                        # Check if there are existing rows
                        row_count = conn.execute(text("SELECT COUNT(*) FROM invitations")).scalar()
                        
                        # Add column as nullable first (to handle existing rows)
                        conn.execute(text("ALTER TABLE invitations ADD COLUMN invite_token VARCHAR(255)"))
                        print("✅ Added invite_token column to invitations table")
                        
                        # If there are existing rows, generate tokens for them
                        if row_count > 0:
                            print(f"⚠️  Found {row_count} existing invitation(s), generating tokens...")
                            rows = conn.execute(text("SELECT id FROM invitations WHERE invite_token IS NULL")).fetchall()
                            for row in rows:
                                token = secrets.token_urlsafe(32)
                                conn.execute(text("UPDATE invitations SET invite_token = :token WHERE id = :id"), 
                                           {"token": token, "id": row[0]})
                            print(f"✅ Generated tokens for {row_count} existing invitation(s)")
                        
                        # Now make it NOT NULL
                        conn.execute(text("ALTER TABLE invitations ALTER COLUMN invite_token SET NOT NULL"))
                        
                        # Add unique constraint
                        constraint_check = text("""
                            SELECT COUNT(*) 
                            FROM information_schema.table_constraints 
                            WHERE table_name = 'invitations' 
                            AND constraint_name = 'invitations_invite_token_key'
                        """)
                        result = conn.execute(constraint_check).scalar()
                        if result == 0:
                            conn.execute(text("ALTER TABLE invitations ADD CONSTRAINT invitations_invite_token_key UNIQUE (invite_token)"))
                            print("✅ Added unique constraint for invitations.invite_token")
                        
                        # Create index if it doesn't exist
                        index_check = text("""
                            SELECT COUNT(*) 
                            FROM pg_indexes 
                            WHERE tablename = 'invitations' 
                            AND indexname = 'ix_invitations_invite_token'
                        """)
                        index_result = conn.execute(index_check).scalar()
                        if index_result == 0:
                            conn.execute(text("CREATE INDEX ix_invitations_invite_token ON invitations (invite_token)"))
                            print("✅ Added index for invitations.invite_token")
                except Exception as constraint_error:
                    print(f"⚠️  Error adding invite_token column: {constraint_error}")
            
            # Make student_phone, student_email, and batch_id nullable if they aren't already
            try:
                with engine.begin() as conn:
                    if 'student_phone' in columns:
                        col_info = next((col for col in inspector.get_columns('invitations') if col['name'] == 'student_phone'), None)
                        if col_info and not col_info.get('nullable', True):
                            conn.execute(text("ALTER TABLE invitations ALTER COLUMN student_phone DROP NOT NULL"))
                            print("✅ Made student_phone nullable in invitations table")
                    
                    if 'student_email' in columns:
                        col_info = next((col for col in inspector.get_columns('invitations') if col['name'] == 'student_email'), None)
                        if col_info and not col_info.get('nullable', True):
                            conn.execute(text("ALTER TABLE invitations ALTER COLUMN student_email DROP NOT NULL"))
                            print("✅ Made student_email nullable in invitations table")
                    
                    if 'batch_id' in columns:
                        col_info = next((col for col in inspector.get_columns('invitations') if col['name'] == 'batch_id'), None)
                        if col_info and not col_info.get('nullable', True):
                            conn.execute(text("ALTER TABLE invitations ALTER COLUMN batch_id DROP NOT NULL"))
                            print("✅ Made batch_id nullable in invitations table")
            except Exception as alter_error:
                print(f"⚠️  Warning: Could not alter column constraints: {alter_error}")

        # Migrate video_resources table - add new columns for student video feature
        if 'video_resources' in tables:
            video_columns = [col['name'] for col in inspector.get_columns('video_resources')]
            print(f"📹 video_resources table found with columns: {video_columns}")

            # Check if this is the old schema (without student_id)
            if 'student_id' not in video_columns:
                print("⚠️  video_resources table has old schema. Migrating...")
                try:
                    with engine.begin() as conn:
                        # Drop old video_resources table (since it has different structure)
                        # First check if there's any data we should preserve
                        count_result = conn.execute(text("SELECT COUNT(*) FROM video_resources")).scalar()
                        if count_result > 0:
                            print(f"⚠️  Found {count_result} existing videos. Backing up old data...")
                            # For safety, rename old table instead of dropping
                            conn.execute(text("ALTER TABLE video_resources RENAME TO video_resources_old_backup"))
                            print("✅ Renamed old table to video_resources_old_backup")
                        else:
                            # No data, safe to drop
                            conn.execute(text("DROP TABLE IF EXISTS video_resources"))
                            print("✅ Dropped empty old video_resources table")

                        # Create new table with correct schema
                        conn.execute(text("""
                            CREATE TABLE video_resources (
                                id SERIAL PRIMARY KEY,
                                student_id INTEGER NOT NULL REFERENCES students(id),
                                title VARCHAR,
                                url VARCHAR NOT NULL,
                                remarks TEXT,
                                uploaded_by INTEGER,
                                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                            )
                        """))
                        print("✅ Created new video_resources table with student association")

                        # Create index on student_id for faster lookups
                        conn.execute(text("CREATE INDEX ix_video_resources_student_id ON video_resources (student_id)"))
                        print("✅ Added index for video_resources.student_id")
                except Exception as video_migration_error:
                    print(f"⚠️  Error migrating video_resources table: {video_migration_error}")
            else:
                # Table already has student_id, just ensure other columns exist
                check_and_add_column(engine, 'video_resources', 'remarks', 'TEXT', nullable=True)
                check_and_add_column(engine, 'video_resources', 'uploaded_by', 'INTEGER', nullable=True)
                check_and_add_column(engine, 'video_resources', 'created_at', 'TIMESTAMP WITH TIME ZONE', nullable=True, default_value='NOW()')
                print("✅ video_resources table schema verified")
        else:
            print("📹 video_resources table will be created by SQLAlchemy")

        # Check if leave_requests table exists
        if 'leave_requests' not in tables:
            print("⚠️  leave_requests table not found. Creating...")
            try:
                LeaveRequestDB.__table__.create(bind=engine)
                print("✅ leave_requests table created!")
            except Exception as e:
                print(f"❌ Error creating leave_requests table: {e}")
        else:
            print("✅ leave_requests table exists")
        
        # Check if student_registration_requests table exists
        if 'student_registration_requests' not in tables:
            print("⚠️  student_registration_requests table not found. Creating...")
            try:
                StudentRegistrationRequestDB.__table__.create(bind=engine)
                print("✅ student_registration_requests table created!")
            except Exception as e:
                print(f"❌ Error creating student_registration_requests table: {e}")
        else:
            print("✅ student_registration_requests table exists")
        
        # Migrate calendar_events table - add end_date and related_leave_request_id columns
        if 'calendar_events' in tables:
            check_and_add_column(engine, 'calendar_events', 'end_date', 'DATE', nullable=True)
            check_and_add_column(engine, 'calendar_events', 'related_leave_request_id', 'INTEGER', nullable=True)
            print("✅ calendar_events table schema updated for leave support")
        
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
    specialization: Optional[str] = None
    experience_years: Optional[int] = None

class Coach(BaseModel):
    id: int
    name: str
    email: str
    phone: str
    password: str
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

class ForgotPasswordRequest(BaseModel):
    email: str
    user_type: str  # "coach", "owner", or "student"

class ResetPasswordRequest(BaseModel):
    email: str
    reset_token: str
    new_password: str
    user_type: str  # "coach", "owner", or "student"

class ChangePasswordRequest(BaseModel):
    email: str
    current_password: str
    new_password: str
    user_type: str  # "coach", "owner", or "student"

class CoachUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    password: Optional[str] = None
    specialization: Optional[str] = None
    experience_years: Optional[int] = None
    status: Optional[str] = None
    profile_photo: Optional[str] = None

# Owner Models
class OwnerCreate(BaseModel):
    name: str
    email: str
    phone: str
    password: str
    specialization: Optional[str] = None
    experience_years: Optional[int] = None
    role: Optional[str] = "owner"
    must_change_password: Optional[bool] = False

class Owner(BaseModel):
    id: int
    name: str
    email: str
    phone: str
    specialization: Optional[str] = None
    experience_years: Optional[int] = None
    status: str = "active"
    role: str = "owner"
    must_change_password: bool = False
    profile_photo: Optional[str] = None
    fcm_token: Optional[str] = None
    academy_name: Optional[str] = None
    academy_address: Optional[str] = None
    academy_contact: Optional[str] = None
    academy_email: Optional[str] = None

    class Config:
        from_attributes = True

class OwnerLogin(BaseModel):
    email: str
    password: str

class OwnerUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    password: Optional[str] = None
    specialization: Optional[str] = None
    experience_years: Optional[int] = None
    must_change_password: Optional[bool] = None
    profile_photo: Optional[str] = None
    fcm_token: Optional[str] = None
    academy_name: Optional[str] = None
    academy_address: Optional[str] = None
    academy_contact: Optional[str] = None
    academy_email: Optional[str] = None

class TransferOwnershipRequest(BaseModel):
    new_owner_id: int

# Batch Models
# Session Models
class SessionCreate(BaseModel):
    name: str
    start_date: str
    end_date: str
    status: Optional[str] = "active"

class SessionUpdate(BaseModel):
    name: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    status: Optional[str] = None

class Session(BaseModel):
    id: int
    name: str
    start_date: str
    end_date: str
    status: str
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    
    class Config:
        from_attributes = True
        # Allow population by field name or alias
        populate_by_name = True

class BatchCreate(BaseModel):
    batch_name: str
    capacity: int
    fees: str
    start_date: str
    timing: str
    period: str
    location: Optional[str] = None
    created_by: str
    assigned_coach_id: Optional[int] = None  # Deprecated: kept for backward compatibility
    assigned_coach_name: Optional[str] = None  # Deprecated: kept for backward compatibility
    assigned_coach_ids: Optional[List[int]] = None  # New: supports multiple coaches
    session_id: Optional[int] = None

class CoachInfo(BaseModel):
    id: int
    name: str
    
    class Config:
        from_attributes = True

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
    assigned_coach_id: Optional[int] = None  # Deprecated: kept for backward compatibility
    assigned_coach_name: Optional[str] = None  # Deprecated: kept for backward compatibility
    assigned_coach_ids: Optional[List[int]] = None  # New: list of coach IDs
    assigned_coaches: Optional[List[CoachInfo]] = None  # New: list of coach info objects
    session_id: Optional[int] = None
    
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
    assigned_coach_id: Optional[int] = None  # Deprecated: kept for backward compatibility
    assigned_coach_name: Optional[str] = None  # Deprecated: kept for backward compatibility
    assigned_coach_ids: Optional[List[int]] = None  # New: supports multiple coaches
    session_id: Optional[int] = None

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
    blood_group: Optional[str] = None

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
    blood_group: Optional[str] = None
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
    blood_group: Optional[str] = None
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
    payee_student_id: Optional[int] = None
    status: Optional[str] = None  # Will be calculated, optional on create

class FeePaymentCreate(BaseModel):
    fee_id: Optional[int] = None  # Optional - provided via path parameter
    amount: float
    paid_date: str
    payee_student_id: Optional[int] = None
    payee_name: Optional[str] = None  # For non-student payees
    payment_method: Optional[str] = None
    collected_by: Optional[str] = None

class FeePayment(BaseModel):
    id: int
    fee_id: int
    amount: float
    paid_date: str
    payee_student_id: Optional[int] = None
    payee_student_name: Optional[str] = None  # Student name if payee_student_id is set
    payee_name: Optional[str] = None  # Custom name for non-student payees
    payment_method: Optional[str] = None
    collected_by: Optional[str] = None
    created_at: Optional[str] = None
    
    class Config:
        from_attributes = True

class Fee(BaseModel):
    id: int
    student_id: int
    student_name: Optional[str] = None
    batch_id: int
    batch_name: Optional[str] = None
    amount: float
    total_paid: float  # Calculated sum of payments
    pending_amount: float  # Calculated: amount - total_paid
    due_date: str
    status: str
    payee_student_id: Optional[int] = None
    payee_student_name: Optional[str] = None
    payments: Optional[List[FeePayment]] = None
    
    class Config:
        from_attributes = True

class FeeUpdate(BaseModel):
    amount: Optional[float] = None
    due_date: Optional[str] = None
    payee_student_id: Optional[int] = None
    status: Optional[str] = None  # Will be recalculated

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

# Frontend-compatible Performance Model (all skills in one record)
class PerformanceFrontend(BaseModel):
    id: int
    student_id: int
    student_name: Optional[str] = None
    date: str
    serve: int  # 1-5 rating
    smash: int  # 1-5 rating
    footwork: int  # 1-5 rating
    defense: int  # 1-5 rating
    stamina: int  # 1-5 rating
    comments: Optional[str] = None
    created_at: Optional[str] = None

class PerformanceFrontendCreate(BaseModel):
    student_id: int
    date: str
    serve: int = 0
    smash: int = 0
    footwork: int = 0
    defense: int = 0
    stamina: int = 0
    comments: Optional[str] = None

class PerformanceFrontendUpdate(BaseModel):
    date: Optional[str] = None
    serve: Optional[int] = None
    smash: Optional[int] = None
    footwork: Optional[int] = None
    defense: Optional[int] = None
    stamina: Optional[int] = None
    comments: Optional[str] = None

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
    health_status: Optional[str] = None  # Added for frontend compatibility
    
    class Config:
        from_attributes = True

class BMIUpdate(BaseModel):
    student_id: Optional[int] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    date: Optional[str] = None
    recorded_by: Optional[str] = None

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
    capacity: Optional[int] = None
    created_by: str

class Schedule(BaseModel):
    id: int
    batch_id: int
    date: str
    activity: str
    description: Optional[str] = None
    capacity: Optional[int] = None
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
    student_id: int
    title: Optional[str] = None
    remarks: Optional[str] = None

class VideoResource(BaseModel):
    id: int
    student_id: int
    student_name: Optional[str] = None
    title: Optional[str] = None
    url: str
    remarks: Optional[str] = None
    uploaded_by: Optional[int] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# Invitation Models
class InvitationCreate(BaseModel):
    coach_id: int
    coach_name: str
    student_phone: Optional[str] = None
    student_email: Optional[str] = None
    batch_id: Optional[int] = None

class Invitation(BaseModel):
    id: int
    coach_id: int
    coach_name: str
    student_phone: Optional[str]
    student_email: Optional[str]
    batch_id: Optional[int]
    invite_token: str
    invite_link: Optional[str] = None
    status: str
    created_at: str
    
    class Config:
        from_attributes = True

class InvitationUpdate(BaseModel):
    status: str  # approved, rejected

# Coach Invitation Models
class CoachInvitationCreate(BaseModel):
    owner_id: int
    owner_name: str
    coach_name: Optional[str] = None  # Optional coach name
    coach_phone: Optional[str] = None  # At least one of phone or email required
    coach_email: Optional[str] = None  # At least one of phone or email required
    experience_years: Optional[int] = None  # Optional experience years

class CoachInvitation(BaseModel):
    id: int
    owner_id: int
    owner_name: str
    coach_name: Optional[str]
    coach_phone: Optional[str]
    coach_email: Optional[str]
    experience_years: Optional[int]
    invite_token: str
    invite_link: Optional[str] = None
    status: str
    created_at: str
    
    class Config:
        from_attributes = True

class CoachInvitationUpdate(BaseModel):
    status: str  # approved, rejected

# Leave Request Models
class LeaveRequestCreate(BaseModel):
    coach_id: int
    coach_name: str
    start_date: str  # YYYY-MM-DD format
    end_date: str  # YYYY-MM-DD format
    leave_type: str  # "sick", "personal", "emergency", "other"
    reason: str

class LeaveRequest(BaseModel):
    id: int
    coach_id: int
    coach_name: str
    start_date: str
    end_date: str
    leave_type: str
    reason: str
    status: str  # "pending", "approved", "rejected"
    submitted_at: str
    reviewed_by: Optional[int] = None
    reviewed_at: Optional[str] = None
    review_notes: Optional[str] = None
    
    # Modification fields
    modification_start_date: Optional[str] = None
    modification_end_date: Optional[str] = None
    modification_reason: Optional[str] = None
    modification_status: Optional[str] = None

    class Config:
        from_attributes = True

class LeaveRequestUpdate(BaseModel):
    status: str  # "approved" or "rejected"
    review_notes: Optional[str] = None

class LeaveRequestModificationCreate(BaseModel):
    start_date: str
    end_date: str
    reason: str

class LeaveRequestModificationReview(BaseModel):
    action: str  # "approve", "reject_modification", "reject_all"
    owner_id: int
    review_notes: Optional[str] = None

# Student Registration Request Models
class StudentRegistrationRequestCreate(BaseModel):
    name: str
    email: str
    phone: str
    password: str
    guardian_name: Optional[str] = None
    guardian_phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    address: Optional[str] = None
    t_shirt_size: Optional[str] = None
    blood_group: Optional[str] = None
    invite_token: Optional[str] = None  # To link with invitation

class StudentRegistrationRequest(BaseModel):
    id: int
    name: str
    email: str
    phone: str
    status: str  # "pending", "approved", "rejected"
    submitted_at: str
    reviewed_by: Optional[int] = None
    reviewed_at: Optional[str] = None
    review_notes: Optional[str] = None
    guardian_name: Optional[str] = None
    guardian_phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    address: Optional[str] = None
    t_shirt_size: Optional[str] = None
    blood_group: Optional[str] = None
    
    # Invitation info
    invitation_id: Optional[int] = None
    invited_by_coach_id: Optional[int] = None
    invited_by_coach_name: Optional[str] = None  # Computed field for convenience
    
    class Config:
        from_attributes = True

class StudentRegistrationRequestUpdate(BaseModel):
    status: str  # "approved" or "rejected"
    review_notes: Optional[str] = None

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
    creator_type: str = "coach"  # "coach" or "owner"
    scheduled_at: Optional[str] = None

class Announcement(BaseModel):
    id: int
    title: str
    message: str
    target_audience: str
    priority: str
    created_by: int
    creator_type: str = "coach"  # "coach" or "owner"
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
    end_date: Optional[str] = None  # Format: "YYYY-MM-DD" (for date ranges)
    description: Optional[str] = None
    created_by: int
    creator_type: str = "coach"  # "coach" or "owner"
    related_leave_request_id: Optional[int] = None  # Link to leave request if this is a leave event

class CalendarEvent(BaseModel):
    id: int
    title: str
    event_type: str
    date: str
    end_date: Optional[str] = None
    description: Optional[str] = None
    created_by: int
    creator_type: str = "coach"  # "coach" or "owner"
    related_leave_request_id: Optional[int] = None
    created_at: str

    class Config:
        from_attributes = True

class CalendarEventUpdate(BaseModel):
    title: Optional[str] = None
    event_type: Optional[str] = None
    date: Optional[str] = None
    end_date: Optional[str] = None
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
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

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

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    try:
        file_ext = os.path.splitext(file.filename)[1]
        filename = f"{uuid.uuid4()}{file_ext}"
        file_path = UPLOAD_DIR / filename
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        return {"url": f"/uploads/{filename}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ==================== Coach Routes ====================

@app.post("/coaches/", response_model=Coach)
def create_coach(coach: CoachCreate):
    """Create a new coach account - saves to coaches table only"""
    db = SessionLocal()
    try:
        # Check if email already exists in owners table (shouldn't happen, but safety check)
        existing_owner = db.query(OwnerDB).filter(OwnerDB.email == coach.email).first()
        if existing_owner:
            raise HTTPException(status_code=400, detail="Email already registered as an owner. Coaches and owners must have unique emails.")
        
        # Hash password before storing
        coach_dict = coach.model_dump()
        coach_dict['password'] = hash_password(coach_dict['password'])
        
        # Explicitly create CoachDB instance (saves to coaches table)
        db_coach = CoachDB(**coach_dict)
        
        # Verify it's a CoachDB instance before adding
        if not isinstance(db_coach, CoachDB):
            raise HTTPException(status_code=500, detail="Internal error: Invalid coach instance")
        
        # Verify table name
        if db_coach.__tablename__ != "coaches":
            raise HTTPException(status_code=500, detail="Internal error: Coach not mapped to coaches table")
        
        db.add(db_coach)
        db.commit()
        db.refresh(db_coach)
        
        # Verify it was saved to coaches table by querying it back
        verify_coach = db.query(CoachDB).filter(CoachDB.id == db_coach.id).first()
        if not verify_coach:
            raise HTTPException(status_code=500, detail="Error: Coach was not saved to coaches table")
        
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
        # Get all coaches (owners are in separate table)
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
        
        update_data = coach_update.model_dump(exclude_unset=True)
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
    """Login endpoint for coaches only - owners should use /owners/login"""
    db = SessionLocal()
    try:
        coach = db.query(CoachDB).filter(
            CoachDB.email == login_data.email
        ).first()
        
        if coach:
            # Verify password (supports both hashed and plain text for backward compatibility)
            password_valid = False
            if coach.password.startswith('$2b$') or coach.password.startswith('$2a$'):
                # Password is hashed, verify it
                password_valid = verify_password(login_data.password, coach.password)
            else:
                # Plain text password (legacy), check directly and upgrade to hash
                password_valid = (coach.password == login_data.password)
                if password_valid:
                    # Upgrade to hashed password
                    coach.password = hash_password(login_data.password)
                    db.commit()
            
            if not password_valid:
                return {
                    "success": False,
                    "message": "Invalid email or password"
                }
            
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
                "message": "Invalid email or password"
            }
    finally:
        db.close()

# In-memory storage for password reset tokens (in production, use Redis or database)
password_reset_tokens = {}

@app.post("/auth/forgot-password")
def forgot_password(request: ForgotPasswordRequest):
    """Request password reset - generates a reset token"""
    db = SessionLocal()
    try:
        # Find user by email and type
        if request.user_type == "coach":
            user = db.query(CoachDB).filter(CoachDB.email == request.email).first()
        elif request.user_type == "owner":
            user = db.query(OwnerDB).filter(OwnerDB.email == request.email).first()
        else:
            user = db.query(StudentDB).filter(StudentDB.email == request.email).first()
        
        if not user:
            # Don't reveal if email exists for security
            return {
                "success": True,
                "message": "If an account exists with this email, a password reset link has been sent."
            }
        
        # Generate secure reset token
        reset_token = secrets.token_urlsafe(32)
        
        # Store token with expiration (1 hour)
        password_reset_tokens[reset_token] = {
            "email": request.email,
            "user_type": request.user_type,
            "expires_at": datetime.now() + timedelta(hours=1)
        }
        
        # In production, send email with reset link
        # For now, return token (in production, don't return token, send via email)
        return {
            "success": True,
            "message": "Password reset token generated. Use this token to reset your password.",
            "reset_token": reset_token,  # Remove this in production, send via email instead
            "expires_in": 3600  # seconds
        }
    finally:
        db.close()

@app.post("/auth/reset-password")
def reset_password(request: ResetPasswordRequest):
    """Reset password using reset token"""
    db = SessionLocal()
    try:
        # Validate token
        if request.reset_token not in password_reset_tokens:
            return {
                "success": False,
                "message": "Invalid or expired reset token"
            }
        
        token_data = password_reset_tokens[request.reset_token]
        
        # Check expiration
        if datetime.now() > token_data["expires_at"]:
            del password_reset_tokens[request.reset_token]
            return {
                "success": False,
                "message": "Reset token has expired. Please request a new one."
            }
        
        # Verify email matches
        if token_data["email"] != request.email or token_data["user_type"] != request.user_type:
            return {
                "success": False,
                "message": "Invalid reset token"
            }
        
        # Find user
        if request.user_type == "coach":
            user = db.query(CoachDB).filter(CoachDB.email == request.email).first()
        elif request.user_type == "owner":
            user = db.query(OwnerDB).filter(OwnerDB.email == request.email).first()
        else:
            user = db.query(StudentDB).filter(StudentDB.email == request.email).first()
        
        if not user:
            return {
                "success": False,
                "message": "User not found"
            }
        
        # Update password
        user.password = hash_password(request.new_password)
        db.commit()
        
        # Remove used token
        del password_reset_tokens[request.reset_token]
        
        return {
            "success": True,
            "message": "Password reset successfully. You can now login with your new password."
        }
    finally:
        db.close()

@app.post("/auth/change-password")
def change_password(request: ChangePasswordRequest):
    """Change password for authenticated users - requires current password verification"""
    db = SessionLocal()
    try:
        # Find user by email and type
        if request.user_type == "coach":
            user = db.query(CoachDB).filter(CoachDB.email == request.email).first()
        elif request.user_type == "owner":
            user = db.query(OwnerDB).filter(OwnerDB.email == request.email).first()
        else:
            user = db.query(StudentDB).filter(StudentDB.email == request.email).first()
        
        if not user:
            return {
                "success": False,
                "message": "User not found"
            }
        
        # Verify current password
        password_valid = False
        if user.password.startswith('$2b$') or user.password.startswith('$2a$'):
            # Password is hashed, verify it
            password_valid = verify_password(request.current_password, user.password)
        else:
            # Plain text password (legacy), check directly
            password_valid = (user.password == request.current_password)
        
        if not password_valid:
            return {
                "success": False,
                "message": "Current password is incorrect"
            }
        
        # Check if new password is different from current password
        if request.current_password == request.new_password:
            return {
                "success": False,
                "message": "New password must be different from current password"
            }
        
        # Validate new password length (bcrypt limit is 72 bytes)
        new_password_bytes = request.new_password.encode('utf-8')
        if len(new_password_bytes) > 72:
            return {
                "success": False,
                "message": "Password cannot be longer than 72 characters"
            }
        
        # Update password
        user.password = hash_password(request.new_password)
        db.commit()
        
        return {
            "success": True,
            "message": "Password changed successfully"
        }
    except Exception as e:
        db.rollback()
        return {
            "success": False,
            "message": f"Failed to change password: {str(e)}"
        }
    finally:
        db.close()

# ==================== Owner Routes ====================

@app.post("/owners/", response_model=Owner)
def create_owner(owner: OwnerCreate):
    """Create a new owner account - saves to owners table only"""
    db = SessionLocal()
    try:
        # Check if owner with this email already exists in owners table
        existing_owner = db.query(OwnerDB).filter(OwnerDB.email == owner.email).first()
        
        if existing_owner:
            raise HTTPException(status_code=400, detail="Owner with this email already exists")
        
        # Also check if email exists in coaches table (shouldn't happen, but safety check)
        existing_coach = db.query(CoachDB).filter(CoachDB.email == owner.email).first()
        if existing_coach:
            raise HTTPException(status_code=400, detail="Email already registered as a coach. Owners and coaches must have unique emails.")
        
        # Hash password before storing
        owner_dict = owner.model_dump(exclude_none=True)  # Exclude None values to avoid SQLAlchemy issues
        owner_dict['password'] = hash_password(owner_dict['password'])
        owner_dict['status'] = "active"  # Default status
        
        # If creating a co-owner, set must_change_password to True
        if owner_dict.get('role') == 'co_owner':
            owner_dict['must_change_password'] = True
        
        # Explicitly create OwnerDB instance (saves to owners table)
        db_owner = OwnerDB(**owner_dict)
        
        # Verify it's an OwnerDB instance before adding
        if not isinstance(db_owner, OwnerDB):
            raise HTTPException(status_code=500, detail="Internal error: Invalid owner instance")
        
        # Verify table name
        if db_owner.__tablename__ != "owners":
            raise HTTPException(status_code=500, detail="Internal error: Owner not mapped to owners table")
        
        db.add(db_owner)
        db.commit()
        db.refresh(db_owner)
        
        # Verify it was saved to owners table by querying it back
        verify_owner = db.query(OwnerDB).filter(OwnerDB.id == db_owner.id).first()
        if not verify_owner:
            raise HTTPException(status_code=500, detail="Error: Owner was not saved to owners table")
        
        return db_owner
    except IntegrityError as e:
        db.rollback()
        error_msg = str(e.orig) if hasattr(e, 'orig') else str(e)
        if 'email' in error_msg.lower() or 'unique' in error_msg.lower():
            raise HTTPException(status_code=400, detail="Email already registered")
        raise HTTPException(status_code=400, detail=f"Database constraint violation: {error_msg}")
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        # Log the full error for debugging
        error_trace = traceback.format_exc()
        print(f"Error creating owner: {error_trace}")  # Log to console for debugging
        raise HTTPException(status_code=500, detail=f"Error creating owner: {str(e)}")
    finally:
        db.close()

@app.get("/owners/", response_model=List[Owner])
def get_owners():
    """Get all owners"""
    db = SessionLocal()
    try:
        owners = db.query(OwnerDB).all()
        return owners
    finally:
        db.close()

@app.get("/owners/{owner_id}", response_model=Owner)
def get_owner(owner_id: int):
    """Get a specific owner by ID"""
    db = SessionLocal()
    try:
        owner = db.query(OwnerDB).filter(OwnerDB.id == owner_id).first()
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")
        return owner
    finally:
        db.close()

@app.put("/owners/{owner_id}", response_model=Owner)
def update_owner(owner_id: int, owner_update: OwnerUpdate):
    """Update owner profile"""
    db = SessionLocal()
    try:
        owner = db.query(OwnerDB).filter(OwnerDB.id == owner_id).first()
        
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")
        
        # Update only provided fields
        update_data = owner_update.model_dump(exclude_unset=True)
        
        # Hash password if provided
        if 'password' in update_data:
            update_data['password'] = hash_password(update_data['password'])
            # Reset must_change_password if they are changing their password
            update_data['must_change_password'] = False
        
        for key, value in update_data.items():
            setattr(owner, key, value)
        
        db.commit()
        db.refresh(owner)
        return owner
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating owner: {str(e)}")
    finally:
        db.close()

@app.delete("/owners/{owner_id}")
def delete_owner(owner_id: int):
    """Delete owner account"""
    db = SessionLocal()
    try:
        owner = db.query(OwnerDB).filter(OwnerDB.id == owner_id).first()
        
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")
        
        db.delete(owner)
        db.commit()
        return {"message": "Owner deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting owner: {str(e)}")
    finally:
        db.close()

@app.post("/owners/login")
def login_owner(login_data: OwnerLogin):
    """Owner login endpoint"""
    db = SessionLocal()
    try:
        owner = db.query(OwnerDB).filter(OwnerDB.email == login_data.email).first()
        
        if owner:
            # Verify password
            password_valid = False
            if owner.password.startswith('$2b$') or owner.password.startswith('$2a$'):
                password_valid = verify_password(login_data.password, owner.password)
            else:
                # Plain text password (legacy), check directly and upgrade to hash
                password_valid = (owner.password == login_data.password)
                if password_valid:
                    owner.password = hash_password(login_data.password)
                    db.commit()
            
            if not password_valid:
                return {
                    "success": False,
                    "message": "Invalid email or password"
                }
            
            if owner.status == "inactive":
                return {
                    "success": False,
                    "message": "Your account has been deactivated."
                }
            
            return {
                "success": True,
                "message": "Login successful",
                "owner": {
                    "id": owner.id,
                    "name": owner.name,
                    "email": owner.email,
                    "phone": owner.phone,
                    "specialization": owner.specialization,
                    "experience_years": owner.experience_years,
                    "status": owner.status,
                    "role": owner.role,
                    "must_change_password": owner.must_change_password,
                    "profile_photo": owner.profile_photo
                }
            }
        else:
            return {
                "success": False,
                "message": "Invalid email or password"
            }
    finally:
        db.close()

@app.post("/owners/{owner_id}/transfer-ownership")
def transfer_ownership(owner_id: int, request: TransferOwnershipRequest):
    """
    Transfer primary ownership to another user.
    The current owner becomes a co_owner.
    """
    db = SessionLocal()
    try:
        # 1. Verify current owner exists and is actually the owner
        current_owner = db.query(OwnerDB).filter(OwnerDB.id == owner_id).first()
        if not current_owner:
            raise HTTPException(status_code=404, detail="Current owner not found")
        
        if current_owner.role != "owner":
            raise HTTPException(status_code=403, detail="Only the primary owner can transfer ownership")
        
        # 2. Verify new owner exists
        new_owner = db.query(OwnerDB).filter(OwnerDB.id == request.new_owner_id).first()
        if not new_owner:
            raise HTTPException(status_code=404, detail="New owner not found")
        
        if new_owner.id == current_owner.id:
            raise HTTPException(status_code=400, detail="Cannot transfer ownership to yourself")

        # 3. Swap roles
        new_owner.role = "owner"
        current_owner.role = "co_owner"
        
        db.commit()
        return {"success": True, "message": f"Ownership transferred to {new_owner.name}"}
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()

# ==================== Batch Routes ====================

def _sync_batch_coaches(db, batch_id: int, coach_ids: Optional[List[int]]):
    """Helper function to sync batch-coach relationships in junction table"""
    if coach_ids is None:
        return  # No change requested
    
    # Get existing assignments
    existing_assignments = db.query(BatchCoachDB).filter(
        BatchCoachDB.batch_id == batch_id
    ).all()
    existing_coach_ids = {bc.coach_id for bc in existing_assignments}
    new_coach_ids = set(coach_ids)
    
    # Remove coaches that are no longer assigned
    for assignment in existing_assignments:
        if assignment.coach_id not in new_coach_ids:
            db.delete(assignment)
    
    # Add new coach assignments
    for coach_id in new_coach_ids:
        if coach_id not in existing_coach_ids:
            # Verify coach exists
            coach = db.query(CoachDB).filter(CoachDB.id == coach_id).first()
            if coach:
                db_assignment = BatchCoachDB(
                    batch_id=batch_id,
                    coach_id=coach_id
                )
                db.add(db_assignment)
    
    db.commit()

def _get_batch_coaches(db, batch_id: int) -> List[CoachInfo]:
    """Helper function to get coaches assigned to a batch"""
    try:
        assignments = db.query(BatchCoachDB).filter(
            BatchCoachDB.batch_id == batch_id
        ).all()
        coach_ids = [bc.coach_id for bc in assignments]
        
        if not coach_ids:
            return []
        
        coaches = db.query(CoachDB).filter(CoachDB.id.in_(coach_ids)).all()
        return [CoachInfo(id=c.id, name=c.name) for c in coaches]
    except Exception:
        # If table doesn't exist yet, return empty list
        return []

@app.post("/batches/", response_model=Batch)
def create_batch(batch: BatchCreate):
    db = SessionLocal()
    try:
        batch_data = batch.model_dump()
        coach_ids = batch_data.pop('assigned_coach_ids', None)
        
        # Handle backward compatibility: if assigned_coach_id is provided, add it to list
        if coach_ids is None and batch_data.get('assigned_coach_id'):
            coach_ids = [batch_data['assigned_coach_id']]
        
        # Remove assigned_coach_id from batch_data (we'll use junction table)
        batch_data.pop('assigned_coach_id', None)
        batch_data.pop('assigned_coach_name', None)
        
        db_batch = BatchDB(**batch_data)
        db.add(db_batch)
        db.commit()
        db.refresh(db_batch)
        
        # Sync coach assignments
        if coach_ids:
            _sync_batch_coaches(db, db_batch.id, coach_ids)
        
        # Get coaches for response
        coaches = _get_batch_coaches(db, db_batch.id)
        coach_ids_list = [c.id for c in coaches]
        
        # Build response
        batch_response = Batch(
            id=db_batch.id,
            batch_name=db_batch.batch_name,
            capacity=db_batch.capacity,
            fees=db_batch.fees,
            start_date=db_batch.start_date,
            timing=db_batch.timing,
            period=db_batch.period,
            location=db_batch.location,
            created_by=db_batch.created_by,
            assigned_coach_id=coach_ids_list[0] if coach_ids_list else None,  # Backward compatibility
            assigned_coach_name=coaches[0].name if coaches else None,  # Backward compatibility
            assigned_coach_ids=coach_ids_list,
            assigned_coaches=coaches,
            session_id=db_batch.session_id
        )
        
        return batch_response
    finally:
        db.close()

@app.get("/batches/", response_model=List[Batch])
def get_batches():
    db = SessionLocal()
    try:
        # Try normal query first
        try:
            batches_db = db.query(BatchDB).all()
            batches = []
            for batch_db in batches_db:
                # Get coaches from junction table
                coaches = _get_batch_coaches(db, batch_db.id)
                coach_ids_list = [c.id for c in coaches]
                
                batch = Batch(
                    id=batch_db.id,
                    batch_name=batch_db.batch_name,
                    capacity=batch_db.capacity,
                    fees=batch_db.fees,
                    start_date=batch_db.start_date,
                    timing=batch_db.timing,
                    period=batch_db.period,
                    location=batch_db.location,
                    created_by=batch_db.created_by,
                    assigned_coach_id=coach_ids_list[0] if coach_ids_list else batch_db.assigned_coach_id,  # Backward compatibility
                    assigned_coach_name=coaches[0].name if coaches else batch_db.assigned_coach_name,  # Backward compatibility
                    assigned_coach_ids=coach_ids_list,
                    assigned_coaches=coaches,
                    session_id=batch_db.session_id
                )
                batches.append(batch)
            return batches
        except Exception as e:
            # If error is about missing session_id column, rollback and use raw SQL
            if "session_id" in str(e) or "UndefinedColumn" in str(e):
                # Rollback the failed transaction
                db.rollback()
                from sqlalchemy import text
                result = db.execute(text("""
                    SELECT id, batch_name, capacity, fees, start_date, timing, period, 
                           location, created_by, assigned_coach_id, assigned_coach_name
                    FROM batches
                """))
                batches = []
                for row in result:
                    batch_id = row[0]
                    # Try to get coaches from junction table
                    coaches = _get_batch_coaches(db, batch_id)
                    coach_ids_list = [c.id for c in coaches]
                    
                    # Create Batch response model directly (not BatchDB)
                    batch = Batch(
                        id=batch_id,
                        batch_name=row[1],
                        capacity=row[2],
                        fees=row[3],
                        start_date=row[4],
                        timing=row[5],
                        period=row[6],
                        location=row[7],
                        created_by=row[8],
                        assigned_coach_id=coach_ids_list[0] if coach_ids_list else row[9],  # Backward compatibility
                        assigned_coach_name=coaches[0].name if coaches else row[10],  # Backward compatibility
                        assigned_coach_ids=coach_ids_list,
                        assigned_coaches=coaches,
                        session_id=None,  # Default to None if column doesn't exist
                    )
                    batches.append(batch)
                return batches
            else:
                # Re-raise if it's a different error
                raise
    finally:
        db.close()

@app.get("/batches/coach/{coach_id}", response_model=List[Batch])
def get_coach_batches(coach_id: int):
    db = SessionLocal()
    try:
        try:
            # Query via junction table
            batch_coaches = db.query(BatchCoachDB).filter(
                BatchCoachDB.coach_id == coach_id
            ).all()
            batch_ids = [bc.batch_id for bc in batch_coaches]
            
            if not batch_ids:
                return []
            
            batches_db = db.query(BatchDB).filter(BatchDB.id.in_(batch_ids)).all()
            batches = []
            for batch_db in batches_db:
                # Get all coaches for this batch
                coaches = _get_batch_coaches(db, batch_db.id)
                coach_ids_list = [c.id for c in coaches]
                
                batch = Batch(
                    id=batch_db.id,
                    batch_name=batch_db.batch_name,
                    capacity=batch_db.capacity,
                    fees=batch_db.fees,
                    start_date=batch_db.start_date,
                    timing=batch_db.timing,
                    period=batch_db.period,
                    location=batch_db.location,
                    created_by=batch_db.created_by,
                    assigned_coach_id=coach_ids_list[0] if coach_ids_list else batch_db.assigned_coach_id,  # Backward compatibility
                    assigned_coach_name=coaches[0].name if coaches else batch_db.assigned_coach_name,  # Backward compatibility
                    assigned_coach_ids=coach_ids_list,
                    assigned_coaches=coaches,
                    session_id=batch_db.session_id
                )
                batches.append(batch)
            return batches
        except Exception as e:
            # If error is about missing batch_coaches table, fall back to old method
            if "batch_coaches" in str(e) or "UndefinedTable" in str(e):
                db.rollback()
                # Fall back to old method using assigned_coach_id
                try:
                    batches_db = db.query(BatchDB).filter(BatchDB.assigned_coach_id == coach_id).all()
                    batches = []
                    for batch_db in batches_db:
                        coaches = _get_batch_coaches(db, batch_db.id)
                        coach_ids_list = [c.id for c in coaches]
                        
                        batch = Batch(
                            id=batch_db.id,
                            batch_name=batch_db.batch_name,
                            capacity=batch_db.capacity,
                            fees=batch_db.fees,
                            start_date=batch_db.start_date,
                            timing=batch_db.timing,
                            period=batch_db.period,
                            location=batch_db.location,
                            created_by=batch_db.created_by,
                            assigned_coach_id=coach_ids_list[0] if coach_ids_list else batch_db.assigned_coach_id,
                            assigned_coach_name=coaches[0].name if coaches else batch_db.assigned_coach_name,
                            assigned_coach_ids=coach_ids_list,
                            assigned_coaches=coaches,
                            session_id=batch_db.session_id
                        )
                        batches.append(batch)
                    return batches
                except Exception:
                    # If that also fails, use raw SQL
                    from sqlalchemy import text
                    result = db.execute(text("""
                        SELECT id, batch_name, capacity, fees, start_date, timing, period, 
                               location, created_by, assigned_coach_id, assigned_coach_name
                        FROM batches
                        WHERE assigned_coach_id = :coach_id
                    """), {"coach_id": coach_id})
                    batches = []
                    for row in result:
                        batch_id = row[0]
                        coaches = _get_batch_coaches(db, batch_id)
                        coach_ids_list = [c.id for c in coaches]
                        
                        batch = Batch(
                            id=batch_id,
                            batch_name=row[1],
                            capacity=row[2],
                            fees=row[3],
                            start_date=row[4],
                            timing=row[5],
                            period=row[6],
                            location=row[7],
                            created_by=row[8],
                            assigned_coach_id=coach_ids_list[0] if coach_ids_list else row[9],
                            assigned_coach_name=coaches[0].name if coaches else row[10],
                            assigned_coach_ids=coach_ids_list,
                            assigned_coaches=coaches,
                            session_id=None,
                        )
                        batches.append(batch)
                    return batches
            else:
                raise
    finally:
        db.close()

@app.put("/batches/{batch_id}", response_model=Batch)
def update_batch(batch_id: int, batch_update: BatchUpdate):
    db = SessionLocal()
    try:
        # Try normal query first
        try:
            batch = db.query(BatchDB).filter(BatchDB.id == batch_id).first()
            if not batch:
                raise HTTPException(status_code=404, detail="Batch not found")
            session_id_value = batch.session_id
        except Exception as e:
            # If error is about missing session_id column, use raw SQL
            if "session_id" in str(e) or "UndefinedColumn" in str(e):
                db.rollback()
                from sqlalchemy import text
                result = db.execute(text("""
                    SELECT id, batch_name, capacity, fees, start_date, timing, period, 
                           location, created_by, assigned_coach_id, assigned_coach_name
                    FROM batches
                    WHERE id = :batch_id
                """), {"batch_id": batch_id})
                row = result.first()
                if not row:
                    raise HTTPException(status_code=404, detail="Batch not found")
                
                # Create a minimal batch-like object for field updates
                # We'll use raw SQL for updates too
                batch = None
                session_id_value = None
            else:
                raise
        
        update_data = batch_update.model_dump(exclude_unset=True)
        coach_ids = update_data.pop('assigned_coach_ids', None)
        
        # Handle backward compatibility: if assigned_coach_id is provided, convert to list
        if coach_ids is None and 'assigned_coach_id' in update_data:
            assigned_coach_id = update_data.pop('assigned_coach_id')
            if assigned_coach_id is not None:
                coach_ids = [assigned_coach_id]
            else:
                coach_ids = []  # Explicitly clear coaches
        
        # Remove deprecated fields
        update_data.pop('assigned_coach_id', None)
        update_data.pop('assigned_coach_name', None)
        
        # Handle session_id separately if it's in update_data
        session_id_update = update_data.pop('session_id', None)
        
        # Update batch fields
        if batch is not None:
            # Normal ORM update
            for key, value in update_data.items():
                setattr(batch, key, value)
            if session_id_update is not None:
                batch.session_id = session_id_update
            
            db.commit()
            db.refresh(batch)
            session_id_value = batch.session_id
        else:
            # Raw SQL update (when session_id column doesn't exist)
            if update_data or session_id_update is not None:
                from sqlalchemy import text
                set_clauses = []
                params = {"batch_id": batch_id}
                
                for key, value in update_data.items():
                    set_clauses.append(f"{key} = :{key}")
                    params[key] = value
                
                if set_clauses:
                    sql = f"""
                        UPDATE batches
                        SET {', '.join(set_clauses)}
                        WHERE id = :batch_id
                    """
                    db.execute(text(sql), params)
                    db.commit()
        
        # Sync coach assignments if provided
        if coach_ids is not None:
            _sync_batch_coaches(db, batch_id, coach_ids)
        
        # Get coaches for response
        coaches = _get_batch_coaches(db, batch_id)
        coach_ids_list = [c.id for c in coaches]
        
        # Get updated batch data for response
        if batch is not None:
            batch_data = {
                'id': batch.id,
                'batch_name': batch.batch_name,
                'capacity': batch.capacity,
                'fees': batch.fees,
                'start_date': batch.start_date,
                'timing': batch.timing,
                'period': batch.period,
                'location': batch.location,
                'created_by': batch.created_by,
                'session_id': session_id_value
            }
        else:
            # Re-query for response
            from sqlalchemy import text
            result = db.execute(text("""
                SELECT id, batch_name, capacity, fees, start_date, timing, period, 
                       location, created_by, assigned_coach_id, assigned_coach_name
                FROM batches
                WHERE id = :batch_id
            """), {"batch_id": batch_id})
            row = result.first()
            batch_data = {
                'id': row[0],
                'batch_name': row[1],
                'capacity': row[2],
                'fees': row[3],
                'start_date': row[4],
                'timing': row[5],
                'period': row[6],
                'location': row[7],
                'created_by': row[8],
                'session_id': None
            }
        
        # Build response
        batch_response = Batch(
            id=batch_data['id'],
            batch_name=batch_data['batch_name'],
            capacity=batch_data['capacity'],
            fees=batch_data['fees'],
            start_date=batch_data['start_date'],
            timing=batch_data['timing'],
            period=batch_data['period'],
            location=batch_data['location'],
            created_by=batch_data['created_by'],
            assigned_coach_id=coach_ids_list[0] if coach_ids_list else None,  # Backward compatibility
            assigned_coach_name=coaches[0].name if coaches else None,  # Backward compatibility
            assigned_coach_ids=coach_ids_list,
            assigned_coaches=coaches,
            session_id=batch_data['session_id']
        )
        
        return batch_response
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
        
        # Hash password before storing
        student_data['password'] = hash_password(student_data['password'])
        
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
            StudentDB.email == login_data.email
        ).first()
        
        if student:
            # Verify password (supports both hashed and plain text for backward compatibility)
            password_valid = False
            if student.password.startswith('$2b$') or student.password.startswith('$2a$'):
                # Password is hashed, verify it
                password_valid = verify_password(login_data.password, student.password)
            else:
                # Plain text password (legacy), check directly and upgrade to hash
                password_valid = (student.password == login_data.password)
                if password_valid:
                    # Upgrade to hashed password
                    student.password = hash_password(login_data.password)
                    db.commit()
            
            if not password_valid:
                return {
                    "success": False,
                    "message": "Invalid email or password"
                }
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
        
        db_assignment = BatchStudentDB(**assignment.model_dump(), status="approved")
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

@app.get("/student-batches/{student_id}", response_model=List[Batch])
def get_student_batches(student_id: int):
    db = SessionLocal()
    try:
        assignments = db.query(BatchStudentDB).filter(
            BatchStudentDB.student_id == student_id,
            BatchStudentDB.status == "approved"
        ).all()
        batch_ids = [a.batch_id for a in assignments]
        if not batch_ids:
            return []
        
        try:
            batches_db = db.query(BatchDB).filter(BatchDB.id.in_(batch_ids)).all()
            batches = []
            for batch_db in batches_db:
                # Get coaches from junction table
                coaches = _get_batch_coaches(db, batch_db.id)
                coach_ids_list = [c.id for c in coaches]
                
                batch = Batch(
                    id=batch_db.id,
                    batch_name=batch_db.batch_name,
                    capacity=batch_db.capacity,
                    fees=batch_db.fees,
                    start_date=batch_db.start_date,
                    timing=batch_db.timing,
                    period=batch_db.period,
                    location=batch_db.location,
                    created_by=batch_db.created_by,
                    assigned_coach_id=coach_ids_list[0] if coach_ids_list else batch_db.assigned_coach_id,
                    assigned_coach_name=coaches[0].name if coaches else batch_db.assigned_coach_name,
                    assigned_coach_ids=coach_ids_list,
                    assigned_coaches=coaches,
                    session_id=batch_db.session_id
                )
                batches.append(batch)
            return batches
        except Exception as e:
            # If error is about missing session_id column, rollback and use raw SQL
            if "session_id" in str(e) or "UndefinedColumn" in str(e):
                db.rollback()
                from sqlalchemy import text
                result = db.execute(text("""
                    SELECT id, batch_name, capacity, fees, start_date, timing, period, 
                           location, created_by, assigned_coach_id, assigned_coach_name
                    FROM batches
                    WHERE id = ANY(:batch_ids)
                """), {"batch_ids": batch_ids})
                
                batches = []
                for row in result:
                    batch_id = row[0]
                    coaches = _get_batch_coaches(db, batch_id)
                    coach_ids_list = [c.id for c in coaches]
                    
                    batch = Batch(
                        id=batch_id,
                        batch_name=row[1],
                        capacity=row[2],
                        fees=row[3],
                        start_date=row[4],
                        timing=row[5],
                        period=row[6],
                        location=row[7],
                        created_by=row[8],
                        assigned_coach_id=coach_ids_list[0] if coach_ids_list else row[9],
                        assigned_coach_name=coaches[0].name if coaches else row[10],
                        assigned_coach_ids=coach_ids_list,
                        assigned_coaches=coaches,
                        session_id=None,
                    )
                    batches.append(batch)
                return batches
            else:
                raise
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

@app.get("/attendance/", response_model=List[Attendance])
def get_attendance(
    date: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    batch_id: Optional[int] = None,
    student_id: Optional[int] = None,
):
    """Get attendance records with optional filters"""
    db = SessionLocal()
    try:
        query = db.query(AttendanceDB)
        
        # Filter by exact date
        if date:
            query = query.filter(AttendanceDB.date == date)
        
        # Filter by date range
        if start_date:
            query = query.filter(AttendanceDB.date >= start_date)
        if end_date:
            query = query.filter(AttendanceDB.date <= end_date)
        
        # Filter by batch_id
        if batch_id:
            query = query.filter(AttendanceDB.batch_id == batch_id)
        
        # Filter by student_id
        if student_id:
            query = query.filter(AttendanceDB.student_id == student_id)
        
        attendance = query.order_by(AttendanceDB.date.desc()).all()
        return attendance
    finally:
        db.close()

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
            for key, value in attendance.model_dump().items():
                setattr(existing, key, value)
            db.commit()
            db.refresh(existing)
            return existing
        else:
            db_attendance = AttendanceDB(**attendance.model_dump())
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
            for key, value in attendance.model_dump().items():
                setattr(existing, key, value)
            db.commit()
            db.refresh(existing)
            return existing
        else:
            db_attendance = CoachAttendanceDB(**attendance.model_dump())
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

# Helper functions for fee calculations
def calculate_total_paid(fee_id: int, db) -> float:
    """Calculate total amount paid for a fee"""
    payments = db.query(FeePaymentDB).filter(FeePaymentDB.fee_id == fee_id).all()
    return sum(payment.amount for payment in payments)

def calculate_fee_status(amount: float, total_paid: float, due_date: str) -> str:
    """Calculate fee status based on payments and due date"""
    # Fully paid
    if total_paid >= amount:
        return 'paid'
    
    # Check if overdue (7 days after due_date)
    try:
        due_date_obj = datetime.fromisoformat(due_date)
        days_overdue = (datetime.now() - due_date_obj).days
        if days_overdue >= 7:
            return 'overdue'
    except:
        pass
    
    # Default to pending
    return 'pending'

def enrich_fee_with_payments(fee: FeeDB, db) -> dict:
    """Enrich fee with payment data and calculate totals"""
    total_paid = calculate_total_paid(fee.id, db)
    status = calculate_fee_status(fee.amount, total_paid, fee.due_date)
    
    # Update status in database if changed
    if fee.status != status:
        fee.status = status
        db.commit()
        db.refresh(fee)
    
    # Get payments
    payments = db.query(FeePaymentDB).filter(FeePaymentDB.fee_id == fee.id).order_by(FeePaymentDB.created_at.desc()).all()
    
    # Enrich payments with student names
    payment_list = []
    for payment in payments:
        payee_student_name = None
        if payment.payee_student_id:
            payee = db.query(StudentDB).filter(StudentDB.id == payment.payee_student_id).first()
            payee_student_name = payee.name if payee else None
        payment_list.append({
            "id": payment.id,
            "fee_id": payment.fee_id,
            "amount": payment.amount,
            "paid_date": payment.paid_date,
            "payee_student_id": payment.payee_student_id,
            "payee_student_name": payee_student_name,
            "payee_name": payment.payee_name,
            "payment_method": payment.payment_method,
            "collected_by": payment.collected_by,
            "created_at": payment.created_at.isoformat() if payment.created_at else None,
        })
    
    # Get student and batch names
    student = db.query(StudentDB).filter(StudentDB.id == fee.student_id).first()
    # Try to get batch, handle missing session_id column gracefully
    batch = None
    try:
        batch = db.query(BatchDB).filter(BatchDB.id == fee.batch_id).first()
    except Exception as e:
        if "session_id" in str(e) or "UndefinedColumn" in str(e):
            db.rollback()
            from sqlalchemy import text
            result = db.execute(text("""
                SELECT id, batch_name, capacity, fees, start_date, timing, period, 
                       location, created_by, assigned_coach_id, assigned_coach_name
                FROM batches
                WHERE id = :batch_id
            """), {"batch_id": fee.batch_id}).first()
            if result:
                # Create a minimal Batch object for batch_name
                batch = type('Batch', (), {
                    'batch_name': result[1],
                    'id': result[0]
                })()
    payee_student = None
    payee_name = None
    if fee.payee_student_id:
        payee_student = db.query(StudentDB).filter(StudentDB.id == fee.payee_student_id).first()
        payee_name = payee_student.name if payee_student else None
    
    return {
        "id": fee.id,
        "student_id": fee.student_id,
        "student_name": student.name if student else None,
        "batch_id": fee.batch_id,
        "batch_name": batch.batch_name if batch else None,
        "amount": fee.amount,
        "total_paid": total_paid,
        "pending_amount": fee.amount - total_paid,
        "due_date": fee.due_date,
        "status": status,
        "payee_student_id": fee.payee_student_id,
        "payee_student_name": payee_name,
        "payments": payment_list,
    }

@app.post("/fees/", response_model=Fee)
def create_fee(fee: FeeCreate):
    db = SessionLocal()
    try:
        # Calculate initial status (pending if no payments)
        initial_status = fee.status if fee.status else 'pending'
        
        # Create fee
        fee_dict = fee.dict()
        fee_dict['status'] = initial_status
        db_fee = FeeDB(**fee_dict)
        db.add(db_fee)
        db.commit()
        db.refresh(db_fee)
        
        # Enrich with payments and calculate totals
        return enrich_fee_with_payments(db_fee, db)
    finally:
        db.close()

@app.get("/fees/student/{student_id}")
def get_student_fees(student_id: int):
    db = SessionLocal()
    try:
        fees = db.query(FeeDB).filter(FeeDB.student_id == student_id).all()
        # Enrich with payments and calculate totals
        result = []
        for fee in fees:
            result.append(enrich_fee_with_payments(fee, db))
        return result
    finally:
        db.close()

@app.get("/fees/batch/{batch_id}")
def get_batch_fees(batch_id: int):
    db = SessionLocal()
    try:
        fees = db.query(FeeDB).filter(FeeDB.batch_id == batch_id).all()
        result = []
        for fee in fees:
            result.append(enrich_fee_with_payments(fee, db))
        return result
    finally:
        db.close()

@app.get("/fees/", response_model=List[Fee])
def get_all_fees(
    student_id: Optional[int] = None,
    batch_id: Optional[int] = None,
    status: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None
):
    """Get all fees with optional filtering, enriched with student and batch names"""
    db = SessionLocal()
    try:
        query = db.query(FeeDB)
        
        if student_id is not None:
            query = query.filter(FeeDB.student_id == student_id)
        
        if batch_id is not None:
            query = query.filter(FeeDB.batch_id == batch_id)
        
        if status:
            query = query.filter(FeeDB.status == status)
        
        if start_date:
            query = query.filter(FeeDB.due_date >= start_date)
        
        if end_date:
            query = query.filter(FeeDB.due_date <= end_date)
        
        fees = query.order_by(FeeDB.due_date.desc()).all()

        # Enrich with payments and calculate totals using the helper function
        result = []
        for fee in fees:
            enriched_fee = enrich_fee_with_payments(fee, db)
            result.append(enriched_fee)
        return result
    finally:
        db.close()

@app.put("/fees/{fee_id}", response_model=Fee)
def update_fee(fee_id: int, fee_update: FeeUpdate):
    db = SessionLocal()
    try:
        fee = db.query(FeeDB).filter(FeeDB.id == fee_id).first()
        if not fee:
            raise HTTPException(status_code=404, detail="Fee not found")
        
        update_data = fee_update.model_dump(exclude_unset=True)
        # Don't update status directly, it will be recalculated
        if 'status' in update_data:
            del update_data['status']
        
        for key, value in update_data.items():
            setattr(fee, key, value)
        
        db.commit()
        db.refresh(fee)
        
        # Recalculate status and enrich with payments
        return enrich_fee_with_payments(fee, db)
    finally:
        db.close()

# ==================== Fee Payment Routes ====================

@app.post("/fees/{fee_id}/payments/", response_model=FeePayment)
def create_fee_payment(fee_id: int, payment: FeePaymentCreate):
    """Add a payment to a fee"""
    db = SessionLocal()
    try:
        # Validate fee exists
        fee = db.query(FeeDB).filter(FeeDB.id == fee_id).first()
        if not fee:
            raise HTTPException(status_code=404, detail="Fee not found")
        
        # Validate payment amount doesn't exceed pending amount
        total_paid = calculate_total_paid(fee_id, db)
        pending_amount = fee.amount - total_paid
        if payment.amount > pending_amount:
            raise HTTPException(status_code=400, detail=f"Payment amount (₹{payment.amount}) exceeds pending amount (₹{pending_amount})")
        
        # Validate payee: either payee_student_id or payee_name must be provided, but not both
        if payment.payee_student_id and payment.payee_name:
            raise HTTPException(status_code=400, detail="Cannot specify both payee_student_id and payee_name. Provide either a student ID or a custom payee name.")
        if not payment.payee_student_id and not payment.payee_name:
            raise HTTPException(status_code=400, detail="Either payee_student_id or payee_name must be provided.")
        
        # Create payment
        payment_dict = payment.model_dump()
        payment_dict['fee_id'] = fee_id
        db_payment = FeePaymentDB(**payment_dict)
        db.add(db_payment)
        db.commit()
        db.refresh(db_payment)
        
        # Recalculate fee status
        new_total_paid = calculate_total_paid(fee_id, db)
        new_status = calculate_fee_status(fee.amount, new_total_paid, fee.due_date)
        fee.status = new_status
        db.commit()
        db.refresh(fee)
        
        # Enrich payment with payee information
        payee_student_name = None
        if db_payment.payee_student_id:
            payee = db.query(StudentDB).filter(StudentDB.id == db_payment.payee_student_id).first()
            payee_student_name = payee.name if payee else None
        
        return {
            "id": db_payment.id,
            "fee_id": db_payment.fee_id,
            "amount": db_payment.amount,
            "paid_date": db_payment.paid_date,
            "payee_student_id": db_payment.payee_student_id,
            "payee_student_name": payee_student_name,
            "payee_name": db_payment.payee_name,
            "payment_method": db_payment.payment_method,
            "collected_by": db_payment.collected_by,
            "created_at": db_payment.created_at.isoformat() if db_payment.created_at else None,
        }
    finally:
        db.close()

@app.get("/fees/{fee_id}/payments/", response_model=List[FeePayment])
def get_fee_payments(fee_id: int):
    """Get all payments for a fee"""
    db = SessionLocal()
    try:
        payments = db.query(FeePaymentDB).filter(FeePaymentDB.fee_id == fee_id).order_by(FeePaymentDB.created_at.desc()).all()
        result = []
        for payment in payments:
            payee_student_name = None
            if payment.payee_student_id:
                payee = db.query(StudentDB).filter(StudentDB.id == payment.payee_student_id).first()
                payee_student_name = payee.name if payee else None
            result.append({
                "id": payment.id,
                "fee_id": payment.fee_id,
                "amount": payment.amount,
                "paid_date": payment.paid_date,
                "payee_student_id": payment.payee_student_id,
                "payee_student_name": payee_student_name,
                "payee_name": payment.payee_name,
                "payment_method": payment.payment_method,
                "collected_by": payment.collected_by,
                "created_at": payment.created_at.isoformat() if payment.created_at else None,
            })
        return result
    finally:
        db.close()

@app.delete("/fees/{fee_id}/payments/{payment_id}")
def delete_fee_payment(fee_id: int, payment_id: int):
    """Delete a payment and recalculate fee status"""
    db = SessionLocal()
    try:
        payment = db.query(FeePaymentDB).filter(
            FeePaymentDB.id == payment_id,
            FeePaymentDB.fee_id == fee_id
        ).first()
        if not payment:
            raise HTTPException(status_code=404, detail="Payment not found")
        
        db.delete(payment)
        db.commit()
        
        # Recalculate fee status
        fee = db.query(FeeDB).filter(FeeDB.id == fee_id).first()
        if fee:
            total_paid = calculate_total_paid(fee_id, db)
            new_status = calculate_fee_status(fee.amount, total_paid, fee.due_date)
            fee.status = new_status
            db.commit()
        
        return {"message": "Payment deleted successfully"}
    finally:
        db.close()

# ==================== Session Routes ====================

@app.post("/sessions/", response_model=Session)
def create_session(session: SessionCreate):
    """Create a new session/season"""
    db = SessionLocal()
    try:
        db_session = SessionDB(**session.model_dump())
        db.add(db_session)
        db.commit()
        db.refresh(db_session)
        # Convert to response format
        return Session(
            id=db_session.id,
            name=db_session.name,
            start_date=db_session.start_date,
            end_date=db_session.end_date,
            status=db_session.status,
            created_at=db_session.created_at.isoformat() if db_session.created_at else None,
            updated_at=db_session.updated_at.isoformat() if db_session.updated_at else None,
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.get("/sessions/", response_model=List[Session])
def get_sessions(status: Optional[str] = None):
    """Get all sessions, optionally filtered by status"""
    db = SessionLocal()
    try:
        query = db.query(SessionDB)
        if status:
            query = query.filter(SessionDB.status == status)
        sessions = query.order_by(SessionDB.start_date.desc()).all()
        return [
            Session(
                id=s.id,
                name=s.name,
                start_date=s.start_date,
                end_date=s.end_date,
                status=s.status,
                created_at=s.created_at.isoformat() if s.created_at else None,
                updated_at=s.updated_at.isoformat() if s.updated_at else None,
            )
            for s in sessions
        ]
    finally:
        db.close()

@app.get("/sessions/{session_id}", response_model=Session)
def get_session(session_id: int):
    """Get a specific session by ID"""
    db = SessionLocal()
    try:
        session = db.query(SessionDB).filter(SessionDB.id == session_id).first()
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        return Session(
            id=session.id,
            name=session.name,
            start_date=session.start_date,
            end_date=session.end_date,
            status=session.status,
            created_at=session.created_at.isoformat() if session.created_at else None,
            updated_at=session.updated_at.isoformat() if session.updated_at else None,
        )
    finally:
        db.close()

@app.put("/sessions/{session_id}", response_model=Session)
def update_session(session_id: int, session_update: SessionUpdate):
    """Update a session"""
    db = SessionLocal()
    try:
        session = db.query(SessionDB).filter(SessionDB.id == session_id).first()
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        update_data = session_update.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(session, key, value)
        
        # Update updated_at timestamp
        session.updated_at = datetime.now()
        
        db.commit()
        db.refresh(session)
        return Session(
            id=session.id,
            name=session.name,
            start_date=session.start_date,
            end_date=session.end_date,
            status=session.status,
            created_at=session.created_at.isoformat() if session.created_at else None,
            updated_at=session.updated_at.isoformat() if session.updated_at else None,
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.delete("/sessions/{session_id}")
def delete_session(session_id: int):
    """Delete a session (only if no batches are assigned)"""
    db = SessionLocal()
    try:
        session = db.query(SessionDB).filter(SessionDB.id == session_id).first()
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        # Check if any batches are assigned to this session
        batches_count = db.query(BatchDB).filter(BatchDB.session_id == session_id).count()
        if batches_count > 0:
            raise HTTPException(
                status_code=400, 
                detail=f"Cannot delete session. {batches_count} batch(es) are assigned to this session."
            )
        
        db.delete(session)
        db.commit()
        return {"message": "Session deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.get("/sessions/{session_id}/batches", response_model=List[Batch])
def get_session_batches(session_id: int):
    """Get all batches assigned to a session"""
    db = SessionLocal()
    try:
        try:
            batches = db.query(BatchDB).filter(BatchDB.session_id == session_id).all()
            return batches
        except Exception as e:
            # If error is about missing session_id column, return empty list
            # (can't filter by session_id if column doesn't exist)
            if "session_id" in str(e) or "UndefinedColumn" in str(e):
                db.rollback()
                return []  # No batches can be assigned if session_id column doesn't exist
            else:
                raise
    finally:
        db.close()

@app.get("/batches/{batch_id}/students", response_model=List[Student])
def get_batch_students(batch_id: int):
    """Get all approved students enrolled in a batch"""
    db = SessionLocal()
    try:
        # Get student IDs from batch_students table (only approved students)
        batch_students = db.query(BatchStudentDB).filter(
            BatchStudentDB.batch_id == batch_id,
            BatchStudentDB.status == "approved"
        ).all()
        student_ids = [bs.student_id for bs in batch_students]
        
        if not student_ids:
            return []
        
        # Get student details
        students = db.query(StudentDB).filter(StudentDB.id.in_(student_ids)).all()
        return students
    finally:
        db.close()

@app.post("/fees/{fee_id}/notify")
def notify_student_about_fee(fee_id: int):
    """Send notification to student about overdue fee"""
    db = SessionLocal()
    try:
        fee = db.query(FeeDB).filter(FeeDB.id == fee_id).first()
        if not fee:
            raise HTTPException(status_code=404, detail="Fee not found")
        
        # Get student details
        student = db.query(StudentDB).filter(StudentDB.id == fee.student_id).first()
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        
        # Calculate pending amount
        total_paid = calculate_total_paid(fee_id, db)
        pending_amount = fee.amount - total_paid
        
        # Create notification
        notification = NotificationDB(
            user_id=fee.student_id,
            user_type="student",
            title="Fee Payment Reminder",
            body=f"Your fee payment of ₹{pending_amount:.2f} is overdue. Please pay the pending amount.",
            type="fee_due",
            data={
                "fee_id": fee_id,
                "pending_amount": pending_amount,
                "due_date": fee.due_date
            }
        )
        db.add(notification)
        db.commit()
        db.refresh(notification)
        
        return {"message": "Notification sent successfully", "notification_id": notification.id}
    finally:
        db.close()

# ==================== Performance Routes ====================

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
                # Try to get batch, handle missing session_id column gracefully
                batch = None
                batch_name = "Unknown"
                try:
                    batch = db.query(BatchDB).filter(BatchDB.id == record.batch_id).first()
                    batch_name = batch.batch_name if batch else "Unknown"
                except Exception as e:
                    if "session_id" in str(e) or "UndefinedColumn" in str(e):
                        db.rollback()
                        from sqlalchemy import text
                        result = db.execute(text("""
                            SELECT batch_name
                            FROM batches
                            WHERE id = :batch_id
                        """), {"batch_id": record.batch_id}).first()
                        if result:
                            batch_name = result[0]
                
                grouped[key] = {
                    "id": record.id,
                    "date": record.date,
                    "batch_id": record.batch_id,
                    "batch_name": batch_name,
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
                # Try to get batch, handle missing session_id column gracefully
                batch = None
                batch_name = "Unknown"
                try:
                    batch = db.query(BatchDB).filter(BatchDB.id == record.batch_id).first()
                    batch_name = batch.batch_name if batch else "Unknown"
                except Exception as e:
                    if "session_id" in str(e) or "UndefinedColumn" in str(e):
                        db.rollback()
                        from sqlalchemy import text
                        result = db.execute(text("""
                            SELECT batch_name
                            FROM batches
                            WHERE id = :batch_id
                        """), {"batch_id": record.batch_id}).first()
                        if result:
                            batch_name = result[0]
                
                grouped[key] = {
                    "id": record.id,
                    "date": record.date,
                    "batch_id": record.batch_id,
                    "batch_name": batch_name,
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
                # Try to get batch, handle missing session_id column gracefully
                batch = None
                batch_name = "Unknown"
                try:
                    batch = db.query(BatchDB).filter(BatchDB.id == record.batch_id).first()
                    batch_name = batch.batch_name if batch else "Unknown"
                except Exception as e:
                    if "session_id" in str(e) or "UndefinedColumn" in str(e):
                        db.rollback()
                        from sqlalchemy import text
                        result = db.execute(text("""
                            SELECT batch_name
                            FROM batches
                            WHERE id = :batch_id
                        """), {"batch_id": record.batch_id}).first()
                        if result:
                            batch_name = result[0]
                
                grouped[key] = {
                    "id": record.id,
                    "date": record.date,
                    "batch_id": record.batch_id,
                    "batch_name": batch_name,
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

# ==================== Performance Routes (Frontend Compatible) ====================

def transform_performance_to_frontend(records: List[PerformanceDB], db) -> Optional[dict]:
    """Transform backend performance records (multiple per date) to frontend format (single per date)"""
    if not records:
        return None
    
    # Get student name
    student = db.query(StudentDB).filter(StudentDB.id == records[0].student_id).first()
    student_name = student.name if student else None
    
    # Initialize with defaults
    result = {
        "id": records[0].id,  # Use first record's ID
        "student_id": records[0].student_id,
        "student_name": student_name,
        "date": records[0].date,
        "serve": 0,
        "smash": 0,
        "footwork": 0,
        "defense": 0,
        "stamina": 0,
        "comments": None,
        "created_at": None
    }
    
    # Aggregate skills from all records
    comments_list = []
    for record in records:
        skill_lower = record.skill.lower()
        if skill_lower == "serve":
            result["serve"] = record.rating
        elif skill_lower == "smash":
            result["smash"] = record.rating
        elif skill_lower == "footwork":
            result["footwork"] = record.rating
        elif skill_lower == "defense":
            result["defense"] = record.rating
        elif skill_lower == "stamina":
            result["stamina"] = record.rating
        
        if record.comments:
            comments_list.append(record.comments)
    
    # Combine comments
    if comments_list:
        result["comments"] = " | ".join(comments_list)
    
    return result

@app.get("/performance/", response_model=List[PerformanceFrontend])
def get_performance_records(
    student_id: Optional[int] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None
):
    """Get performance records in frontend-compatible format with optional filtering"""
    db = SessionLocal()
    try:
        query = db.query(PerformanceDB)
        
        if student_id is not None:
            query = query.filter(PerformanceDB.student_id == student_id)
        
        if start_date:
            query = query.filter(PerformanceDB.date >= start_date)
        
        if end_date:
            query = query.filter(PerformanceDB.date <= end_date)
        
        all_records = query.order_by(PerformanceDB.date.desc()).all()
        
        # Group by date and student_id
        grouped = {}
        for record in all_records:
            key = f"{record.date}_{record.student_id}"
            if key not in grouped:
                grouped[key] = []
            grouped[key].append(record)
        
        # Transform each group to frontend format
        result = []
        for records in grouped.values():
            transformed = transform_performance_to_frontend(records, db)
            if transformed:
                result.append(transformed)
        
        return result
    finally:
        db.close()

@app.get("/performance/{record_id}", response_model=PerformanceFrontend)
def get_performance_record(record_id: int):
    """Get a single performance record by ID in frontend format"""
    db = SessionLocal()
    try:
        # Get the first record with this ID
        first_record = db.query(PerformanceDB).filter(PerformanceDB.id == record_id).first()
        if not first_record:
            raise HTTPException(status_code=404, detail="Performance record not found")
        
        # Get all records for the same date and student
        all_records = db.query(PerformanceDB).filter(
            and_(
                PerformanceDB.student_id == first_record.student_id,
                PerformanceDB.date == first_record.date
            )
        ).all()
        
        transformed = transform_performance_to_frontend(all_records, db)
        if not transformed:
            raise HTTPException(status_code=404, detail="Performance record not found")
        
        return transformed
    finally:
        db.close()

@app.post("/performance/", response_model=PerformanceFrontend)
def create_performance_record_v2(performance_data: PerformanceFrontendCreate):
    """Create performance records (frontend-compatible endpoint)"""
    db = SessionLocal()
    try:
        # Get current user for recorded_by (you may need to adjust this based on your auth)
        recorded_by = "owner"  # Default, should come from auth context
        
        # Get student to find batch_id (required by backend model)
        student = db.query(StudentDB).filter(StudentDB.id == performance_data.student_id).first()
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        
        # Get student's first batch enrollment, or use default
        batch_student = db.query(BatchStudentDB).filter(
            BatchStudentDB.student_id == performance_data.student_id
        ).first()
        batch_id = batch_student.batch_id if batch_student else 1
        
        # Create individual records for each skill with rating > 0
        skill_mappings = {
            "serve": performance_data.serve,
            "smash": performance_data.smash,
            "footwork": performance_data.footwork,
            "defense": performance_data.defense,
            "stamina": performance_data.stamina,
        }
        
        created_records = []
        for skill, rating in skill_mappings.items():
            if rating > 0:  # Only create record if rating is provided
                db_performance = PerformanceDB(
                    student_id=performance_data.student_id,
                    batch_id=batch_id,
                    date=performance_data.date,
                    skill=skill,
                    rating=rating,
                    comments=performance_data.comments if skill == "serve" else None,  # Store comments only once
                    recorded_by=recorded_by
                )
                db.add(db_performance)
                created_records.append(db_performance)
        
        if not created_records:
            raise HTTPException(status_code=400, detail="At least one skill rating must be provided")
        
        db.commit()
        
        # Refresh all records
        for record in created_records:
            db.refresh(record)
        
        # Get all records for this date/student to return in frontend format
        all_records = db.query(PerformanceDB).filter(
            and_(
                PerformanceDB.student_id == performance_data.student_id,
                PerformanceDB.date == performance_data.date
            )
        ).all()
        
        transformed = transform_performance_to_frontend(all_records, db)
        if not transformed:
            raise HTTPException(status_code=500, detail="Failed to create performance record")
        
        return transformed
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.put("/performance/{record_id}", response_model=PerformanceFrontend)
def update_performance_record(record_id: int, performance_update: PerformanceFrontendUpdate):
    """Update performance records (frontend-compatible endpoint)"""
    db = SessionLocal()
    try:
        # Get the first record with this ID
        first_record = db.query(PerformanceDB).filter(PerformanceDB.id == record_id).first()
        if not first_record:
            raise HTTPException(status_code=404, detail="Performance record not found")
        
        # Get all records for the same date and student
        all_records = db.query(PerformanceDB).filter(
            and_(
                PerformanceDB.student_id == first_record.student_id,
                PerformanceDB.date == first_record.date
            )
        ).all()
        
        update_data = performance_update.model_dump(exclude_unset=True)
        
        # Update date if provided
        new_date = update_data.get('date', first_record.date)
        
        # Update skill ratings
        skill_mappings = {
            "serve": update_data.get('serve'),
            "smash": update_data.get('smash'),
            "footwork": update_data.get('footwork'),
            "defense": update_data.get('defense'),
            "stamina": update_data.get('stamina'),
        }
        
        # Update existing records or create new ones
        for skill, new_rating in skill_mappings.items():
            if new_rating is not None:
                # Find existing record for this skill
                existing = next((r for r in all_records if r.skill.lower() == skill), None)
                
                if existing:
                    # Update existing record
                    existing.rating = new_rating
                    if new_rating == 0:
                        # Delete if rating set to 0
                        db.delete(existing)
                elif new_rating > 0:
                    # Create new record if rating > 0
                    new_record = PerformanceDB(
                        student_id=first_record.student_id,
                        batch_id=first_record.batch_id,
                        date=new_date,
                        skill=skill,
                        rating=new_rating,
                        comments=update_data.get('comments') if skill == "serve" else None,
                        recorded_by=first_record.recorded_by
                    )
                    db.add(new_record)
        
        # Update comments (store in first record)
        if 'comments' in update_data:
            first_record.comments = update_data['comments']
        
        # Update date for all records
        if 'date' in update_data:
            for record in all_records:
                record.date = new_date
        
        db.commit()
        
        # Get updated records
        updated_records = db.query(PerformanceDB).filter(
            and_(
                PerformanceDB.student_id == first_record.student_id,
                PerformanceDB.date == new_date
            )
        ).all()
        
        transformed = transform_performance_to_frontend(updated_records, db)
        if not transformed:
            raise HTTPException(status_code=404, detail="Performance record not found")
        
        return transformed
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.delete("/performance/{record_id}")
def delete_performance_record(record_id: int):
    """Delete performance records (all records for the same date/student)"""
    db = SessionLocal()
    try:
        # Get the first record with this ID
        first_record = db.query(PerformanceDB).filter(PerformanceDB.id == record_id).first()
        if not first_record:
            raise HTTPException(status_code=404, detail="Performance record not found")
        
        # Delete all records for the same date and student
        all_records = db.query(PerformanceDB).filter(
            and_(
                PerformanceDB.student_id == first_record.student_id,
                PerformanceDB.date == first_record.date
            )
        ).all()
        
        for record in all_records:
            db.delete(record)
        
        db.commit()
        return {"message": "Performance record deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

# ==================== BMI Routes ====================

def calculate_health_status(bmi_value: float) -> str:
    """Calculate health status based on BMI value"""
    if bmi_value < 18.5:
        return "underweight"
    elif bmi_value < 25:
        return "normal"
    elif bmi_value < 30:
        return "overweight"
    else:
        return "obese"

def bmi_db_to_response(bmi_db: BMIDB) -> BMI:
    """Convert BMIDB to BMI response model with health_status"""
    return BMI(
        id=bmi_db.id,
        student_id=bmi_db.student_id,
        height=bmi_db.height,
        weight=bmi_db.weight,
        bmi=bmi_db.bmi,
        date=bmi_db.date,
        recorded_by=bmi_db.recorded_by,
        health_status=calculate_health_status(bmi_db.bmi)
    )

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
        return bmi_db_to_response(db_bmi)
    finally:
        db.close()

@app.get("/bmi/student/{student_id}")
def get_student_bmi(student_id: int):
    db = SessionLocal()
    try:
        bmi_records = db.query(BMIDB).filter(BMIDB.student_id == student_id).all()
        return [bmi_db_to_response(record) for record in bmi_records]
    finally:
        db.close()

# ==================== BMI Records Routes (Frontend Compatible) ====================

@app.get("/bmi-records/", response_model=List[BMI])
def get_bmi_records(
    student_id: Optional[int] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None
):
    """Get BMI records with optional filtering"""
    db = SessionLocal()
    try:
        query = db.query(BMIDB)
        
        if student_id is not None:
            query = query.filter(BMIDB.student_id == student_id)
        
        if start_date:
            query = query.filter(BMIDB.date >= start_date)
        
        if end_date:
            query = query.filter(BMIDB.date <= end_date)
        
        bmi_records = query.order_by(BMIDB.date.desc()).all()
        return [bmi_db_to_response(record) for record in bmi_records]
    finally:
        db.close()

@app.get("/bmi-records/{record_id}", response_model=BMI)
def get_bmi_record(record_id: int):
    """Get a single BMI record by ID"""
    db = SessionLocal()
    try:
        bmi_record = db.query(BMIDB).filter(BMIDB.id == record_id).first()
        if not bmi_record:
            raise HTTPException(status_code=404, detail="BMI record not found")
        return bmi_db_to_response(bmi_record)
    finally:
        db.close()

@app.post("/bmi-records/", response_model=BMI)
def create_bmi_record_v2(bmi_data: BMICreate):
    """Create a new BMI record (frontend compatible endpoint)"""
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
        return bmi_db_to_response(db_bmi)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.put("/bmi-records/{record_id}", response_model=BMI)
def update_bmi_record(record_id: int, bmi_update: BMIUpdate):
    """Update a BMI record"""
    db = SessionLocal()
    try:
        db_bmi = db.query(BMIDB).filter(BMIDB.id == record_id).first()
        if not db_bmi:
            raise HTTPException(status_code=404, detail="BMI record not found")
        
        # Update fields if provided
        update_data = bmi_update.dict(exclude_unset=True)
        
        # Recalculate BMI if height or weight changed
        height = update_data.get('height', db_bmi.height)
        weight = update_data.get('weight', db_bmi.weight)
        
        if 'height' in update_data or 'weight' in update_data:
            height_m = height / 100
            bmi_value = weight / (height_m ** 2)
            update_data['bmi'] = round(bmi_value, 2)
        
        for key, value in update_data.items():
            setattr(db_bmi, key, value)
        
        db.commit()
        db.refresh(db_bmi)
        return bmi_db_to_response(db_bmi)
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.delete("/bmi-records/{record_id}")
def delete_bmi_record(record_id: int):
    """Delete a BMI record"""
    db = SessionLocal()
    try:
        db_bmi = db.query(BMIDB).filter(BMIDB.id == record_id).first()
        if not db_bmi:
            raise HTTPException(status_code=404, detail="BMI record not found")
        
        db.delete(db_bmi)
        db.commit()
        return {"message": "BMI record deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
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

@app.post("/video-resources/upload")
async def upload_video(
    student_id: int = Form(...),
    title: Optional[str] = Form(None),
    remarks: Optional[str] = Form(None),
    uploaded_by: Optional[int] = Form(None),
    video: UploadFile = File(...)
):
    """Upload a video file for a specific student"""
    db = SessionLocal()
    try:
        # Validate file type
        allowed_extensions = ["mp4", "webm", "mov", "avi", "mkv", "m4v"]
        file_extension = video.filename.split(".")[-1].lower() if video.filename else ""

        if file_extension not in allowed_extensions:
            raise HTTPException(
                status_code=400,
                detail=f"File type not allowed. Allowed types: {', '.join(allowed_extensions)}"
            )

        # Verify student exists
        student = db.query(StudentDB).filter(StudentDB.id == student_id).first()
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")

        # Generate unique filename
        unique_filename = f"video_{uuid.uuid4()}.{file_extension}"
        file_path = UPLOAD_DIR / unique_filename

        # Save file
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(video.file, buffer)

        # Create database record
        db_video = VideoResourceDB(
            student_id=student_id,
            title=title or video.filename,
            url=f"/uploads/{unique_filename}",
            remarks=remarks,
            uploaded_by=uploaded_by
        )
        db.add(db_video)
        db.commit()
        db.refresh(db_video)

        # Return with student name
        return {
            "id": db_video.id,
            "student_id": db_video.student_id,
            "student_name": student.name,
            "title": db_video.title,
            "url": db_video.url,
            "remarks": db_video.remarks,
            "uploaded_by": db_video.uploaded_by,
            "created_at": db_video.created_at
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        db.close()

@app.get("/video-resources/")
def get_video_resources(student_id: Optional[int] = None):
    """Get all video resources, optionally filtered by student_id"""
    db = SessionLocal()
    try:
        query = db.query(VideoResourceDB)

        if student_id is not None:
            query = query.filter(VideoResourceDB.student_id == student_id)

        videos = query.order_by(VideoResourceDB.created_at.desc()).all()

        # Enrich with student names
        result = []
        for video in videos:
            student = db.query(StudentDB).filter(StudentDB.id == video.student_id).first()
            result.append({
                "id": video.id,
                "student_id": video.student_id,
                "student_name": student.name if student else None,
                "title": video.title,
                "url": video.url,
                "remarks": video.remarks,
                "uploaded_by": video.uploaded_by,
                "created_at": video.created_at
            })

        return result
    finally:
        db.close()

@app.get("/video-resources/{video_id}")
def get_video_resource_by_id(video_id: int):
    """Get a specific video resource by ID"""
    db = SessionLocal()
    try:
        video = db.query(VideoResourceDB).filter(VideoResourceDB.id == video_id).first()
        if not video:
            raise HTTPException(status_code=404, detail="Video not found")

        student = db.query(StudentDB).filter(StudentDB.id == video.student_id).first()

        return {
            "id": video.id,
            "student_id": video.student_id,
            "student_name": student.name if student else None,
            "title": video.title,
            "url": video.url,
            "remarks": video.remarks,
            "uploaded_by": video.uploaded_by,
            "created_at": video.created_at
        }
    finally:
        db.close()

@app.delete("/video-resources/{video_id}")
def delete_video_resource(video_id: int):
    """Delete a video resource and its file"""
    db = SessionLocal()
    try:
        video = db.query(VideoResourceDB).filter(VideoResourceDB.id == video_id).first()
        if not video:
            raise HTTPException(status_code=404, detail="Video not found")

        # Try to delete the file
        if video.url:
            filename = video.url.split("/")[-1]
            file_path = UPLOAD_DIR / filename
            if file_path.exists():
                file_path.unlink()

        db.delete(video)
        db.commit()
        return {"message": "Video deleted successfully"}
    finally:
        db.close()

# ==================== Invitation Routes ====================

# ==================== Coach Invitation Routes ====================

@app.post("/coach-invitations/", response_model=CoachInvitation)
def create_coach_invitation(invitation: CoachInvitationCreate):
    """Create a coach invitation - at least phone or email must be provided"""
    # Validate that at least phone or email is provided
    phone = (invitation.coach_phone or '').strip()
    email = (invitation.coach_email or '').strip()
    if not phone and not email:
        raise HTTPException(
            status_code=400,
            detail="At least phone number or email address must be provided"
        )
    
    db = SessionLocal()
    try:
        # Verify owner exists
        owner = db.query(OwnerDB).filter(OwnerDB.id == invitation.owner_id).first()
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")
        
        # Generate unique invite token
        invite_token = secrets.token_urlsafe(32)
        
        # Create invitation record
        invitation_dict = invitation.model_dump()
        invitation_dict['invite_token'] = invite_token
        invitation_dict['created_at'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        db_invitation = CoachInvitationDB(**invitation_dict)
        db.add(db_invitation)
        db.commit()
        db.refresh(db_invitation)
        
        # Generate invite link (using a configurable base URL or default)
        base_url = os.getenv("INVITE_BASE_URL", "https://academy.app")
        invite_link = f"{base_url}/invite/coach/{invite_token}"
        
        # Convert to response model with invite link
        invitation_response = CoachInvitation(
            id=db_invitation.id,
            owner_id=db_invitation.owner_id,
            owner_name=db_invitation.owner_name,
            coach_name=db_invitation.coach_name,
            coach_phone=db_invitation.coach_phone,
            coach_email=db_invitation.coach_email,
            experience_years=db_invitation.experience_years,
            invite_token=db_invitation.invite_token,
            invite_link=invite_link,
            status=db_invitation.status,
            created_at=db_invitation.created_at
        )
        
        return invitation_response
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating coach invitation: {str(e)}")
    finally:
        db.close()

@app.get("/coach-invitations/", response_model=List[CoachInvitation])
def get_all_coach_invitations(owner_id: Optional[int] = None):
    """Get all coach invitations, optionally filtered by owner_id"""
    db = SessionLocal()
    try:
        query = db.query(CoachInvitationDB)
        if owner_id:
            query = query.filter(CoachInvitationDB.owner_id == owner_id)
        invitations = query.order_by(CoachInvitationDB.created_at.desc()).all()
        
        # Add invite links to responses
        base_url = os.getenv("INVITE_BASE_URL", "https://academy.app")
        result = []
        for inv in invitations:
            invite_link = f"{base_url}/invite/coach/{inv.invite_token}"
            result.append(CoachInvitation(
                id=inv.id,
                owner_id=inv.owner_id,
                owner_name=inv.owner_name,
                coach_name=inv.coach_name,
                coach_phone=inv.coach_phone,
                coach_email=inv.coach_email,
                experience_years=inv.experience_years,
                invite_token=inv.invite_token,
                invite_link=invite_link,
                status=inv.status,
                created_at=inv.created_at
            ))
        return result
    finally:
        db.close()

@app.get("/coach-invitations/{coach_email}")
def get_coach_invitations_by_email(coach_email: str):
    """Get coach invitations by email address"""
    db = SessionLocal()
    try:
        invitations = db.query(CoachInvitationDB).filter(
            CoachInvitationDB.coach_email == coach_email
        ).all()
        
        # Add invite links to responses
        base_url = os.getenv("INVITE_BASE_URL", "https://academy.app")
        result = []
        for inv in invitations:
            invite_link = f"{base_url}/invite/coach/{inv.invite_token}"
            result.append(CoachInvitation(
                id=inv.id,
                owner_id=inv.owner_id,
                owner_name=inv.owner_name,
                coach_name=inv.coach_name,
                coach_phone=inv.coach_phone,
                coach_email=inv.coach_email,
                experience_years=inv.experience_years,
                invite_token=inv.invite_token,
                invite_link=invite_link,
                status=inv.status,
                created_at=inv.created_at
            ))
        return result
    finally:
        db.close()

@app.get("/coach-invitations/token/{invite_token}")
def get_coach_invitation_by_token(invite_token: str):
    """Get coach invitation by invite token"""
    db = SessionLocal()
    try:
        invitation = db.query(CoachInvitationDB).filter(
            CoachInvitationDB.invite_token == invite_token
        ).first()
        
        if not invitation:
            raise HTTPException(status_code=404, detail="Invitation not found")
        
        base_url = os.getenv("INVITE_BASE_URL", "https://academy.app")
        invite_link = f"{base_url}/invite/coach/{invitation.invite_token}"
        
        return CoachInvitation(
            id=invitation.id,
            owner_id=invitation.owner_id,
            owner_name=invitation.owner_name,
            coach_name=invitation.coach_name,
            coach_phone=invitation.coach_phone,
            coach_email=invitation.coach_email,
            experience_years=invitation.experience_years,
            invite_token=invitation.invite_token,
            invite_link=invite_link,
            status=invitation.status,
            created_at=invitation.created_at
        )
    finally:
        db.close()

@app.put("/coach-invitations/{invitation_id}")
def update_coach_invitation(invitation_id: int, invitation_update: CoachInvitationUpdate):
    """Update coach invitation status"""
    db = SessionLocal()
    try:
        invitation = db.query(CoachInvitationDB).filter(CoachInvitationDB.id == invitation_id).first()
        if not invitation:
            raise HTTPException(status_code=404, detail="Invitation not found")
        
        invitation.status = invitation_update.status
        
        # If approved, automatically create coach account
        if invitation_update.status == "approved":
            # Check if coach already exists
            existing_coach = None
            if invitation.coach_email:
                existing_coach = db.query(CoachDB).filter(CoachDB.email == invitation.coach_email).first()
            elif invitation.coach_phone:
                existing_coach = db.query(CoachDB).filter(CoachDB.phone == invitation.coach_phone).first()
            
            if not existing_coach:
                # Create coach account with default password (coach will change it)
                default_password = hash_password("Welcome123!")  # Default password
                new_coach = CoachDB(
                    name=invitation.coach_name or "Coach",
                    email=invitation.coach_email or f"coach{invitation.id}@academy.com",
                    phone=invitation.coach_phone or "",
                    password=default_password,
                    specialization=None,
                    experience_years=invitation.experience_years,
                    status="active"
                )
                db.add(new_coach)
        
        db.commit()
        db.refresh(invitation)
        
        base_url = os.getenv("INVITE_BASE_URL", "https://academy.app")
        invite_link = f"{base_url}/invite/coach/{invitation.invite_token}"
        
        return CoachInvitation(
            id=invitation.id,
            owner_id=invitation.owner_id,
            owner_name=invitation.owner_name,
            coach_name=invitation.coach_name,
            coach_phone=invitation.coach_phone,
            coach_email=invitation.coach_email,
            experience_years=invitation.experience_years,
            invite_token=invitation.invite_token,
            invite_link=invite_link,
            status=invitation.status,
            created_at=invitation.created_at
        )
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating invitation: {str(e)}")
    finally:
        db.close()

@app.post("/invitations/", response_model=Invitation)
def create_invitation(invitation: InvitationCreate):
    # Validate that at least phone or email is provided
    phone = (invitation.student_phone or '').strip()
    email = (invitation.student_email or '').strip()
    if not phone and not email:
        raise HTTPException(
            status_code=400,
            detail="At least phone number or email address must be provided"
        )
    
    db = SessionLocal()
    try:
        # Generate unique invite token
        invite_token = secrets.token_urlsafe(32)
        
        # Create invitation record
        invitation_dict = invitation.model_dump()  # Use model_dump() instead of dict() for Pydantic v2
        invitation_dict['invite_token'] = invite_token
        invitation_dict['created_at'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        db_invitation = InvitationDB(**invitation_dict)
        db.add(db_invitation)
        db.commit()
        db.refresh(db_invitation)
        
        # Generate invite link (using a configurable base URL or default)
        # In production, this should come from environment variables
        base_url = os.getenv("INVITE_BASE_URL", "https://academy.app")
        invite_link = f"{base_url}/invite/{invite_token}"
        
        # Convert to response model with invite link
        invitation_response = Invitation(
            id=db_invitation.id,
            coach_id=db_invitation.coach_id,
            coach_name=db_invitation.coach_name,
            student_phone=db_invitation.student_phone,
            student_email=db_invitation.student_email,
            batch_id=db_invitation.batch_id,
            invite_token=db_invitation.invite_token,
            invite_link=invite_link,
            status=db_invitation.status,
            created_at=db_invitation.created_at
        )
        
        return invitation_response
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()


@app.get("/invitations/pending", response_model=List[Invitation])
def get_pending_invitations():
    """Get all pending invitations (waiting for student registration) - owner only"""
    db = SessionLocal()
    try:
        invitations = db.query(InvitationDB).filter(
            InvitationDB.status == "pending"
        ).order_by(InvitationDB.created_at.desc()).all()
        
        # Add invite links
        base_url = os.getenv("INVITE_BASE_URL", "https://academy.app")
        result = []
        for inv in invitations:
            invite_link = f"{base_url}/invite/{inv.invite_token}"
            result.append(Invitation(
                id=inv.id,
                coach_id=inv.coach_id,
                coach_name=inv.coach_name,
                student_phone=inv.student_phone,
                student_email=inv.student_email,
                batch_id=inv.batch_id,
                invite_token=inv.invite_token,
                invite_link=invite_link,
                status=inv.status,
                created_at=inv.created_at
            ))
        return result
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
        # Count coaches (owners are in separate table)
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

def _db_announcement_to_pydantic(db_announcement: AnnouncementDB) -> Announcement:
    """Convert database announcement to Pydantic model with proper datetime serialization"""
    return Announcement(
        id=db_announcement.id,
        title=db_announcement.title,
        message=db_announcement.message,
        target_audience=db_announcement.target_audience,
        priority=db_announcement.priority,
        created_by=db_announcement.created_by,
        creator_type=db_announcement.creator_type,
        created_at=db_announcement.created_at.isoformat() if hasattr(db_announcement.created_at, 'isoformat') else str(db_announcement.created_at),
        scheduled_at=db_announcement.scheduled_at.isoformat() if db_announcement.scheduled_at and hasattr(db_announcement.scheduled_at, 'isoformat') else (str(db_announcement.scheduled_at) if db_announcement.scheduled_at else None),
        is_sent=db_announcement.is_sent
    )

@app.post("/api/announcements/", response_model=Announcement)
def create_announcement(announcement: AnnouncementCreate):
    """Create a new announcement"""
    db = SessionLocal()
    try:
        # Validate that the creator (coach/owner) exists
        if announcement.creator_type == "owner":
            creator = db.query(OwnerDB).filter(OwnerDB.id == announcement.created_by).first()
            if not creator:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid created_by user ID. Owner with ID {announcement.created_by} does not exist."
                )
        else:  # coach
            creator = db.query(CoachDB).filter(CoachDB.id == announcement.created_by).first()
            if not creator:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid created_by user ID. Coach with ID {announcement.created_by} does not exist."
                )
        
        # Convert scheduled_at string to datetime if provided
        announcement_data = announcement.model_dump()
        if announcement_data.get('scheduled_at'):
            try:
                # Parse ISO format datetime string
                announcement_data['scheduled_at'] = datetime.fromisoformat(announcement_data['scheduled_at'].replace('Z', '+00:00'))
            except (ValueError, AttributeError) as e:
                raise HTTPException(status_code=400, detail=f"Invalid scheduled_at format: {str(e)}")
        
        db_announcement = AnnouncementDB(**announcement_data)
        db.add(db_announcement)
        db.commit()
        db.refresh(db_announcement)
        return _db_announcement_to_pydantic(db_announcement)
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        db.close()

@app.get("/api/announcements/", response_model=List[Announcement])
def get_announcements(
    target_audience: Optional[str] = Query(None, description="Filter by target audience"),
    priority: Optional[str] = Query(None, description="Filter by priority"),
    is_sent: Optional[bool] = Query(None, description="Filter by sent status")
):
    """Get all announcements, optionally filtered by target audience, priority, or is_sent"""
    db = SessionLocal()
    try:
        query = db.query(AnnouncementDB)
        if target_audience:
            query = query.filter(AnnouncementDB.target_audience.in_([target_audience, "all"]))
        if priority:
            query = query.filter(AnnouncementDB.priority == priority)
        if is_sent is not None:
            query = query.filter(AnnouncementDB.is_sent == is_sent)
        announcements = query.order_by(AnnouncementDB.created_at.desc()).all()
        return [_db_announcement_to_pydantic(ann) for ann in announcements]
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
        return _db_announcement_to_pydantic(announcement)
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

        update_data = announcement.model_dump(exclude_unset=True)
        # Convert scheduled_at string to datetime if provided
        if 'scheduled_at' in update_data and update_data['scheduled_at'] is not None:
            try:
                # Parse ISO format datetime string
                update_data['scheduled_at'] = datetime.fromisoformat(update_data['scheduled_at'].replace('Z', '+00:00'))
            except (ValueError, AttributeError) as e:
                raise HTTPException(status_code=400, detail=f"Invalid scheduled_at format: {str(e)}")
        
        for key, value in update_data.items():
            setattr(db_announcement, key, value)

        db.commit()
        db.refresh(db_announcement)
        return _db_announcement_to_pydantic(db_announcement)
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
        end_date=db_event.end_date.isoformat() if db_event.end_date and isinstance(db_event.end_date, date) else (str(db_event.end_date) if db_event.end_date else None),
        description=db_event.description,
        created_by=db_event.created_by,
        creator_type=db_event.creator_type or "coach",
        related_leave_request_id=db_event.related_leave_request_id,
        created_at=db_event.created_at.isoformat() if hasattr(db_event.created_at, 'isoformat') else str(db_event.created_at),
    )

@app.post("/api/calendar-events/", response_model=CalendarEvent)
def create_calendar_event(event: CalendarEventCreate):
    """Create a new calendar event"""
    db = SessionLocal()
    try:
        # Validate that the creator (coach/owner) exists
        if event.creator_type == "owner":
            creator = db.query(OwnerDB).filter(OwnerDB.id == event.created_by).first()
            if not creator:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid created_by user ID. Owner with ID {event.created_by} does not exist."
                )
        else:  # coach
            creator = db.query(CoachDB).filter(CoachDB.id == event.created_by).first()
            if not creator:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid created_by user ID. Coach with ID {event.created_by} does not exist."
                )
        
        # Convert date string to date object
        event_date = datetime.strptime(event.date, "%Y-%m-%d").date()
        
        # Convert end_date if provided
        event_end_date = None
        if event.end_date:
            event_end_date = datetime.strptime(event.end_date, "%Y-%m-%d").date()
        
        # Create database event with proper date conversion
        db_event = CalendarEventDB(
            title=event.title,
            event_type=event.event_type,
            date=event_date,
            end_date=event_end_date,
            description=event.description,
            created_by=event.created_by,
            creator_type=event.creator_type,
            related_leave_request_id=event.related_leave_request_id,
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
                detail=f"Invalid created_by user ID. User with ID {event.created_by} does not exist."
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
    from sqlalchemy import or_
    db = SessionLocal()
    try:
        query = db.query(CalendarEventDB)

        if start_date and end_date:
            # Convert strings to date objects for comparison
            start_date_obj = datetime.strptime(start_date, "%Y-%m-%d").date()
            end_date_obj = datetime.strptime(end_date, "%Y-%m-%d").date()
            # Include events that:
            # 1. Start within the range, OR
            # 2. End within the range, OR
            # 3. Span the entire range (start before and end after)
            query = query.filter(
                or_(
                    # Event starts within range
                    (CalendarEventDB.date >= start_date_obj) & (CalendarEventDB.date <= end_date_obj),
                    # Event ends within range (if end_date exists)
                    (CalendarEventDB.end_date.isnot(None)) & 
                    (CalendarEventDB.end_date >= start_date_obj) & 
                    (CalendarEventDB.end_date <= end_date_obj),
                    # Event spans the range (starts before and ends after)
                    (CalendarEventDB.date <= start_date_obj) & 
                    (CalendarEventDB.end_date.isnot(None)) & 
                    (CalendarEventDB.end_date >= end_date_obj),
                    # Single-day events that fall within range
                    (CalendarEventDB.end_date.is_(None)) & 
                    (CalendarEventDB.date >= start_date_obj) & 
                    (CalendarEventDB.date <= end_date_obj)
                )
            )
        elif start_date:
            # Only start_date provided - include events that start on or after this date
            # or events that end on or after this date
            start_date_obj = datetime.strptime(start_date, "%Y-%m-%d").date()
            query = query.filter(
                or_(
                    CalendarEventDB.date >= start_date_obj,
                    (CalendarEventDB.end_date.isnot(None)) & (CalendarEventDB.end_date >= start_date_obj)
                )
            )
        elif end_date:
            # Only end_date provided - include events that end on or before this date
            # or events that start on or before this date
            end_date_obj = datetime.strptime(end_date, "%Y-%m-%d").date()
            query = query.filter(
                or_(
                    CalendarEventDB.date <= end_date_obj,
                    (CalendarEventDB.end_date.isnot(None)) & (CalendarEventDB.end_date <= end_date_obj)
                )
            )
        
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
        event_dict = event.model_dump(exclude_unset=True)
        if 'date' in event_dict and isinstance(event_dict['date'], str):
            event_dict['date'] = datetime.strptime(event_dict['date'], "%Y-%m-%d").date()
        if 'end_date' in event_dict and isinstance(event_dict['end_date'], str):
            event_dict['end_date'] = datetime.strptime(event_dict['end_date'], "%Y-%m-%d").date()
        elif 'end_date' in event_dict and event_dict['end_date'] is None:
            event_dict['end_date'] = None
        
        # Only update allowed fields (exclude created_by and creator_type as they shouldn't change)
        allowed_fields = {'title', 'event_type', 'date', 'end_date', 'description'}
        for key, value in event_dict.items():
            if key in allowed_fields:
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

# ==================== Leave Request Routes ====================

@app.post("/leave-requests/", response_model=LeaveRequest)
def create_leave_request(request: LeaveRequestCreate):
    """Create a leave request - coaches can submit leave requests"""
    db = SessionLocal()
    try:
        # Verify coach exists
        coach = db.query(CoachDB).filter(CoachDB.id == request.coach_id).first()
        if not coach:
            raise HTTPException(status_code=404, detail="Coach not found")
        
        # Parse dates
        from datetime import datetime
        start_date = datetime.strptime(request.start_date, "%Y-%m-%d").date()
        end_date = datetime.strptime(request.end_date, "%Y-%m-%d").date()
        
        if start_date > end_date:
            raise HTTPException(status_code=400, detail="End date must be after start date")
        
        # Create leave request
        db_request = LeaveRequestDB(
            coach_id=request.coach_id,
            coach_name=request.coach_name,
            start_date=start_date,
            end_date=end_date,
            leave_type=request.leave_type,
            reason=request.reason,
            status="pending"
        )
        db.add(db_request)
        db.commit()
        db.refresh(db_request)
        
        # Convert to response model
        return LeaveRequest(
            id=db_request.id,
            coach_id=db_request.coach_id,
            coach_name=db_request.coach_name,
            start_date=db_request.start_date.strftime("%Y-%m-%d"),
            end_date=db_request.end_date.strftime("%Y-%m-%d"),
            leave_type=db_request.leave_type,
            reason=db_request.reason,
            status=db_request.status,
            submitted_at=db_request.submitted_at.isoformat() if db_request.submitted_at else "",
            reviewed_by=db_request.reviewed_by,
            reviewed_at=db_request.reviewed_at.isoformat() if db_request.reviewed_at else None,
            review_notes=db_request.review_notes
        )
    except HTTPException:
        db.rollback()
        raise
    except ValueError as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=f"Invalid date format: {str(e)}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating leave request: {str(e)}")
    finally:
        db.close()

@app.get("/leave-requests/", response_model=List[LeaveRequest])
def get_leave_requests(
    coach_id: Optional[int] = None,
    status: Optional[str] = None,
    owner_id: Optional[int] = None
):
    """Get leave requests - owners can see all, coaches can see their own"""
    # #region agent log
    import json
    log_data = {
        "location": "main.py:5319",
        "message": "get_leave_requests endpoint called",
        "data": {"coach_id": coach_id, "status": status, "owner_id": owner_id},
        "timestamp": __import__("time").time() * 1000,
        "sessionId": "debug-session",
        "runId": "run1",
        "hypothesisId": "A"
    }
    try:
        with open(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log", "a") as f:
            f.write(json.dumps(log_data) + "\n")
    except: pass
    # #endregion
    db = SessionLocal()
    try:
        # #region agent log
        from sqlalchemy import inspect
        inspector = inspect(db.bind)
        tables = inspector.get_table_names()
        table_exists = 'leave_requests' in tables
        log_data2 = {
            "location": "main.py:5330",
            "message": "Checking if leave_requests table exists",
            "data": {"table_exists": table_exists, "all_tables": tables},
            "timestamp": __import__("time").time() * 1000,
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A"
        }
        try:
            with open(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log", "a") as f:
                f.write(json.dumps(log_data2) + "\n")
        except: pass
        # #endregion
        
        query = db.query(LeaveRequestDB)
        
        # Filter by coach_id if provided (for coaches viewing their own requests)
        if coach_id:
            query = query.filter(LeaveRequestDB.coach_id == coach_id)
        
        # Filter by status if provided
        if status:
            query = query.filter(LeaveRequestDB.status == status)
        
        # If owner_id is provided, they can see all requests (for approval)
        # Otherwise, return all requests ordered by submission date
        requests = query.order_by(LeaveRequestDB.submitted_at.desc()).all()
        
        # #region agent log
        log_data3 = {
            "location": "main.py:5340",
            "message": "Query executed, found requests",
            "data": {"request_count": len(requests), "request_ids": [r.id for r in requests]},
            "timestamp": __import__("time").time() * 1000,
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "B"
        }
        try:
            with open(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log", "a") as f:
                f.write(json.dumps(log_data3) + "\n")
        except: pass
        # #endregion
        
        result = []
        for req in requests:
            result.append(LeaveRequest(
                id=req.id,
                coach_id=req.coach_id,
                coach_name=req.coach_name,
                start_date=req.start_date.strftime("%Y-%m-%d"),
                end_date=req.end_date.strftime("%Y-%m-%d"),
                leave_type=req.leave_type,
                reason=req.reason,
                status=req.status,
                submitted_at=req.submitted_at.isoformat() if req.submitted_at else "",
                reviewed_by=req.reviewed_by,
                reviewed_at=req.reviewed_at.isoformat() if req.reviewed_at else None,
                review_notes=req.review_notes
            ))
        
        # #region agent log
        log_data4 = {
            "location": "main.py:5358",
            "message": "Returning result",
            "data": {"result_count": len(result)},
            "timestamp": __import__("time").time() * 1000,
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "B"
        }
        try:
            with open(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log", "a") as f:
                f.write(json.dumps(log_data4) + "\n")
        except: pass
        # #endregion
        
        return result
    except Exception as e:
        # #region agent log
        log_data5 = {
            "location": "main.py:5360",
            "message": "Error in get_leave_requests",
            "data": {"error": str(e), "error_type": type(e).__name__},
            "timestamp": __import__("time").time() * 1000,
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "C"
        }
        try:
            with open(r"c:\Users\morch\Documents\Code\RallyOn\shuttler\.cursor\debug.log", "a") as f:
                f.write(json.dumps(log_data5) + "\n")
        except: pass
        # #endregion
        raise
    finally:
        db.close()

@app.get("/leave-requests/{request_id}", response_model=LeaveRequest)
def get_leave_request(request_id: int):
    """Get a specific leave request by ID"""
    db = SessionLocal()
    try:
        request = db.query(LeaveRequestDB).filter(LeaveRequestDB.id == request_id).first()
        if not request:
            raise HTTPException(status_code=404, detail="Leave request not found")
        
        return LeaveRequest(
            id=request.id,
            coach_id=request.coach_id,
            coach_name=request.coach_name,
            start_date=request.start_date.strftime("%Y-%m-%d"),
            end_date=request.end_date.strftime("%Y-%m-%d"),
            leave_type=request.leave_type,
            reason=request.reason,
            status=request.status,
            submitted_at=request.submitted_at.isoformat() if request.submitted_at else "",
            reviewed_by=request.reviewed_by,
            reviewed_at=request.reviewed_at.isoformat() if request.reviewed_at else None,
            review_notes=request.review_notes
        )
    finally:
        db.close()

@app.put("/leave-requests/{request_id}", response_model=LeaveRequest)
def update_leave_request(request_id: int, update: LeaveRequestUpdate, owner_id: int):
    """Update leave request status - only owners can approve/reject"""
    db = SessionLocal()
    try:
        # Verify owner exists
        owner = db.query(OwnerDB).filter(OwnerDB.id == owner_id).first()
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")
        
        # Get leave request
        db_request = db.query(LeaveRequestDB).filter(LeaveRequestDB.id == request_id).first()
        if not db_request:
            raise HTTPException(status_code=404, detail="Leave request not found")
        
        # Validate status
        if update.status not in ["approved", "rejected"]:
            raise HTTPException(status_code=400, detail="Status must be 'approved' or 'rejected'")
        
        # Update request
        from datetime import datetime, timedelta
        db_request.status = update.status
        db_request.reviewed_by = owner_id
        db_request.reviewed_at = datetime.now()
        db_request.review_notes = update.review_notes
        
        # If approved, create calendar event(s) for the leave period
        if update.status == "approved":
            # Check if calendar event already exists for this leave request
            existing_event = db.query(CalendarEventDB).filter(
                CalendarEventDB.related_leave_request_id == request_id
            ).first()
            
            if not existing_event:
                # Create calendar event for the leave period
                # Use start_date as the main date, end_date for range
                # Format leave type: 'sick' -> 'Sick', 'personal' -> 'Personal', etc.
                leave_type_formatted = db_request.leave_type.replace('_', ' ').title()
                leave_title = f"{db_request.coach_name} - {leave_type_formatted} Leave"
                leave_description = f"Leave request: {db_request.reason}"
                
                calendar_event = CalendarEventDB(
                    title=leave_title,
                    event_type="leave",
                    date=db_request.start_date,
                    end_date=db_request.end_date,
                    description=leave_description,
                    created_by=owner_id,  # Created by owner who approved
                    creator_type="owner",
                    related_leave_request_id=request_id
                )
                db.add(calendar_event)
        
        # If rejected, remove any existing calendar events for this leave request
        elif update.status == "rejected":
            existing_events = db.query(CalendarEventDB).filter(
                CalendarEventDB.related_leave_request_id == request_id
            ).all()
            for event in existing_events:
                db.delete(event)
        
        db.commit()
        db.refresh(db_request)
        
        # Convert to response model
        return LeaveRequest(
            id=db_request.id,
            coach_id=db_request.coach_id,
            coach_name=db_request.coach_name,
            start_date=db_request.start_date.strftime("%Y-%m-%d"),
            end_date=db_request.end_date.strftime("%Y-%m-%d"),
            leave_type=db_request.leave_type,
            reason=db_request.reason,
            status=db_request.status,
            submitted_at=db_request.submitted_at.isoformat() if db_request.submitted_at else "",
            reviewed_by=db_request.reviewed_by,
            reviewed_at=db_request.reviewed_at.isoformat() if db_request.reviewed_at else None,
            review_notes=db_request.review_notes
        )
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating leave request: {str(e)}")
    finally:
        db.close()

@app.delete("/leave-requests/{request_id}")
def delete_leave_request(request_id: int, coach_id: int):
    """Delete a leave request - only the coach who created it can delete (if pending)"""
    db = SessionLocal()
    try:
        db_request = db.query(LeaveRequestDB).filter(LeaveRequestDB.id == request_id).first()
        if not db_request:
            raise HTTPException(status_code=404, detail="Leave request not found")
        
        # Verify coach owns this request
        if db_request.coach_id != coach_id:
            raise HTTPException(status_code=403, detail="You can only delete your own leave requests")
        
        # Only allow deletion if status is pending
        if db_request.status != "pending":
            raise HTTPException(status_code=400, detail="Can only delete pending leave requests")
        
        db.delete(db_request)
        db.commit()
        return {"message": "Leave request deleted successfully"}
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting leave request: {str(e)}")
    finally:
        db.close()

@app.post("/leave-requests/{request_id}/modify", response_model=LeaveRequest)
def submit_leave_modification(request_id: int, modification: LeaveRequestModificationCreate):
    """Submit a modification to an approved leave request"""
    db = SessionLocal()
    try:
        db_request = db.query(LeaveRequestDB).filter(LeaveRequestDB.id == request_id).first()
        if not db_request:
            raise HTTPException(status_code=404, detail="Leave request not found")
        
        # Only allowed if original request is approved
        if db_request.status != "approved":
            raise HTTPException(status_code=400, detail="Only approved leave requests can be modified")
        
        # Verify modification date range (max 7 days)
        from datetime import datetime
        start = datetime.strptime(modification.start_date, "%Y-%m-%d")
        end = datetime.strptime(modification.end_date, "%Y-%m-%d")
        days = (end - start).days + 1
        
        if days > 7:
            raise HTTPException(status_code=400, detail="Modification leave duration cannot exceed 7 days")
        
        if days < 1:
            raise HTTPException(status_code=400, detail="End date must be after start date")
        
        # Update modification fields
        db_request.modification_start_date = start.date()
        db_request.modification_end_date = end.date()
        db_request.modification_reason = modification.reason
        db_request.modification_status = "pending"
        
        db.commit()
        db.refresh(db_request)
        
        # Determine effective response values
        mod_start = db_request.modification_start_date.strftime("%Y-%m-%d") if db_request.modification_start_date else None
        mod_end = db_request.modification_end_date.strftime("%Y-%m-%d") if db_request.modification_end_date else None
        
        return LeaveRequest(
            id=db_request.id,
            coach_id=db_request.coach_id,
            coach_name=db_request.coach_name,
            start_date=db_request.start_date.strftime("%Y-%m-%d"),
            end_date=db_request.end_date.strftime("%Y-%m-%d"),
            leave_type=db_request.leave_type,
            reason=db_request.reason,
            status=db_request.status,
            submitted_at=db_request.submitted_at.isoformat() if db_request.submitted_at else "",
            reviewed_by=db_request.reviewed_by,
            reviewed_at=db_request.reviewed_at.isoformat() if db_request.reviewed_at else None,
            review_notes=db_request.review_notes,
            modification_start_date=mod_start,
            modification_end_date=mod_end,
            modification_reason=db_request.modification_reason,
            modification_status=db_request.modification_status
        )
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error submitting modification: {str(e)}")
    finally:
        db.close()

@app.put("/leave-requests/{request_id}/review-modification", response_model=LeaveRequest)
def review_modification_request(request_id: int, review: LeaveRequestModificationReview):
    """Review a leave modification request (approve mod, reject mod, or reject all)"""
    db = SessionLocal()
    try:
        # Verify owner exists
        owner = db.query(OwnerDB).filter(OwnerDB.id == review.owner_id).first()
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")
            
        db_request = db.query(LeaveRequestDB).filter(LeaveRequestDB.id == request_id).first()
        if not db_request:
            raise HTTPException(status_code=404, detail="Leave request not found")
        
        if db_request.modification_status != "pending":
            raise HTTPException(status_code=400, detail="No pending modification to review")
            
        if review.action == "approve":
            # Approve Modification: Update main dates to modified dates
            db_request.modification_status = "approved"
            db_request.start_date = db_request.modification_start_date
            db_request.end_date = db_request.modification_end_date
            # Original reason is kept? Or updated? 
            # Plan says: "Update Calendar". Reason implies we might want to append modification reason?
            # Let's append mod reason to notes or keep purely as modification metadata.
            # We will rely on updated start/end dates for the calendar.
            
            # Update Calendar Events
            existing_event = db.query(CalendarEventDB).filter(
                CalendarEventDB.related_leave_request_id == request_id
            ).first()
            
            if existing_event:
                existing_event.date = db_request.start_date
                existing_event.end_date = db_request.end_date
                existing_event.description = f"Leave request: {db_request.reason} (Modified: {db_request.modification_reason})"
            
        elif review.action == "reject_modification":
            # Reject Modification: Keep original dates
            db_request.modification_status = "rejected"
            # No change to Calendar
            
        elif review.action == "reject_all":
            # Reject Both: Cancel entire leave
            db_request.status = "rejected"
            db_request.modification_status = "rejected"
            
            # Remove from Calendar
            existing_events = db.query(CalendarEventDB).filter(
                CalendarEventDB.related_leave_request_id == request_id
            ).all()
            for event in existing_events:
                db.delete(event)
                
        else:
            raise HTTPException(status_code=400, detail="Invalid action")
            
        db_request.reviewed_by = review.owner_id
        from datetime import datetime
        db_request.reviewed_at = datetime.now()
        if review.review_notes:
            db_request.review_notes = review.review_notes

        db.commit()
        db.refresh(db_request)
        
        # Prepare response
        mod_start = db_request.modification_start_date.strftime("%Y-%m-%d") if db_request.modification_start_date else None
        mod_end = db_request.modification_end_date.strftime("%Y-%m-%d") if db_request.modification_end_date else None
        
        return LeaveRequest(
            id=db_request.id,
            coach_id=db_request.coach_id,
            coach_name=db_request.coach_name,
            start_date=db_request.start_date.strftime("%Y-%m-%d"),
            end_date=db_request.end_date.strftime("%Y-%m-%d"),
            leave_type=db_request.leave_type,
            reason=db_request.reason,
            status=db_request.status,
            submitted_at=db_request.submitted_at.isoformat() if db_request.submitted_at else "",
            reviewed_by=db_request.reviewed_by,
            reviewed_at=db_request.reviewed_at.isoformat() if db_request.reviewed_at else None,
            review_notes=db_request.review_notes,
            modification_start_date=mod_start,
            modification_end_date=mod_end,
            modification_reason=db_request.modification_reason,
            modification_status=db_request.modification_status
        )
        
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error reviewing modification: {str(e)}")
    finally:
        db.close()

# ==================== Student Registration Request Routes ====================

@app.post("/students/registration-request", response_model=StudentRegistrationRequest)
def create_student_registration_request(request: StudentRegistrationRequestCreate):
    """Create a student registration request - requires owner approval"""
    db = SessionLocal()
    try:
        # Check if email already exists in students table
        existing_student = db.query(StudentDB).filter(StudentDB.email == request.email).first()
        if existing_student:
            raise HTTPException(status_code=400, detail="Email already registered")
        
        # Check if email already exists in pending requests
        existing_request = db.query(StudentRegistrationRequestDB).filter(
            StudentRegistrationRequestDB.email == request.email
        ).first()
        if existing_request:
            raise HTTPException(status_code=400, detail="Registration request already exists for this email")
        
        # Hash password
        hashed_password = hash_password(request.password)
        
        # Check for invite token and link
        invitation_id = None
        invited_by_coach_id = None
        
        if request.invite_token:
            invitation = db.query(InvitationDB).filter(
                InvitationDB.invite_token == request.invite_token
            ).first()
            if invitation:
                invitation_id = invitation.id
                invited_by_coach_id = invitation.coach_id
        
        # Create registration request
        db_request = StudentRegistrationRequestDB(
            name=request.name,
            email=request.email,
            phone=request.phone,
            password=hashed_password,
            guardian_name=request.guardian_name,
            guardian_phone=request.guardian_phone,
            date_of_birth=request.date_of_birth,
            address=request.address,
            t_shirt_size=request.t_shirt_size,
            blood_group=request.blood_group,
            invitation_id=invitation_id,
            invited_by_coach_id=invited_by_coach_id,
            status="pending"
        )
        db.add(db_request)
        db.commit()
        db.refresh(db_request)
        
        # Get coach name if invited
        invited_by_coach_name = None
        if invited_by_coach_id:
            coach = db.query(CoachDB).filter(CoachDB.id == invited_by_coach_id).first()
            if coach:
                invited_by_coach_name = coach.name
        
        # Convert to response model
        return StudentRegistrationRequest(
            id=db_request.id,
            name=db_request.name,
            email=db_request.email,
            phone=db_request.phone,
            status=db_request.status,
            submitted_at=db_request.submitted_at.isoformat() if db_request.submitted_at else "",
            reviewed_by=db_request.reviewed_by,
            reviewed_at=db_request.reviewed_at.isoformat() if db_request.reviewed_at else None,
            review_notes=db_request.review_notes,
            guardian_name=db_request.guardian_name,
            guardian_phone=db_request.guardian_phone,
            date_of_birth=db_request.date_of_birth,
            address=db_request.address,
            t_shirt_size=db_request.t_shirt_size,
            blood_group=db_request.blood_group,
            invitation_id=db_request.invitation_id,
            invited_by_coach_id=db_request.invited_by_coach_id,
            invited_by_coach_name=invited_by_coach_name
        )
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating registration request: {str(e)}")
    finally:
        db.close()

@app.get("/student-registration-requests/", response_model=List[StudentRegistrationRequest])
def get_student_registration_requests(
    status: Optional[str] = Query(None, description="Filter by status: pending, approved, rejected")
):
    """Get all student registration requests - owner only"""
    db = SessionLocal()
    try:
        query = db.query(StudentRegistrationRequestDB)
        if status:
            query = query.filter(StudentRegistrationRequestDB.status == status)
        requests = query.order_by(StudentRegistrationRequestDB.submitted_at.desc()).all()
        
        # Pre-fetch coaches if needed
        coach_map = {}
        coach_ids = {req.invited_by_coach_id for req in requests if req.invited_by_coach_id}
        if coach_ids:
            coaches = db.query(CoachDB).filter(CoachDB.id.in_(coach_ids)).all()
            coach_map = {c.id: c.name for c in coaches}
        
        # Convert to response models
        return [
            StudentRegistrationRequest(
                id=req.id,
                name=req.name,
                email=req.email,
                phone=req.phone,
                status=req.status,
                submitted_at=req.submitted_at.isoformat() if req.submitted_at else "",
                reviewed_by=req.reviewed_by,
                reviewed_at=req.reviewed_at.isoformat() if req.reviewed_at else None,
                review_notes=req.review_notes,
                guardian_name=req.guardian_name,
                guardian_phone=req.guardian_phone,
                date_of_birth=req.date_of_birth,
                address=req.address,
                t_shirt_size=req.t_shirt_size,
                blood_group=req.blood_group,
                invitation_id=req.invitation_id,
                invited_by_coach_id=req.invited_by_coach_id,
                invited_by_coach_name=coach_map.get(req.invited_by_coach_id)
            )
            for req in requests
        ]
    finally:
        db.close()

@app.get("/student-registration-requests/{request_id}", response_model=StudentRegistrationRequest)
def get_student_registration_request(request_id: int):
    """Get a specific registration request"""
    db = SessionLocal()
    try:
        request = db.query(StudentRegistrationRequestDB).filter(
            StudentRegistrationRequestDB.id == request_id
        ).first()
        if not request:
            raise HTTPException(status_code=404, detail="Registration request not found")
        
        return StudentRegistrationRequest(
            id=request.id,
            name=request.name,
            email=request.email,
            phone=request.phone,
            status=request.status,
            submitted_at=request.submitted_at.isoformat() if request.submitted_at else "",
            reviewed_by=request.reviewed_by,
            reviewed_at=request.reviewed_at.isoformat() if request.reviewed_at else None,
            review_notes=request.review_notes,
            guardian_name=request.guardian_name,
            guardian_phone=request.guardian_phone,
            date_of_birth=request.date_of_birth,
            address=request.address,
            t_shirt_size=request.t_shirt_size
        )
    finally:
        db.close()

@app.put("/student-registration-requests/{request_id}", response_model=StudentRegistrationRequest)
def update_registration_request_status(
    request_id: int,
    update: StudentRegistrationRequestUpdate,
    owner_id: int = Query(..., description="Owner ID reviewing the request")
):
    """Approve or reject a student registration request"""
    db = SessionLocal()
    try:
        request = db.query(StudentRegistrationRequestDB).filter(
            StudentRegistrationRequestDB.id == request_id
        ).first()
        
        if not request:
            raise HTTPException(status_code=404, detail="Registration request not found")
        
        if request.status != "pending":
            raise HTTPException(status_code=400, detail="Request has already been reviewed")
        
        # Update request status
        request.status = update.status
        request.reviewed_by = owner_id
        request.reviewed_at = datetime.now()
        request.review_notes = update.review_notes
        
        # If approved, create the student account
        if update.status == "approved":
            # Check if student already exists (race condition check)
            existing_student = db.query(StudentDB).filter(
                StudentDB.email == request.email
            ).first()
            
            if existing_student:
                raise HTTPException(status_code=400, detail="Student with this email already exists")
            
            # Create student account
            db_student = StudentDB(
                name=request.name,
                email=request.email,
                phone=request.phone,
                password=request.password,  # Already hashed
                guardian_name=request.guardian_name,
                guardian_phone=request.guardian_phone,
                date_of_birth=request.date_of_birth,
                address=request.address,
                t_shirt_size=request.t_shirt_size,
                added_by="self",
                status="active"  # Active after approval
            )
            db.add(db_student)
        
        db.commit()
        db.refresh(request)
        
        # Convert to response model
        return StudentRegistrationRequest(
            id=request.id,
            name=request.name,
            email=request.email,
            phone=request.phone,
            status=request.status,
            submitted_at=request.submitted_at.isoformat() if request.submitted_at else "",
            reviewed_by=request.reviewed_by,
            reviewed_at=request.reviewed_at.isoformat() if request.reviewed_at else None,
            review_notes=request.review_notes,
            guardian_name=request.guardian_name,
            guardian_phone=request.guardian_phone,
            date_of_birth=request.date_of_birth,
            address=request.address,
            t_shirt_size=request.t_shirt_size
        )
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating registration request: {str(e)}")
    finally:
        db.close()

@app.get("/students/check-registration-status/{email}")
def check_registration_status(email: str):
    """Check if a registration request exists for an email"""
    db = SessionLocal()
    try:
        request = db.query(StudentRegistrationRequestDB).filter(
            StudentRegistrationRequestDB.email == email
        ).order_by(StudentRegistrationRequestDB.submitted_at.desc()).first()
        
        if not request:
            return {"exists": False}
        
        return {
            "exists": True,
            "status": request.status,
            "submitted_at": request.submitted_at.isoformat() if request.submitted_at else None,
            "reviewed_at": request.reviewed_at.isoformat() if request.reviewed_at else None,
            "review_notes": request.review_notes
        }
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
    
    # Start schema registry watcher automatically
    try:
        from schema_watcher import start_schema_watcher
        start_schema_watcher()
    except ImportError:
        # Schema watcher not available - continue without it
        pass
    except Exception as e:
        # Don't crash if watcher fails
        print(f"[Schema Watcher] Could not start: {e}")
    
    print("🚀 Starting Badminton Academy Management System API...")
    print("📖 API Documentation (Local): http://127.0.0.1:8000/docs")
    print("📖 API Documentation (Network): http://192.168.1.7:8000/docs")
    print("📊 Alternative Docs: http://127.0.0.1:8000/redoc")
    print("📱 Mobile devices can connect to: http://192.168.1.7:8000")
    # host="0.0.0.0" allows connections from any device on the network
    uvicorn.run(app, host="0.0.0.0", port=8000)
