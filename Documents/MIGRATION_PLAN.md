# Data Migration Plan: Local → Cloud

This document outlines the step-by-step procedure for migrating Shuttler data from local environments to the production cloud infrastructure.

## 1. Database Migration (PostgreSQL)

### Phase 1: Preparation
1. **Maintenance Window**: Announce a maintenance window where the app will be in read-only mode.
2. **Schema Alignment**: Ensure the local database schema is fully up-to-date with Alembic migrations:
   ```bash
   alembic upgrade head
   ```
3. **Cloud Connectivity**: Verify the local machine can connect to the Cloud DB (AWS RDS / Supabase / Railway) via URI.

### Phase 2: Execution
1. **Take a Dump**: Create a compressed SQL dump of the local database:
   ```bash
   pg_dump -h localhost -U shuttler -d shuttler -F c -b -v -f shuttler_migration.dump
   ```
2. **Restore to Cloud**: Use `pg_restore` to push the data to the cloud instance:
   ```bash
   pg_restore -h <cloud_host> -U <cloud_user> -d <cloud_db_name> -v shuttler_migration.dump
   ```

### Phase 3: Verification
1. Run row count checks on critical tables: `owners`, `coaches`, `students`, `fee_payments`.
2. check data integrity for encrypted fields (FE encryption should remain intact if the key is the same).

## 2. File Storage Migration (Local Disk → S3/R2)

Existing files stored in the local `uploads/` directory must be synchronized with the S3 bucket.

### Phase 1: Preparation
1. Configure AWS CLI with appropriate credentials.
2. Identify the target bucket name and region.

### Phase 2: Sync Execution
1. Use the AWS CLI `sync` command to mirror the local directory to the bucket:
   ```bash
   aws s3 sync ./Backend/uploads/ s3://<your-bucket-name>/uploads/ --acl public-read
   ```

## 3. Dry-Run & Staging Test
1. Replicate the migration process using the **Staging** environment before attempting Production.
2. Verify all API endpoints function correctly with the cloud database and S3 links.

## 4. Rollback Strategy
If the migration fails or data corruption is detected:
1. **Database**: Re-point the API service back to the local/previous stable DB instance.
2. **Files**: Keep the local `uploads/` directory intact until the migration is confirmed successful for 7 days.
3. **DNS**: If a URL change was made, revert the CNAME/A records.
