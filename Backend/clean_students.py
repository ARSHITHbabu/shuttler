"""
Script to clean/delete all students from the database
WARNING: This will permanently delete all student records!
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

def clean_students(confirm=False):
    """Delete all students from the database"""
    db = SessionLocal()
    try:
        # First, get count of students
        result = db.execute(text("SELECT COUNT(*) FROM students"))
        count = result.scalar()
        
        print(f"\nWARNING: This will delete {count} student(s) from the database!")
        
        if not confirm:
            confirmation = input("Type 'YES' to confirm deletion: ")
            if confirmation != 'YES':
                print("Deletion cancelled.")
                return
        else:
            print("Auto-confirmed deletion (confirm=True)")
        
        # Delete all students
        # Note: Related records in batch_students will be handled by CASCADE if foreign key is set up
        # Otherwise, we need to delete them first
        
        # Check if batch_students table exists and has foreign key constraints
        try:
            # Delete from batch_students first (if foreign key doesn't cascade)
            db.execute(text("DELETE FROM batch_students"))
            print("Deleted batch_student relationships")
        except Exception as e:
            print(f"Note: Could not delete batch_students (may not exist or already cascaded): {e}")
        
        # Delete all students
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
    import sys
    print("=" * 60)
    print("STUDENT DATABASE CLEANER")
    print("=" * 60)
    
    # Allow --yes flag to skip confirmation
    auto_confirm = '--yes' in sys.argv or '-y' in sys.argv
    clean_students(confirm=auto_confirm)
    print("=" * 60)
