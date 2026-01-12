# Fee Management Schema Migration Guide

## Problem

The application is failing with the error:
```
psycopg2.errors.UndefinedColumn: column fees.payee_student_id does not exist
```

This occurs because the database schema is missing the `payee_student_id` column in the `fees` table, which was added to support the enhanced fee management features.

## Solution

We have three ways to run the migration:

### Option 1: Automatic Migration (Recommended)

The migration will run automatically when you start the backend server. The `migrate_database_schema()` function in `main.py` has been updated to include fee-related migrations.

**Steps:**
1. Ensure your backend server is stopped
2. Start the backend: `python main.py`
3. The migration will run automatically and you should see:
   ```
   ⚠️  Column 'payee_student_id' missing in 'fees' table. Adding...
   ✅ Added column 'payee_student_id' to 'fees' table
   ✅ Added foreign key constraint for fees.payee_student_id
   ✅ fee_payments table exists
   ✅ Database schema migration completed!
   ```

### Option 2: Python Migration Script

Run the standalone Python migration script:

```bash
cd Backend
python migrate_fee_schema.py
```

This script will:
- Connect to your database using `DATABASE_URL` from `.env`
- Check if `payee_student_id` column exists
- Add it if missing
- Add foreign key constraint
- Verify `fee_payments` table exists

### Option 3: SQL Script (Manual)

If you prefer to run SQL directly:

1. Open pgAdmin or connect via `psql`
2. Connect to your `badminton_academy` database
3. Run the SQL script:
   ```bash
   psql -U postgres -d badminton_academy -f migrate_fee_schema.sql
   ```
   
   Or copy-paste the contents of `migrate_fee_schema.sql` into pgAdmin query window

## What Gets Migrated

1. **fees table**: Adds `payee_student_id` column (INTEGER, nullable)
2. **Foreign key constraint**: Links `fees.payee_student_id` → `students.id`
3. **fee_payments table**: Verified to exist (created automatically by SQLAlchemy)

## Verification

After running the migration, verify it worked:

1. **Check the column exists:**
   ```sql
   SELECT column_name, data_type, is_nullable 
   FROM information_schema.columns 
   WHERE table_name = 'fees' AND column_name = 'payee_student_id';
   ```

2. **Check foreign key constraint:**
   ```sql
   SELECT constraint_name, table_name, column_name
   FROM information_schema.key_column_usage
   WHERE table_name = 'fees' AND column_name = 'payee_student_id';
   ```

3. **Test the API:**
   - Restart your backend server
   - Try accessing `/fees/` endpoint
   - Should return 200 OK instead of 500 Internal Server Error

## Troubleshooting

### Error: "relation fees does not exist"
- The `fees` table hasn't been created yet
- Run `python main.py` first to create all tables via `Base.metadata.create_all()`

### Error: "permission denied"
- Ensure your database user has ALTER TABLE permissions
- You may need to run as a superuser or grant permissions:
  ```sql
  GRANT ALL PRIVILEGES ON TABLE fees TO your_user;
  ```

### Error: "column already exists"
- The column is already there, migration was successful
- This is not an error, just informational

### Error: "fee_payments table does not exist"
- This table should be created automatically by SQLAlchemy
- Ensure `FeePaymentDB` model is properly defined in `main.py`
- Run `Base.metadata.create_all(bind=engine)` to create it

## Files Created

- `Backend/migrate_fee_schema.py` - Python migration script
- `Backend/migrate_fee_schema.sql` - SQL migration script
- `Backend/main.py` - Updated with automatic migration logic

## Next Steps

After successful migration:
1. ✅ Restart backend server
2. ✅ Test `/fees/` endpoint
3. ✅ Verify fee creation works
4. ✅ Test payment recording functionality
