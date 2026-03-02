"""Quick fix for coach_attendance table"""
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

# Parse DATABASE_URL
db_url = os.getenv("DATABASE_URL")
if not db_url:
    print("ERROR: DATABASE_URL not found")
    exit(1)

# Extract connection params from URL
# Format: postgresql://user:password@host:port/database
parts = db_url.replace("postgresql://", "").split("@")
user_pass = parts[0].split(":")
host_db = parts[1].split("/")
host_port = host_db[0].split(":")

conn_params = {
    "user": user_pass[0],
    "password": user_pass[1],
    "host": host_port[0],
    "port": host_port[1] if len(host_port) > 1 else "5432",
    "database": host_db[1]
}

print(f"Connecting to {conn_params['database']}...")

try:
    conn = psycopg2.connect(**conn_params)
    cur = conn.cursor()
    
    # Add marked_by column
    print("Adding marked_by column...")
    cur.execute("""
        ALTER TABLE coach_attendance 
        ADD COLUMN IF NOT EXISTS marked_by VARCHAR(255)
    """)
    
    # Add remarks column
    print("Adding remarks column...")
    cur.execute("""
        ALTER TABLE coach_attendance 
        ADD COLUMN IF NOT EXISTS remarks TEXT
    """)
    
    conn.commit()
    print("✅ Migration completed successfully!")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
    exit(1)
