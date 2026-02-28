# Database Backups and Restore Procedures

## Overview

This document outlines the backup, retention, and restore procedures for the Shuttler PostgreSQL database running in a cloud-managed environment (e.g., Railway, Render, AWS RDS). Continuous protection guarantees data integrity against accidental deletions, data corruption, and infrastructure failures.

## 1. Automated Daily Backups

Automated backups are enabled by default for our cloud-managed PostgreSQL instances.
- **Provider Mechanisms:** Railway/Render automatically capture full database snapshots periodically. 
- **Application Redundancy:** A background job running on the server can execute a logical `pg_dump` when manually triggered by the Owner from the `/admin/trigger-backup` endpoint.
- **S3 Uploads:** In future scaling phases, logical `.sql` dumps are securely pushed to an Amazon S3 (or Cloudflare R2) bucket, preserving off-site separation.

## 2. Point-In-Time Recovery (PITR)

- **Cloud PostgreSQL PITR:** Point-In-Time Recovery is enabled out-of-the-box on managed databases. This allows rolling back the database to a precise second within the retention window by replaying Write-Ahead Logs (WAL).
- **Usage:** In the event of catastrophic data corruption (e.g. accidental `DROP TABLE` or massive incorrect `UPDATE` executed manually), use the Railway/Render UI portal to select "Restore to Point-In-Time" and select a timestamp right before the incident.

## 3. Backup Retention

- **Retention Window:** PostgreSQL automated backups are preserved for a **minimum of 30 days**. This is the hard enforcement threshold for our disaster recovery Service Level Agreement (SLA).
- **Cold Storage:** Logical backups exported to Amazon S3 have a lifecycle rule to transition to Glacier storage after 30 days, kept indefinitely for audit compliance.

## 4. Disaster Recovery: Testing and Restoring

### Restore Procedure from automated Snapshots
1. Log into the Database Cloud Dashboard.
2. Navigate to "Backups" for the primary PostgreSQL cluster.
3. Select the latest healthy snapshot (or PITR datetime).
4. Click "Restore Database." This creates a **new** Database instance. Wait until the provisioning is fully complete.
5. In your target environment configuration (`.env` or Cloud Secrets), temporarily update the `DATABASE_URL` to point to the new cluster.
6. Verify the application logic, run sanity queries.
7. Once verified, modify the DNS load balancers or redeploy pointing fully to the new restored DB. Destroy the corrupted old DB.

### Documented monthly tests
For ISO compliance, a manual restore test must be executed monthly.
- Procedure: Execute the restore into a Staging environment. Connect tools to verify row counts, integrity of references, and general health check. After the dry run succeeds, destroy the staging snapshot.

## 5. Administrative Controls

To manually command a database maintenance cleanup immediately (such as purging expired, inactive records older than 2 years based on the retention policy), the `/admin/trigger-cleanup` POST REST API endpoint is exposed, callable only by the `owner` capability role.
