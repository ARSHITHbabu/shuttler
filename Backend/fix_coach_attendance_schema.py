"""
Migration script to add missing columns to coach_attendance table
"""
import os
from sqlalchemy import create_engine, text, inspect
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get database URL
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found in .env file!")
    exit(1)

print(f"Connecting to database...")
engine = create_engine(DATABASE_URL)

try:
    with engine.begin() as conn:
        # Check if columns exist
        inspector = inspect(engine)
        columns = [col['name'] for col in inspector.get_columns('coach_attendance')]
        
        print(f"Current coach_attendance columns: {columns}")
        
        # Add marked_by column if it doesn't exist
        if 'marked_by' not in columns:
            print("Adding 'marked_by' column...")
            conn.execute(text("""
                ALTER TABLE coach_attendance 
                ADD COLUMN marked_by VARCHAR(255)
            """))
            print("✓ Added 'marked_by' column")
        else:
            print("✓ 'marked_by' column already exists")
        
        # Add remarks column if it doesn't exist
        if 'remarks' not in columns:
            print("Adding 'remarks' column...")
            conn.execute(text("""
                ALTER TABLE coach_attendance 
                ADD COLUMN remarks TEXT
            """))
            print("✓ Added 'remarks' column")
        else:
            print("✓ 'remarks' column already exists")
        
        print("\n✅ Migration completed successfully!")
        
except Exception as e:
    print(f"\n❌ Migration failed: {e}")
    exit(1)
