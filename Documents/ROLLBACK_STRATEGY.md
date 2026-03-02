# Rollback Strategy & Procedures

This document defines the protocols for reverting changes in the event of a failed deployment or critical bug discovery in production.

## 1. Backend Service Rollback (Docker/CI/CD)

If a new deployment causes instability (e.g., high crash rate, performance regression):

1. **Identify Stable Tag**: Locate the hash/tag of the previous successful build in GitHub Actions or DockerHub (e.g., `latest` vs `v1.2.0`).
2. **Revert Image**: Update the production environment's image reference back to the stable tag.
   - For Manual Deployments: `docker pull shuttlerapp/backend:<previous_tag> && docker-compose up -d`
   - For Managed Platforms: Select the previous stable deployment in the dashboard and click "Redeploy/Rollback".
3. **Trigger Re-deploy**: If using CI/CD, you can also revert the `main` branch to the previous commit and push, though re-pantomiming the image tag is usually faster.

## 2. Database Rollback (Alembic)

If a schema migration proves destructive or buggy:

1. **Assess Data Loss**: Before rolling back, determine if new data collected during the "buggy" period will be lost.
2. **Execute Downgrade**: Use Alembic to revert the schema to the previous version:
   ```bash
   alembic downgrade -1
   ```
   *Note: Always test `downgrade` locally or in staging BEFORE attempting in production.*
3. **Data Recovery**: If the migration deleted columns, you must restore from the most recent PG backup taken *before* the migration.

## 3. Frontend App Rollback

1. **Android**: If using Google Play Store, use the **Version Rollback** feature or promote the previous "Bundle" back to the production track.
2. **iOS**: Similar to Android, re-submit the previous stable build if Apple's "Expedited Review" isn't fast enough.
3. **Hotfixes**: For semi-critical bugs, prefers a "Forward-Fix" (releasing a new version with the fix) over a full rollback unless the app is completely unusable.

## 4. Feature Flags (Plan)

For critical features, wrap code in feature toggle checks:
```python
if os.getenv("ENABLE_NEW_ANALYTICS") == "true":
    run_new_logic()
else:
    run_old_logic()
```
This allows disabling broken features via environment variable updates without requiring a full code redeploy.
