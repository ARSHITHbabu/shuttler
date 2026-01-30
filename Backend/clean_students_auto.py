"""
Script to automatically clean/delete all students from the database
WARNING: This will permanently delete all student records without confirmation!
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Load environment variables
load_dotenv()

# Database setup - PostgreSQL with fallback to SQLite
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

if not SQLALCHEMY_DATABASE_URL:
    print("WARNING: DATABASE_URL not found in .env file!")
    print("Falling back to SQLite")
    SQLALCHEMY_DATABASE_URL = "sqlite:///./academy_portal.db"
    engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
else:
    print("Connecting to PostgreSQL database...")
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL,
        pool_size=20,
        max_overflow=40,
        pool_pre_ping=True,
        pool_recycle=3600,
        echo=False
    )
    print("PostgreSQL connection established!")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def clean_students():
    """Delete all students from the database"""
    db = SessionLocal()
    try:
        # First, get count of students
        result = db.execute(text("SELECT COUNT(*) FROM students"))
        count = result.scalar()
        
        print(f"\nDeleting {count} student(s) from the database...")
        
        # Delete related records first (in order to avoid foreign key violations)
        # Order matters: delete from child tables first, then parent table
        
        tables_to_clean = [
            "fee_payments",           # References students via payee_student_id
            "fees",                   # References students via student_id
            "performance",            # References students via student_id
            "bmi_records",            # References students via student_id
            "attendance",             # References students via student_id
            "video_resources",        # References students via student_id
            "batch_students",         # References students via student_id
        ]
        
        for table in tables_to_clean:
            try:
                result = db.execute(text(f"DELETE FROM {table}"))
                deleted = result.rowcount
                if deleted > 0:
                    print(f"Deleted {deleted} record(s) from {table}")
            except Exception as e:
                # Table might not exist or already empty
                print(f"Note: Could not delete from {table}: {e}")
        
        # Now delete all students
        db.execute(text("DELETE FROM students"))
        db.commit()
        
        # Verify deletion
        result = db.execute(text("SELECT COUNT(*) FROM students"))
        remaining = result.scalar()
        
        if remaining == 0:
            print(f"\nSuccessfully deleted all {count} student(s)!")
            print("Student table is now empty.")
        else:
            print(f"\nWarning: {remaining} student(s) still remain in the database.")
            
    except Exception as e:
        db.rollback()
        print(f"\nError deleting students: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 60)
    print("STUDENT DATABASE CLEANER (AUTO)")
    print("=" * 60)
    clean_students()
    print("=" * 60)
