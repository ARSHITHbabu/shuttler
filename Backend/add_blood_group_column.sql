-- Add blood_group column to students table
-- Run this SQL command if you need to add the column immediately without restarting the server

ALTER TABLE students ADD COLUMN IF NOT EXISTS blood_group VARCHAR;

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'students' AND column_name = 'blood_group';
