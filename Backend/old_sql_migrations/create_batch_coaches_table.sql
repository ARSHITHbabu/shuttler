-- Migration script to create batch_coaches junction table for multiple coach assignments
-- This allows a batch to have multiple coaches assigned

-- Create junction table
CREATE TABLE IF NOT EXISTS batch_coaches (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    coach_id INTEGER NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(batch_id, coach_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_batch_coaches_batch_id ON batch_coaches(batch_id);
CREATE INDEX IF NOT EXISTS idx_batch_coaches_coach_id ON batch_coaches(coach_id);

-- Migrate existing data from assigned_coach_id to batch_coaches table
-- This preserves existing single-coach assignments
INSERT INTO batch_coaches (batch_id, coach_id)
SELECT id, assigned_coach_id 
FROM batches 
WHERE assigned_coach_id IS NOT NULL
ON CONFLICT (batch_id, coach_id) DO NOTHING;

-- Note: We keep assigned_coach_id column for backward compatibility
-- It can be removed in a future migration after all clients are updated
