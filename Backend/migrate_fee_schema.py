#!/usr/bin/env python3
"""
Database Migration Script for Fee Management Schema Updates
This script adds the payee_student_id column to the fees table and ensures
the fee_payments table exists.

Run this script if you encounter the error:
    psycopg2.errors.UndefinedColumn: column fees.payee_student_id does not exist
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.exc import ProgrammingError

# Load environment variables
load_dotenv()

def check_and_add_column(engine, table_name: str, column_name: str, column_type: str, nullable: bool = True):
    """Check if a column exists in a table, and add it if missing"""
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
                    conn.execute(text(alter_sql))
                print(f"✅ Added column '{column_name}' to '{table_name}' table")
                return True
            except Exception as e:
                print(f"❌ Error adding column '{column_name}': {e}")
                return False
        else:
            print(f"✅ Column '{column_name}' already exists in '{table_name}' table")
            return False
    except Exception as e:
        print(f"⚠️  Could not check columns for '{table_name}': {e}")
        return False

def add_foreign_key_constraint(engine, table_name: str, column_name: str, referenced_table: str, referenced_column: str = 'id'):
    """Add foreign key constraint if it doesn't exist"""
    try:
        with engine.begin() as conn:
            # Check if foreign key constraint exists
            constraint_name = f"{table_name}_{column_name}_fkey"
            fk_check = text(f"""
                SELECT COUNT(*) 
                FROM information_schema.table_constraints 
                WHERE table_name = '{table_name}' 
                AND constraint_name = '{constraint_name}'
            """)
            result = conn.execute(fk_check).scalar()
            if result == 0:
                # Add foreign key constraint
                fk_sql = text(f"""
                    ALTER TABLE {table_name} 
                    ADD CONSTRAINT {constraint_name} 
                    FOREIGN KEY ({column_name}) 
                    REFERENCES {referenced_table}({referenced_column})
                """)
                conn.execute(fk_sql)
                print(f"✅ Added foreign key constraint '{constraint_name}'")
                return True
            else:
                print(f"✅ Foreign key constraint '{constraint_name}' already exists")
                return False
    except Exception as e:
        print(f"⚠️  Note: Foreign key constraint check: {e}")
        return False

def verify_fee_payments_table(engine):
    """Verify that fee_payments table exists and has correct structure"""
    try:
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        
        if 'fee_payments' not in tables:
            print("⚠️  fee_payments table not found!")
            print("⚠️  This table should be created automatically by Base.metadata.create_all()")
            print("⚠️  Please ensure FeePaymentDB model is properly defined in main.py")
            return False
        else:
            print("✅ fee_payments table exists")
            # Check required columns
            columns = [col['name'] for col in inspector.get_columns('fee_payments')]
            required_columns = ['id', 'fee_id', 'amount', 'paid_date']
            missing_columns = [col for col in required_columns if col not in columns]
            if missing_columns:
                print(f"⚠️  Missing columns in fee_payments table: {missing_columns}")
                return False
            else:
                print("✅ fee_payments table has all required columns")
                return True
    except Exception as e:
        print(f"⚠️  Error verifying fee_payments table: {e}")
        return False

def main():
    print("=" * 60)
    print("Fee Management Schema Migration")
    print("=" * 60)
    
    # Get database URL
    database_url = os.getenv("DATABASE_URL")
    
    if not database_url:
        print("❌ ERROR: DATABASE_URL not found in .env file!")
        print("   Please add: DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/badminton_academy")
        sys.exit(1)
    
    if "your_password" in database_url or "YOUR_PASSWORD" in database_url:
        print("❌ ERROR: DATABASE_URL still contains placeholder password!")
        print("   Please replace 'your_password' with your actual PostgreSQL password")
        sys.exit(1)
    
    try:
        # Create engine
        print(f"\n📡 Connecting to database...")
        engine = create_engine(database_url, echo=False)
        
        # Test connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        print("✅ Database connection successful!")
        
        # Check if fees table exists
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        
        if 'fees' not in tables:
            print("❌ ERROR: 'fees' table does not exist!")
            print("   Please ensure the fees table has been created first.")
            print("   Run 'python main.py' to create all tables.")
            sys.exit(1)
        
        print("\n📋 Starting migration...")
        
        # Add payee_student_id column to fees table
        print("\n1. Checking fees table...")
        column_added = check_and_add_column(
            engine, 
            'fees', 
            'payee_student_id', 
            'INTEGER', 
            nullable=True
        )
        
        # Add foreign key constraint if column was just added or if it doesn't exist
        if column_added or True:  # Always check for FK constraint
            print("\n2. Checking foreign key constraint...")
            add_foreign_key_constraint(
                engine,
                'fees',
                'payee_student_id',
                'students',
                'id'
            )
        
        # Verify fee_payments table
        print("\n3. Verifying fee_payments table...")
        verify_fee_payments_table(engine)
        
        print("\n" + "=" * 60)
        print("✅ Migration completed successfully!")
        print("=" * 60)
        print("\nNext steps:")
        print("1. Restart your backend server (python main.py)")
        print("2. Test the /fees/ endpoint to verify it works")
        
    except ProgrammingError as e:
        print(f"\n❌ Database error: {e}")
        print("\nTroubleshooting:")
        print("1. Ensure PostgreSQL service is running")
        print("2. Check your DATABASE_URL in .env file")
        print("3. Verify you have permissions to alter the database")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
