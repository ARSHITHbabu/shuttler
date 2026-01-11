-- Migration script to add missing columns to existing database tables
-- Run this script in pgAdmin or psql if automatic migration fails
-- Connect to your database first: \c badminton_academy

-- Add missing columns to coaches table
DO $$
BEGIN
    -- Add role column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'coaches' AND column_name = 'role'
    ) THEN
        ALTER TABLE coaches ADD COLUMN role VARCHAR DEFAULT 'coach';
        RAISE NOTICE 'Added role column to coaches table';
    END IF;

    -- Add profile_photo column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'coaches' AND column_name = 'profile_photo'
    ) THEN
        ALTER TABLE coaches ADD COLUMN profile_photo VARCHAR(500);
        RAISE NOTICE 'Added profile_photo column to coaches table';
    END IF;

    -- Add fcm_token column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'coaches' AND column_name = 'fcm_token'
    ) THEN
        ALTER TABLE coaches ADD COLUMN fcm_token VARCHAR(500);
        RAISE NOTICE 'Added fcm_token column to coaches table';
    END IF;
END $$;

-- Add missing columns to students table
DO $$
BEGIN
    -- Add profile_photo column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' AND column_name = 'profile_photo'
    ) THEN
        ALTER TABLE students ADD COLUMN profile_photo VARCHAR(500);
        RAISE NOTICE 'Added profile_photo column to students table';
    END IF;

    -- Add fcm_token column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' AND column_name = 'fcm_token'
    ) THEN
        ALTER TABLE students ADD COLUMN fcm_token VARCHAR(500);
        RAISE NOTICE 'Added fcm_token column to students table';
    END IF;
END $$;

-- Verify the changes
SELECT 
    table_name, 
    column_name, 
    data_type, 
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name IN ('coaches', 'students')
    AND column_name IN ('role', 'profile_photo', 'fcm_token')
ORDER BY table_name, column_name;
