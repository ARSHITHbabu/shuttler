#!/usr/bin/env python3
"""
Database Migration Script for Session/Season Schema
This script adds the sessions table and session_id column to batches table.

Run this script to add session/season support to the database.
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.exc import ProgrammingError

# Load environment variables
load_dotenv()

def check_and_create_table(engine, table_name: str, create_sql: str):
    """Check if a table exists, and create it if missing"""
    try:
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        
        if table_name not in tables:
            print(f"⚠️  Table '{table_name}' missing. Creating...")
            try:
                with engine.begin() as conn:
                    conn.execute(text(create_sql))
                print(f"✅ Created table '{table_name}'")
                return True
            except Exception as e:
                print(f"❌ Error creating table '{table_name}': {e}")
                return False
        else:
            print(f"✅ Table '{table_name}' already exists")
            return False
    except Exception as e:
        print(f"⚠️  Could not check tables: {e}")
        return False

def check_and_add_column(engine, table_name: str, column_name: str, column_type: str, nullable: bool = True, foreign_key: str = None):
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
                    if foreign_key:
                        alter_sql += f" {foreign_key}"
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

def create_index(engine, index_name: str, table_name: str, column_name: str):
    """Create an index if it doesn't exist"""
    try:
        with engine.begin() as conn:
            # Check if index exists
            check_sql = f"""
                SELECT EXISTS (
                    SELECT 1 FROM pg_indexes 
                    WHERE indexname = '{index_name}'
                );
            """
            result = conn.execute(text(check_sql)).scalar()
            
            if not result:
                print(f"⚠️  Index '{index_name}' missing. Creating...")
                create_index_sql = f"CREATE INDEX {index_name} ON {table_name}({column_name})"
                conn.execute(text(create_index_sql))
                print(f"✅ Created index '{index_name}'")
                return True
            else:
                print(f"✅ Index '{index_name}' already exists")
                return False
    except Exception as e:
        print(f"⚠️  Could not create index '{index_name}': {e}")
        return False

def main():
    """Main migration function"""
    # Get database URL from environment or use default
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        # Try to construct from individual components
        db_user = os.getenv("DB_USER", "postgres")
        db_password = os.getenv("DB_PASSWORD", "postgres")
        db_host = os.getenv("DB_HOST", "localhost")
        db_port = os.getenv("DB_PORT", "5432")
        db_name = os.getenv("DB_NAME", "badminton_academy")
        database_url = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    
    print("🔄 Starting Session/Season Schema Migration...")
    print(f"📊 Database: {database_url.split('@')[1] if '@' in database_url else 'unknown'}")
    
    try:
        engine = create_engine(database_url)
        
        # Create sessions table
        sessions_table_sql = """
        CREATE TABLE IF NOT EXISTS sessions (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            start_date VARCHAR(50) NOT NULL,
            end_date VARCHAR(50) NOT NULL,
            status VARCHAR(20) DEFAULT 'active',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE
        );
        """
        check_and_create_table(engine, "sessions", sessions_table_sql)
        
        # Add session_id column to batches table
        check_and_add_column(
            engine,
            "batches",
            "session_id",
            "INTEGER",
            nullable=True,
            foreign_key="REFERENCES sessions(id) ON DELETE SET NULL"
        )
        
        # Create index on session_id
        create_index(engine, "idx_batches_session_id", "batches", "session_id")
        
        print("\n✅ Session/Season Schema Migration Completed Successfully!")
        print("\n📝 Next Steps:")
        print("   1. Restart your backend server")
        print("   2. Sessions can now be created and batches can be assigned to sessions")
        print("   3. Use the Session/Season Management screen in the owner portal")
        
    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
