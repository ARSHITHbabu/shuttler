-- Migration script to add session_id column to batches table
-- This column links batches to sessions/seasons

-- Add session_id column if it doesn't exist
ALTER TABLE batches 
ADD COLUMN IF NOT EXISTS session_id INTEGER;

-- Add foreign key constraint if it doesn't exist
-- Note: This will only work if the sessions table exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'batches_session_id_fkey'
    ) THEN
        ALTER TABLE batches 
        ADD CONSTRAINT batches_session_id_fkey 
        FOREIGN KEY (session_id) REFERENCES sessions(id);
    END IF;
END $$;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_batches_session_id ON batches(session_id);
