# Data Retention Policy

## Scope and Purpose

This policy governs the retention, archiving, and deletion of user and operational data within the Shuttler platform. It ensures compliance with data protection laws (such as PIPEDA and GDPR) by preventing data from being stored indefinitely while preserving necessary records for auditing and operational continuity.

## 1. Retention Periods

- **Active Accounts**: Data belonging to active academies, owners, coaches, and students is retained indefinitely as long as the account status remains active.
- **Inactive Accounts**: When a student or coach is marked as "inactive" (e.g. they unenroll or leave the academy), their core data and relational history (attendance, payments) are hard-retained in the operational database for a period of **2 years** (730 days) from the `inactive_at` timestamp.
- **Batches**: Finished or discontinued batches marked as "inactive" are also retained directly in the database for 2 years.

## 2. The Archiving Process

To comply with minimizing long-term PII (Personally Identifiable Information) exposure while still keeping vital anonymized historical context or recovery options:
- Shuttler implements a daily scheduled background job (`cleanup_inactive_records`).
- Once a record has crossed the 2-year inactivity limit, the job initiates the Archiving Phase.
- **Archival Before Deletion**: The raw JSON payload of the entity (e.g. Student, Batch) is copied to a centralized `archive_records` table (`ArchiveRecordDB`), where it is stripped of sensitive relations. 
- **Hard Deletion**: Immediately following the archive insertion, the relational graph corresponding to the entity is permanently purged. For a student, this includes their attendance records, individual fee payments, physical performance assessments, BMI logs, and video analytics references.

The archived records table (`archive_records`) is kept for an additional 5 years to meet financial auditing laws, after which it too can be systematically purged.

## 3. Immediate Account Deletion

Users inherently hold the "Right to Erasure." If a user specifically initiates an Account Deletion (via the in-app settings), the 2-year retention period is bypassed entirely. All associated data is deleted permanently without traversing into the `archive_records` table (unless specifically required under financial/taxation laws where anonymized fee transactions must be retained).

## 4. Enforcement

- **Database Backups**: Note that Point-In-Time-Recovery (PITR) and daily snapshot backups (documented in `DATABASE_BACKUPS.md`) also inherently hold snapshots of deleted data for an extra 30 days before that data rotates out of existence completely from all systems.
- **Admin Control**: The `/admin/trigger-cleanup` endpoint enables super-admins to run the 2-year inactivity sweep manually via a POST request at any time.
