-- Migration script to add Session/Season structure
-- Run this script to add sessions table and session_id to batches

-- Create sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    start_date VARCHAR(50) NOT NULL,
    end_date VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Add session_id column to batches table (nullable, can be added later)
ALTER TABLE batches 
ADD COLUMN IF NOT EXISTS session_id INTEGER REFERENCES sessions(id) ON DELETE SET NULL;

-- Create index on session_id for better query performance
CREATE INDEX IF NOT EXISTS idx_batches_session_id ON batches(session_id);

-- Add comment to sessions table
COMMENT ON TABLE sessions IS 'Sessions/Seasons that group multiple batches together (e.g., Fall 2026, Winter 2026)';
