"""
Script to clear all data from the database while keeping the structure intact.
This will delete all records from all tables but preserve the table structure.
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text, inspect
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
    is_postgresql = False
else:
    print("Connecting to PostgreSQL database...")
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL,
        pool_size=5,
        max_overflow=10,
        pool_pre_ping=True,
        echo=False
    )
    is_postgresql = True
    print("PostgreSQL connection established!")

# Get all table names
inspector = inspect(engine)
table_names = inspector.get_table_names()

print(f"\nFound {len(table_names)} tables in the database:")
for table in table_names:
    print(f"   - {table}")

# Tables in order (child tables first to respect foreign key constraints)
# This order ensures we delete child records before parent records
tables_order = [
    # Child tables first (those with foreign keys)
    "notifications",
    "calendar_events",
    "announcements",
    "invitations",
    "video_resources",
    "tournaments",
    "schedules",
    "enquiries",
    "bmi",
    "performance",
    "fee_payments",
    "fees",
    "coach_attendance",
    "attendance",
    "batch_students",
    # Parent tables
    "students",
    "batches",
    "coaches",
]

# Filter to only include tables that exist
tables_to_clear = [t for t in tables_order if t in table_names]

# Add any remaining tables that weren't in our list
remaining_tables = [t for t in table_names if t not in tables_to_clear]
if remaining_tables:
    print(f"\nFound additional tables not in predefined list: {remaining_tables}")
    tables_to_clear.extend(remaining_tables)

print(f"\nClearing data from {len(tables_to_clear)} tables...")

# Create a session
SessionLocal = sessionmaker(bind=engine)
session = SessionLocal()

try:
    # Disable foreign key checks temporarily (for SQLite)
    if not is_postgresql:
        session.execute(text("PRAGMA foreign_keys = OFF"))
    
    # Delete data from each table
    deleted_counts = {}
    for table_name in tables_to_clear:
        try:
            # Count records before deletion
            result = session.execute(text(f"SELECT COUNT(*) FROM {table_name}"))
            count_before = result.scalar()
            
            # Delete all records
            session.execute(text(f"DELETE FROM {table_name}"))
            
            deleted_counts[table_name] = count_before
            print(f"   [OK] Cleared {count_before} records from '{table_name}'")
        except Exception as e:
            print(f"   [WARNING] Error clearing '{table_name}': {e}")
            deleted_counts[table_name] = 0
    
    # Re-enable foreign key checks (for SQLite)
    if not is_postgresql:
        session.execute(text("PRAGMA foreign_keys = ON"))
    
    # Reset sequences for PostgreSQL (auto-increment counters)
    if is_postgresql:
        print("\nResetting auto-increment sequences...")
        for table_name in tables_to_clear:
            try:
                # Reset the sequence for the id column
                session.execute(text(f"SELECT setval(pg_get_serial_sequence('{table_name}', 'id'), 1, false)"))
                print(f"   [OK] Reset sequence for '{table_name}'")
            except Exception as e:
                # Some tables might not have a serial id column, that's okay
                pass
    
    # Commit all changes
    session.commit()
    
    print("\n" + "="*60)
    print("DATABASE CLEARED SUCCESSFULLY!")
    print("="*60)
    print(f"\nSummary:")
    total_deleted = sum(deleted_counts.values())
    print(f"   Total records deleted: {total_deleted}")
    print(f"   Tables cleared: {len([t for t in deleted_counts if deleted_counts[t] > 0])}")
    print(f"\nThe database structure is intact. You can now add fresh data.")
    
except Exception as e:
    session.rollback()
    print(f"\nERROR: Failed to clear database: {e}")
    raise
finally:
    session.close()
    engine.dispose()

print("\nDone!")
