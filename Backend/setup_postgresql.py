#!/usr/bin/env python3
"""
PostgreSQL Setup Verification Script
This script helps verify your PostgreSQL configuration before starting the backend.
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv

def check_env_file():
    """Check if .env file exists and has DATABASE_URL"""
    env_path = Path(__file__).parent / ".env"
    
    if not env_path.exists():
        print("ERROR: .env file not found!")
        print(f"   Please create .env file in: {env_path.parent}")
        return False
    
    load_dotenv(env_path)
    database_url = os.getenv("DATABASE_URL")
    
    if not database_url:
        print("ERROR: DATABASE_URL not found in .env file!")
        print("   Please add: DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/badminton_academy")
        return False
    
    if "your_password" in database_url or "YOUR_PASSWORD" in database_url:
        print("WARNING: DATABASE_URL still contains placeholder password!")
        print("   Please replace 'your_password' with your actual PostgreSQL password")
        return False
    
    print(f"OK: .env file found with DATABASE_URL")
    return (True, database_url)

def test_postgresql_connection(database_url):
    """Test PostgreSQL connection"""
    try:
        import psycopg2
        from urllib.parse import urlparse
        
        # Parse the database URL
        parsed = urlparse(database_url)
        
        print(f"\nTesting PostgreSQL connection...")
        print(f"   Host: {parsed.hostname}")
        print(f"   Port: {parsed.port}")
        print(f"   Database: {parsed.path[1:]}")
        print(f"   User: {parsed.username}")
        
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            host=parsed.hostname,
            port=parsed.port,
            database=parsed.path[1:],  # Remove leading /
            user=parsed.username,
            password=parsed.password
        )
        
        # Check if database exists
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print(f"OK: PostgreSQL connection successful!")
        print(f"   Version: {version.split(',')[0]}")
        
        # Check if badminton_academy database exists
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = 'badminton_academy'")
        if cursor.fetchone():
            print(f"OK: Database 'badminton_academy' exists")
        else:
            print(f"WARNING: Database 'badminton_academy' does not exist")
            print(f"   Run this SQL command in pgAdmin or psql:")
            print(f"   CREATE DATABASE badminton_academy;")
        
        cursor.close()
        conn.close()
        return True
        
    except ImportError:
        print("ERROR: psycopg2 not installed!")
        print("   Run: pip install psycopg2-binary")
        return False
    except psycopg2.OperationalError as e:
        print(f"ERROR: PostgreSQL connection failed!")
        print(f"   Error: {e}")
        print(f"\n   Troubleshooting:")
        print(f"   1. Make sure PostgreSQL service is running")
        print(f"   2. Check your password in .env file")
        print(f"   3. Verify database name is 'badminton_academy'")
        print(f"   4. Check if PostgreSQL is on port 5432")
        return False
    except Exception as e:
        print(f"ERROR: Unexpected error: {e}")
        return False

def main():
    print("=" * 60)
    print("PostgreSQL Setup Verification")
    print("=" * 60)
    
    # Check .env file
    result = check_env_file()
    if not result:
        print("\nERROR: Setup incomplete. Please fix the issues above.")
        sys.exit(1)
    
    if isinstance(result, tuple):
        _, database_url = result
    else:
        load_dotenv()
        database_url = os.getenv("DATABASE_URL")
    
    # Test connection
    if test_postgresql_connection(database_url):
        print("\n" + "=" * 60)
        print("SUCCESS: All checks passed! You're ready to run the backend.")
        print("=" * 60)
        print("\nNext step: Run 'python main.py' to start the server")
    else:
        print("\n" + "=" * 60)
        print("ERROR: Setup incomplete. Please fix the issues above.")
        print("=" * 60)
        sys.exit(1)

if __name__ == "__main__":
    main()
