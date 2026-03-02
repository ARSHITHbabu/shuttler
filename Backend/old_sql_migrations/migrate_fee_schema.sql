-- Migration script to add payee_student_id column to fees table
-- Run this script in pgAdmin or psql if automatic migration fails
-- Connect to your database first: \c badminton_academy

-- Add payee_student_id column to fees table
DO $$
BEGIN
    -- Add payee_student_id column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'fees' AND column_name = 'payee_student_id'
    ) THEN
        ALTER TABLE fees ADD COLUMN payee_student_id INTEGER;
        RAISE NOTICE 'Added payee_student_id column to fees table';
    ELSE
        RAISE NOTICE 'Column payee_student_id already exists in fees table';
    END IF;
END $$;

-- Add foreign key constraint if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'fees' 
        AND constraint_name = 'fees_payee_student_id_fkey'
    ) THEN
        ALTER TABLE fees 
        ADD CONSTRAINT fees_payee_student_id_fkey 
        FOREIGN KEY (payee_student_id) 
        REFERENCES students(id);
        RAISE NOTICE 'Added foreign key constraint for fees.payee_student_id';
    ELSE
        RAISE NOTICE 'Foreign key constraint fees_payee_student_id_fkey already exists';
    END IF;
END $$;

-- Verify fee_payments table exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'fee_payments'
    ) THEN
        RAISE NOTICE 'WARNING: fee_payments table does not exist!';
        RAISE NOTICE 'This table should be created automatically by the application.';
        RAISE NOTICE 'Please ensure FeePaymentDB model is properly defined and run Base.metadata.create_all()';
    ELSE
        RAISE NOTICE 'fee_payments table exists';
    END IF;
END $$;

-- Verify the changes
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'fees'
    AND column_name = 'payee_student_id'
ORDER BY table_name, column_name;

-- Show foreign key constraints
SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    tc.constraint_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name = 'fees'
  AND kcu.column_name = 'payee_student_id';
