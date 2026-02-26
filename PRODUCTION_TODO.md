# Shuttler — Production To-Do List

**Generated**: February 2026
**Based on**: `PRODUCTION_READINESS_PLAN.md` v1.1 + additional gap analysis
**Target Platforms**: iOS · Android · macOS · Cloud Backend
**Overall Readiness**: ~30% — Security holes are the single biggest risk

> Items marked `[GAP]` were **not in the original plan** but are required for a production-grade release.

---

## Legend
- 🔴 CRITICAL — Blocker. App must not go live without this.
- 🟠 HIGH — Must be done before or at launch.
- 🟡 MEDIUM — Important quality / UX item; do before launch if possible.
- 🟢 LOW — Nice-to-have; can ship in a follow-up version.
- `[GAP]` — Missing from the original readiness plan.

---

## PHASE A — Security & Authentication
*Complete this before any real user data is stored. Estimated: 2 weeks.*

### A1 · JWT Authentication (Backend)
- [ ] 🔴 Install and configure `python-jose` for JWT token generation (library already installed, not used)
- [ ] 🔴 Implement `POST /auth/login` → returns `{access_token, refresh_token, user_data}`
- [ ] 🔴 Access token: short-lived (15–60 min); refresh token: 7–30 days
- [ ] 🔴 Implement `POST /auth/refresh` endpoint
- [ ] 🔴 Implement `POST /auth/logout` endpoint (add token to blacklist / revocation list)
- [ ] 🔴 Implement `GET /auth/me` endpoint (current user profile)
- [ ] 🔴 Protect ALL backend endpoints with Bearer token validation via FastAPI `Depends(get_current_user)`
- [ ] 🔴 Token revocation list (blacklist in Redis or DB) for logout
- [ ] 🔴 Invalidate ALL tokens on password change

### A2 · Secure Token Storage (Flutter)
- [ ] 🔴 Add `flutter_secure_storage: ^9.2.2` to `pubspec.yaml`
- [ ] 🔴 Migrate ALL credentials from `SharedPreferences` to `flutter_secure_storage` (access token, refresh token, FCM token)
- [ ] 🔴 Add Dio interceptor to attach `Authorization: Bearer <token>` to every request
- [ ] 🔴 Add Dio interceptor to auto-refresh token on 401 response (with retry)
- [ ] 🔴 On refresh token expiry: clear all stored data and redirect to login screen
- [ ] 🔴 Clear all secure storage on logout

### A3 · Role-Based Authorization (Backend)
- [ ] 🔴 Create `get_current_user` dependency that validates JWT and returns user
- [ ] 🔴 Create `require_owner`, `require_coach`, `require_student` dependency functions
- [ ] 🔴 Apply role guards to ALL 100+ endpoints — owner-only, coach-only, student read-only
- [ ] 🔴 Return HTTP 403 (not 401) for valid token but insufficient role

### A4 · IDOR / Ownership Enforcement
- [ ] 🔴 Audit every `GET /attendance/student/{id}`, `GET /fees/student/{id}`, `GET /performance/student/{id}`, `GET /bmi/student/{id}` — students can only see their own data
- [ ] 🔴 Coaches can only access students in their assigned batches — enforce for every endpoint
- [ ] 🔴 Create reusable `verify_coach_batch_access(coach_id, batch_id, db)` utility
- [ ] 🔴 Audit ALL GET/PUT/DELETE endpoints for ownership enforcement (students, coaches, fees, payments, performance, BMI, notifications, profile photos, leave requests)

### A5 · Mass Assignment Protection
- [ ] 🔴 Audit ALL Pydantic request schemas — remove `id`, `role`, `status`, `created_at`, `is_deleted`, `fcm_token` from user-facing update schemas
- [ ] 🔴 Use separate Pydantic schemas for `Create` vs `Update` vs `Response`

### A6 · HTTPS / TLS
- [ ] 🔴 Deploy backend behind Nginx reverse proxy with SSL/TLS termination
- [ ] 🔴 Use Let's Encrypt (Certbot) or cloud-managed HTTPS (Railway/Render auto-provision)
- [ ] 🔴 Enforce HTTP → HTTPS redirect
- [ ] 🔴 Enable HSTS header (`Strict-Transport-Security: max-age=31536000; includeSubDomains`)
- [ ] 🔴 Update Flutter API base URL from `http://` to `https://`
- [ ] 🔴 Ensure no `http://` URLs are hardcoded anywhere in the Flutter codebase
- [ ] 🔴 Remove `NSAllowsArbitraryLoads: true` from iOS `Info.plist` if present

### A7 · CORS Lockdown
- [ ] 🔴 Replace wildcard `allow_origins=["*"]` with specific production domain(s) only
- [ ] 🔴 Specify `allow_methods` and `allow_headers` explicitly

### A8 · Rate Limiting
- [ ] 🔴 Add `slowapi==0.1.9` to backend
- [ ] 🔴 Login endpoint: max 5 attempts per IP per 15 minutes
- [ ] 🔴 Forgot password: max 3 requests per email per hour
- [ ] 🔴 General API: max 100 requests per user per minute
- [ ] 🔴 File upload: max 10 uploads per user per hour
- [ ] 🔴 Return HTTP 429 with `Retry-After` header

### A9 · Security Headers
- [ ] 🔴 Add via Nginx or FastAPI middleware: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `X-XSS-Protection: 1; mode=block`, `Content-Security-Policy`, `Referrer-Policy: no-referrer`

### A10 · Secrets Management
- [ ] 🔴 Verify `.env` is in `.gitignore` and never committed
- [ ] 🔴 Rotate ALL secrets (DB password, JWT secret key) before going live
- [ ] 🔴 Use cloud provider secrets injection (Railway/AWS Secrets Manager/GCP Secret Manager)
- [ ] 🔴 Use a strong, random `SECRET_KEY` (minimum 256-bit entropy)
- [ ] 🔴 Separate secrets per environment (dev / staging / prod)
- [ ] 🔴 Add `google-services.json`, `GoogleService-Info.plist`, `*.pem`, `*.p12` to `.gitignore`

### A11 · Password & Account Security
- [ ] 🔴 Enforce minimum password length (8 chars), complexity, and maximum length (72 bytes for BCrypt)
- [ ] 🔴 Add password strength indicator in signup screen
- [ ] 🔴 Fix account enumeration: return identical error message for wrong email AND wrong password ("Invalid email or password")
- [ ] 🔴 Password reset tokens: cryptographically random (`secrets.token_urlsafe(32)`), single-use, expire after 15 min, stored as hash in DB
- [ ] 🟠 Rate-limit password reset requests (3 per email per hour)
- [ ] 🟡 Implement concurrent session control (view and revoke active sessions)
- [ ] 🟡 "Log out all devices" option in settings

### A12 · Input Validation & File Upload Security
- [ ] 🔴 Validate all text inputs (length limits, allowed characters) server-side
- [ ] 🔴 Validate file MIME type using magic bytes (not just file extension)
- [ ] 🔴 Restrict upload types to image/jpeg, image/png, image/webp only
- [ ] 🔴 Enforce 5 MB max file size per upload
- [ ] 🔴 Sanitize filenames: strip directory components, special characters; enforce server-generated UUID filename for ALL uploads (verify no exceptions)
- [ ] 🔴 Validate email format, phone number format, date ranges (start_date < end_date) server-side
- [ ] 🟠 Protect announcement/notification text against XSS

### A13 · Data Encryption
- [ ] 🟠 Enable SSL for PostgreSQL connections (`sslmode=require` in DATABASE_URL)
- [ ] 🟠 Enable database-level encryption at rest (cloud-managed on RDS/Railway)
- [ ] 🟠 Enable S3 server-side encryption for uploaded files
- [ ] 🟡 Encrypt sensitive fields at rest in DB (guardian phone, address) using `pgcrypto`

### A14 · Path Traversal Protection
- [ ] 🔴 Verify server-side UUID filenames are enforced for ALL file upload endpoints (not just profile photos)
- [ ] 🔴 Store uploaded files in an isolated directory with no execute permissions

### A15 · Bola for Coaches
- [ ] 🔴 Before coach marks attendance: verify batch is assigned to that coach
- [ ] 🔴 Before coach records performance: verify student is in their batch
- [ ] 🔴 Before coach updates a student record: verify access rights

### A16 · Supply Chain Security
- [ ] 🔴 Scan Git history for leaked secrets: run `truffleHog --regex --entropy=True .`
- [ ] 🔴 Enable GitHub Secret Scanning (Settings → Security → Secret Scanning)
- [ ] 🔴 If any secrets found in history: rotate ALL affected credentials immediately
- [ ] 🔴 Run `pip-audit -r requirements.txt` — fix any high/critical CVEs
- [ ] 🟠 Run `flutter pub outdated` and update vulnerable packages
- [ ] 🟠 Create `.github/dependabot.yml` for automatic dependency update PRs (pip + pub)
- [ ] 🟠 Add `git-secrets` pre-commit hook to prevent future secret commits
- [ ] 🟠 Commit `pubspec.lock` to Git (reproducible builds)
- [ ] 🟡 Verify Dio `badCertificateCallback` does NOT return `true` in production builds
- [ ] 🟡 Verify Hive local database is NOT storing sensitive data unencrypted

---

## PHASE B — Core App Features (Pending)
*All HIGH-priority items needed before beta. Estimated: 2 weeks.*

### B1 · Multiple Coach Assignment per Batch
- [ ] 🟠 Backend: Enable many-to-many via existing `batch_coaches` junction table; remove `assigned_coach_id` single-field dependency
- [ ] 🟠 Backend: Update batch create/update endpoints for multi-coach
- [ ] 🟠 Flutter: Update `Batch` model to `List<int> assignedCoachIds`
- [ ] 🟠 Flutter: Update batch create/edit form with multi-select coach picker
- [ ] 🟠 Flutter: Update batch card to display multiple coaches

### B2 · Partial Payment Status for Fees
- [ ] 🟠 Backend: Update `calculate_fee_status()` to return `'partial'` when `0 < total_paid < amount`
- [ ] 🟠 Flutter: Add `partial` to `Fee` model status enum
- [ ] 🟠 Flutter: Add "Partially Paid" badge/color in fees UI and filter chips

### B3 · Payment Method Standardization
- [ ] 🟠 Flutter: Update `add_payment_dialog.dart` — restrict to Cash and Card only (remove UPI, Bank Transfer)
- [ ] 🟠 Flutter: Update `record_payment_dialog.dart` — same restriction
- [ ] 🟠 Backend: Add server-side validation for allowed payment methods (`cash`, `card`)

### B4 · Session-wise Reports
- [ ] 🟠 Backend: Add `/reports/attendance/session/{session_id}` endpoint
- [ ] 🟠 Backend: Add `/reports/fees/session/{session_id}` endpoint
- [ ] 🟠 Backend: Add `/reports/performance/session/{session_id}` endpoint
- [ ] 🟠 Flutter: Add session picker/filter to reports screen

### B5 · Notification Triggers (FCM)
- [ ] 🟠 Backend: Install `firebase-admin==6.3.0`
- [ ] 🟠 Backend: Configure Firebase service account credentials
- [ ] 🟠 Backend: Implement `send_push_notification(fcm_token, title, body, data)` utility
- [ ] 🟠 Backend: Attendance marked → notify student (present/absent)
- [ ] 🟠 Backend: Performance recorded → notify student
- [ ] 🟠 Backend: BMI recorded → notify student
- [ ] 🟠 Backend: Announcement published → notify target audience
- [ ] 🟠 Backend: Leave request approved/rejected → notify coach
- [ ] 🟠 Backend: Fee payment received → notify student
- [ ] 🟠 Backend: Verify fee overdue cron job (APScheduler) is working

### B6 · In-App Notification Center Fixes
- [ ] 🟡 Verify notification read/unread status works end-to-end
- [ ] 🟡 Notification badge count on home screen icon
- [ ] 🟡 Mark all as read functionality
- [ ] 🟡 Notification tap action navigates to the relevant screen

### B7 · Notification Preferences
- [ ] 🟡 Allow users to toggle which notifications they receive (per type)
- [ ] 🟡 Store preferences in user profile (backend)
- [ ] 🟡 Respect preferences in backend trigger logic

### B8 · Performance Entry Completion Status (Coach Portal)
- [ ] 🟡 Backend: Add completion status tracking for performance records per session
- [ ] 🟡 Flutter: Create `coach_performance_screen.dart` with checklist (which students have/haven't been assessed)

### B9 · Student Batch Capacity Visibility
- [ ] 🟡 Flutter: Audit `student_batches_screen.dart` — remove capacity/total slots from student view

### B10 · Database Table Cleanup
- [ ] 🟡 Investigate `requests` table (no model exists) — create model or drop via Alembic migration

### B11 · `[GAP]` — Transactional Email Service
- [ ] 🟠 Select and integrate an email service: SendGrid, AWS SES, or Mailchimp Transactional (Mandrill)
- [ ] 🟠 Password reset: send email with secure reset link (currently only token-based — unclear if email is sent)
- [ ] 🟠 Coach/student invitation: send email alongside WhatsApp link
- [ ] 🟠 Welcome email on successful account creation
- [ ] 🟠 Payment receipt email on successful fee payment
- [ ] 🟡 Fee overdue reminder email (in addition to push notification)

### B12 · `[GAP]` — Payment Gateway Integration (Card Processing)
- [ ] 🟠 Decide if the app processes cards directly or just records in-person card transactions
- [ ] 🟠 If online card processing: integrate Stripe (or Square for Canadian market)
- [ ] 🟠 If in-person only: clearly label UI as "record a payment received" (not "process payment")
- [ ] 🟡 Stripe or Square webhook handling for payment status updates (if online)
- [ ] 🟡 PCI-DSS compliance assessment if handling card data directly

---

## PHASE C — Database & Infrastructure
*Production-grade data layer. Estimated: 2 weeks.*

### C1 · Alembic Migrations
- [ ] 🔴 Initialize Alembic properly: `alembic init alembic`
- [ ] 🔴 Configure `alembic.ini` and `env.py` with database URL (from environment variable)
- [ ] 🔴 Convert all existing manual SQL migration scripts to Alembic migration files
- [ ] 🔴 Create an initial baseline migration from current models
- [ ] 🔴 All future schema changes go through Alembic only (never manual SQL in production)
- [ ] 🔴 Alembic migrations run automatically in CI/CD pre-deploy step

### C2 · Database Indexing
- [ ] 🟠 Add index: `students(status)`
- [ ] 🟠 Add index: `attendance(batch_id, date)` and `attendance(student_id, date)`
- [ ] 🟠 Add index: `fees(student_id, status)`
- [ ] 🟠 Add index: `notifications(user_id, user_type, is_read)`
- [ ] 🟠 Add index: `batches(session_id, status)`
- [ ] 🟠 Add index: `performance(student_id, date)`
- [ ] 🟠 Add index: `bmi_records(student_id, date)`
- [ ] 🟠 Deliver all indexes as Alembic migrations

### C3 · Database Backups
- [ ] 🔴 Enable automated daily backups (`pg_dump` or cloud-managed)
- [ ] 🔴 Enable Point-In-Time Recovery (PITR) on cloud PostgreSQL
- [ ] 🔴 Backup retention: minimum 30 days
- [ ] 🔴 Backup to separate storage (S3 or equivalent)
- [ ] 🟠 Document and test restore procedure (restore from backup monthly)
- [ ] 🟡 Add admin endpoint to manually trigger cleanup job

### C4 · Database Connection & Health
- [ ] 🟠 Verify connection pool settings are appropriate for production load
- [ ] 🟠 Add health check endpoints: `GET /health`, `GET /health/db`, `GET /health/redis` (once Redis is added)
- [ ] 🟠 Configure `connect_args={"connect_timeout": 10}` for connection timeout
- [ ] 🟠 Ensure `pool_pre_ping=True` is set for stale connection detection
- [ ] 🟠 Log when connection pool is exhausted

### C5 · Data Archiving / Retention Policy
- [ ] 🟡 Define and document data retention policy
- [ ] 🟡 Archive to a separate archive table before deletion (don't hard-delete)
- [ ] 🟡 Verify the APScheduler cleanup job (inactive records >2 years) is working correctly

### C6 · Cloud Deployment
- [ ] 🔴 Select cloud provider: Railway.app or Render.com (recommended for start)
- [ ] 🔴 Deploy FastAPI backend to cloud
- [ ] 🔴 Provision managed PostgreSQL on cloud (with SSL, automated backups, PITR)
- [ ] 🟠 Register a domain name (e.g., `api.shuttler.app`)
- [ ] 🟠 Configure DNS records pointing to backend
- [ ] 🟠 Configure SSL certificate for domain

### C7 · File Storage Migration
- [ ] 🔴 Migrate file uploads from local disk to cloud object storage (AWS S3 or Cloudflare R2)
- [ ] 🔴 Update upload endpoint to store to cloud instead of local disk
- [ ] 🟠 Serve files via CDN for performance and global availability
- [ ] 🟠 Update Flutter to load images from CDN URLs
- [ ] 🟠 Add `boto3==1.34.0` (or equivalent) to backend requirements

### C8 · Redis Cache
- [ ] 🟠 Deploy Redis instance (Redis Cloud free tier or Railway Redis)
- [ ] 🟠 Add `redis==5.0.1` and `fastapi-cache2==0.2.1` to backend
- [ ] 🟠 Cache active batches list (TTL: 5 min), student list (TTL: 2 min), coach list (TTL: 5 min), calendar events (TTL: 1 hr), academy details (TTL: 1 hr)
- [ ] 🟠 Cache invalidation: clear relevant keys on write operations
- [ ] 🟠 Token revocation list in Redis (for JWT blacklist)

### C9 · API Layer Quality
- [ ] 🟠 API Versioning: prefix all endpoints with `/api/v1/`
- [ ] 🔴 Pagination: add `?page=1&limit=20` to ALL list endpoints (students, batches, attendance, fees, etc.)
- [ ] 🟠 Standardize all API responses: `{success, data, message, error}` format
- [ ] 🟠 Disable Swagger UI in production (`docs_url=None` when `IS_PRODUCTION=true`)
- [ ] 🟠 Move PDF generation to background task (FastAPI BackgroundTasks); return job ID; notify on completion
- [ ] 🟡 Add `GET /reports/status/{job_id}` endpoint for async report status

### C10 · Docker & CI/CD
- [ ] 🔴 Create `Backend/Dockerfile` (multi-stage build)
- [ ] 🟠 Create `docker-compose.yml` for local dev (FastAPI + PostgreSQL + Redis)
- [ ] 🔴 Create `.github/workflows/backend-ci.yml`: lint → test → security-scan → build → deploy-staging → deploy-prod (with approval gate)
- [ ] 🔴 Create `.github/workflows/flutter-ci.yml`: analyze → test → build-android → build-ios → deploy
- [ ] 🔴 Three environments: Development (localhost), Staging (`api-staging.shuttler.app`), Production (`api.shuttler.app`)
- [ ] 🟠 Create `.env.dev`, `.env.staging`, `.env.prod` (never commit `.env.prod`)
- [ ] 🟡 Infrastructure as Code (Terraform / Pulumi) — or use managed platform defaults

### C11 · Usage Capping & Quotas
- [ ] 🟠 Per-academy API quota: 10,000 calls/day tracked in Redis
- [ ] 🟠 Burst allowance: max 200 requests/min per academy
- [ ] 🟠 Return HTTP 429 with `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers
- [ ] 🟠 Storage quota per academy (define limits per tier); track cumulative upload size
- [ ] 🟠 Reject uploads when quota exceeded (HTTP 413)
- [ ] 🟡 Show storage usage dashboard in owner portal
- [ ] 🟡 Invitation token expiry: 7 days, single-use, invalidate on student removal
- [ ] 🟡 FCM notification rate limiting: max 10 push/student/day, max 5 announcements/owner/hour

### C12 · Audit Trail & Logging
- [ ] 🟠 Create `audit_logs` table: user_id, role, action, resource_type, resource_id, old_values (JSONB), new_values (JSONB), ip_address, timestamp
- [ ] 🟠 Log: student created/updated/deleted, fee payment recorded, attendance marked, coach assigned/removed, leave approved/rejected, announcement created/deleted, password changed, login/logout, failed login attempts
- [ ] 🔴 Financial audit: prevent deletion of fee payment records (soft-cancel with reason); lock payments after 24 hours
- [ ] 🟠 Login activity tracking: timestamp, IP address, device/OS per login
- [ ] 🟠 Auto-lock account after 10 consecutive failed logins; notify owner
- [ ] 🟠 Login history: owners can view login history for their coaches/students (min 90 days retention)

### C13 · `[GAP]` — Data Migration Plan (Local → Cloud)
- [ ] 🔴 Document step-by-step plan to migrate existing local PostgreSQL data to cloud DB
- [ ] 🔴 Migrate existing uploaded files from local disk to S3/R2
- [ ] 🟠 Test migration with a full dry-run on staging environment
- [ ] 🟠 Define rollback procedure if migration fails

### C14 · `[GAP]` — Rollback Strategy
- [ ] 🟠 Document rollback procedure for bad backend deployments (prior Docker image tag)
- [ ] 🟠 Test Alembic `downgrade` path for every migration before applying to production
- [ ] 🟡 Feature flags: ability to disable a new feature without redeployment

### C15 · `[GAP]` — Network Security
- [ ] 🟠 Restrict database port (5432) access to backend server IP only (VPC / security group rules)
- [ ] 🟠 Restrict Redis port (6379) access to backend server only
- [ ] 🟠 Firewall: only expose ports 80 and 443 publicly
- [ ] 🟡 Consider VPN or private network access for database administration

---

## PHASE D — Testing
*Minimum 70% coverage target. Estimated: 2 weeks.*

### D1 · Backend Tests
- [ ] 🔴 Add `pytest==7.4.3`, `httpx==0.25.2`, `pytest-asyncio==0.21.1` to requirements
- [ ] 🔴 Unit tests: fee calculation, status calculation, invitation token generation
- [ ] 🔴 Integration tests for all 100+ API endpoints using `httpx` TestClient
- [ ] 🔴 Separate test database (not production)
- [ ] 🔴 Test authentication flows: login, token refresh, invalid token, expired token
- [ ] 🔴 Test role-based access: student trying owner endpoints → 403; coach trying owner endpoints → 403
- [ ] 🔴 Test IDOR: student A cannot access student B's data
- [ ] 🔴 Minimum 70% code coverage target (use `pytest-cov`)

### D2 · Flutter Tests
- [ ] 🔴 Unit tests for all service classes (auth, fee, student, batch, coach, attendance)
- [ ] 🔴 Unit tests for all Riverpod provider logic
- [ ] 🟠 Widget tests for key screens (login, dashboard, forms)
- [ ] 🟠 Add `mockito: ^5.4.4` or `mocktail: ^1.0.3` for mocking
- [ ] 🟡 Integration tests for critical user flows: Login → Dashboard → Mark Attendance; Login → Add Student → View Student; Login → Record Fee Payment → View Updated Status

### D3 · Security Testing
- [ ] 🟠 Run `bandit` (Python security linter) on backend: `bandit -r Backend/`
- [ ] 🟠 Test SQL injection on all text input fields
- [ ] 🟠 Test for authentication bypass (call protected endpoint without token)
- [ ] 🟠 Test for privilege escalation (student calling owner endpoints)
- [ ] 🟠 Test rate limiting is enforced correctly
- [ ] 🟡 Run OWASP ZAP or Burp Suite for API vulnerability scanning

### D4 · Performance Testing
- [ ] 🟠 Load test with `locust` or `k6`: 500 students, 50 coaches, 100 batches, 10,000 attendance records
- [ ] 🟠 Identify and fix N+1 query problems (use `EXPLAIN ANALYZE`)
- [ ] 🟠 Target: API responses < 300ms at p95 under normal load
- [ ] 🟠 Add query timeout (30 seconds max)
- [ ] 🟡 Profile Flutter app with DevTools — fix jank/slow frames

### D5 · Device & Compatibility Testing
- [ ] 🔴 Test on multiple Android versions (API 26+) and screen sizes
- [ ] 🔴 Test on multiple iOS versions (iOS 13+) and device sizes (iPhone SE, regular, Pro Max, iPad)
- [ ] 🔴 Test on macOS (if macOS target is added — see Phase F)
- [ ] 🟠 Full E2E flow testing for all 3 user roles (Owner, Coach, Student)
- [ ] 🟠 Test offline scenarios: show cached data, queue requests, sync on reconnect

---

## PHASE E — Mobile App Hardening
*Before any app store submission.*

### E1 · Code Obfuscation
- [ ] 🟠 Android release: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/`
- [ ] 🟠 iOS release: `flutter build ipa --release --obfuscate --split-debug-info=build/symbols/`
- [ ] 🟠 Store `symbols/` directory securely (needed for crash symbolication)
- [ ] 🟠 Upload symbols to Firebase Crashlytics

### E2 · Root / Jailbreak Detection
- [ ] 🟠 Add `flutter_jailbreak_detection: ^1.8.0` or `root_detection: ^2.0.0`
- [ ] 🟠 Show warning to user on compromised device (do not silently block to avoid locking out legitimate users)

### E3 · Screenshot & Screen Recording Prevention
- [ ] 🟠 Add `flutter_windowmanager: ^0.2.0` (Android)
- [ ] 🟠 Apply `FLAG_SECURE` on sensitive screens (fee data, personal info, guardian phone numbers)

### E4 · Certificate Pinning (Recommended)
- [ ] 🟡 Pin backend SSL certificate public key in Dio client
- [ ] 🟡 Plan certificate rotation before expiry (keep backup pin)

### E5 · Anti-Tampering
- [ ] 🟠 Verify ProGuard/R8 is enabled for Android release builds
- [ ] 🔴 Remove all hardcoded secrets (API keys, URLs) from Flutter source code
- [ ] 🔴 Use `--dart-define=API_URL=https://api.shuttler.app` for build-time config

### E6 · App Transport Security (iOS)
- [ ] 🔴 Ensure ALL API calls use HTTPS before iOS submission (ATS will block HTTP)
- [ ] 🔴 Remove any `NSAllowsArbitraryLoads: true` from `Info.plist`

### E7 · API Timeout Configuration (Flutter)
- [ ] 🟠 Set Dio connection timeout: 30 seconds
- [ ] 🟠 Set Dio receive timeout: 60 seconds (longer for file uploads)
- [ ] 🟠 Set Dio send timeout: 30 seconds
- [ ] 🟠 Handle timeout errors gracefully in UI with retry option

### E8 · Biometric Authentication (Nice-to-Have)
- [ ] 🟢 Add `local_auth: ^2.2.0`
- [ ] 🟢 Biometric unlock on app re-open after backgrounding (optional, for Owner/Coach)

---

## PHASE F — App Store Preparation
*iOS · Android · macOS*

### F1 · Legal Documents (Required by All Stores)
- [ ] 🔴 Write comprehensive Privacy Policy (data collected, purpose, storage, retention, user rights, contact)
- [ ] 🔴 Host Privacy Policy at public URL (e.g., `https://shuttler.app/privacy`)
- [ ] 🔴 Add Privacy Policy link in app Settings screen
- [ ] 🔴 Write Terms of Service for owners and students
- [ ] 🔴 Host Terms of Service at public URL (e.g., `https://shuttler.app/terms`)
- [ ] 🔴 Add ToS link in signup flow and settings

### F2 · Account Deletion (App Store Required Since 2022)
- [ ] 🔴 Implement in-app account deletion in settings
- [ ] 🔴 Backend: `DELETE /users/me/account` — anonymize or remove ALL personal data
- [ ] 🔴 Do not just soft-delete: true erasure must be possible

### F3 · App Icon & Splash Screen
- [ ] 🟠 Create 1024×1024 master app icon (custom branded, no default Flutter icon)
- [ ] 🟠 Create adaptive icon for Android (foreground + background layers)
- [ ] 🟠 Create custom splash screen with brand colors and logo
- [ ] 🟠 Add `flutter_launcher_icons: ^0.13.1` and `flutter_native_splash: ^2.4.0`

### F4 · App Permissions
- [ ] 🟠 Add `permission_handler: ^11.3.1`
- [ ] 🟠 Request camera permission only when feature is used (profile photo via camera)
- [ ] 🟠 Request photo library permission only when feature is used
- [ ] 🟠 Request notification permission at a contextually appropriate time (not on launch)
- [ ] 🟠 Handle permission denied gracefully with explanation and settings redirect

### F5 · Deep Linking for Invitations
- [ ] 🟠 Android: configure App Links (Digital Asset Links file at `/.well-known/assetlinks.json`)
- [ ] 🟠 iOS: configure Universal Links (`/.well-known/apple-app-site-association`)
- [ ] 🟠 Configure GoRouter to handle deep link paths for student/coach invitations

### F6 · Google Play Store (Android)
- [ ] 🔴 Generate release keystore; configure in `android/app/build.gradle`
- [ ] 🔴 Configure `flutter build appbundle --release` (`.aab` format for Play Store)
- [ ] 🔴 Add ProGuard rules for Flutter plugins
- [ ] 🔴 Update `google-services.json` with production Firebase credentials
- [ ] 🔴 Target SDK: Android API 34+ (current Play Store requirement)
- [ ] 🔴 Review `AndroidManifest.xml` — justify all requested permissions
- [ ] 🟠 App metadata: name, short description (80 chars), full description (4000 chars)
- [ ] 🟠 App icon (512×512 PNG), feature graphic (1024×500 PNG)
- [ ] 🟠 Screenshots: minimum 2, up to 8 (phone and tablet)
- [ ] 🟠 Categorization: Education or Sports
- [ ] 🟠 Fill Data Safety Section (declare data collected)
- [ ] 🟠 Fill IARC content rating questionnaire
- [ ] 🟡 Google Play Internal Testing track (minimum 1 week before public)

### F7 · Apple App Store (iOS)
- [ ] 🔴 Register Apple Developer Account ($99/year)
- [ ] 🔴 Register App ID / Bundle ID in Apple Developer Portal
- [ ] 🔴 Create Distribution Certificate and Provisioning Profile
- [ ] 🔴 Configure `flutter build ipa --release`
- [ ] 🔴 Update `Info.plist` for camera and photo library permission descriptions
- [ ] 🔴 Configure push notification entitlement in Xcode
- [ ] 🔴 Update `GoogleService-Info.plist` with production Firebase config
- [ ] 🔴 Set iOS deployment target (minimum iOS 13.0)
- [ ] 🟠 App metadata in App Store Connect: name, subtitle, description, keywords
- [ ] 🟠 App icon (1024×1024 PNG), screenshots for iPhone 6.7", 6.5", iPad
- [ ] 🟠 Privacy Nutrition Labels (data types and usage purposes)
- [ ] 🟠 Age Rating questionnaire
- [ ] 🟠 Create demo/reviewer account with populated test data for App Store review team
- [ ] 🟠 Remove all placeholder "coming soon" content
- [ ] 🟡 TestFlight beta testing (minimum 2 weeks before App Store submission)

### F8 · `[GAP]` — macOS App (Mac App Store / Direct Distribution)
- [ ] 🟠 Enable macOS target in Flutter project: `flutter config --enable-macos-desktop`
- [ ] 🟠 Configure macOS entitlements (`DebugProfile.entitlements`, `Release.entitlements`)
- [ ] 🟠 Update UI for larger screens: responsive layouts, keyboard navigation, mouse interaction
- [ ] 🟠 Configure macOS code signing (Developer ID Application certificate)
- [ ] 🟠 macOS notarization (required for distribution outside Mac App Store)
- [ ] 🟠 Configure Hardened Runtime (required for notarization)
- [ ] 🟠 Update network access entitlement (`com.apple.security.network.client`)
- [ ] 🟡 macOS App Store submission if distributing via App Store (separate from direct distribution)
- [ ] 🟡 Adapt to macOS window management (resizable, drag-and-drop)
- [ ] 🟡 macOS menu bar integration (standard menus)

### F9 · Versioning & Release Management
- [ ] 🟠 Auto-increment build number in CI/CD pipeline
- [ ] 🟠 Create Git tags for each release (`v1.0.0`, `v1.0.1`, etc.)
- [ ] 🟠 Maintain `CHANGELOG.md`
- [ ] 🟠 Use release branch strategy (main, develop, feature branches)

### F10 · `[GAP]` — App Update Management (Forced Updates)
- [ ] 🟠 Backend: maintain minimum supported app version in config or DB
- [ ] 🟠 On app launch: compare app version with minimum supported version
- [ ] 🟠 If below minimum: show mandatory update dialog, prevent usage until updated
- [ ] 🟡 Add `in_app_update` (Android) for in-app update flow
- [ ] 🟡 Add `upgrader: ^10.0.0` package for cross-platform update prompt

---

## PHASE G — Monitoring & Observability
*Set up before and immediately after launch.*

### G1 · Structured Logging (Backend)
- [ ] 🔴 Replace all `print()` with Python `logging` module
- [ ] 🟠 Add `loguru==0.7.2` for structured JSON logging
- [ ] 🟠 Log every API request: method, path, status code, duration, user_id
- [ ] 🟠 Log all authentication events (success and failure with IP)
- [ ] 🟠 Log all errors and exceptions with stack traces (not exposed to clients)
- [ ] 🟠 Log background job execution results
- [ ] 🔴 Never expose stack traces in API error responses in production

### G2 · Error Tracking (Sentry)
- [ ] 🔴 Backend: add `sentry-sdk[fastapi]==1.38.0`
- [ ] 🔴 Flutter: add `sentry_flutter: ^8.4.0`
- [ ] 🟠 Configure error grouping, assignment, and alert rules for new errors

### G3 · Global Exception Handler
- [ ] 🔴 Add FastAPI `@app.exception_handler(Exception)` — log error, return safe response (no stack trace)
- [ ] 🔴 Flutter: configure `FlutterError.onError` and `PlatformDispatcher.instance.onError` handlers
- [ ] 🟠 Flutter: handle all Dio errors uniformly; show user-friendly messages
- [ ] 🟠 Flutter: retry mechanism for transient network errors (exponential backoff)

### G4 · Crash Reporting (Mobile)
- [ ] 🔴 Add `firebase_crashlytics: ^4.1.3`
- [ ] 🔴 Upload obfuscation symbols to Crashlytics
- [ ] 🟠 Link crash reports to user sessions

### G5 · Performance Monitoring
- [ ] 🟠 Add `firebase_performance: ^0.10.0+6` (screen load times, network latency)
- [ ] 🟠 Backend APM: Sentry Performance or Datadog (trace slow API calls)
- [ ] 🟠 PostgreSQL: enable `log_min_duration_statement = 1000` for slow query logging

### G6 · Uptime Monitoring
- [ ] 🟠 Configure UptimeRobot (free) or Better Uptime for health check monitoring
- [ ] 🟠 Alert via email/Slack when backend goes down
- [ ] 🟠 Target uptime SLA: 99.5%

### G7 · Analytics
- [ ] 🟡 Add `firebase_analytics: ^11.3.3`
- [ ] 🟡 Track: login, screen views, fee payment recorded, attendance marked, report generated

### G8 · Flutter-Side Caching & Offline
- [ ] 🟠 Cache API responses in Hive with TTL (stale-while-revalidate pattern)
- [ ] 🟠 Show cached data when offline; queue write operations for sync on reconnect
- [ ] 🟠 Clear all cached data on logout
- [ ] 🟠 Add `Cache-Control: no-store` headers to sensitive API responses

### G9 · `[GAP]` — Disaster Recovery Plan
- [ ] 🟠 Document: what happens if production DB is corrupted → how to restore
- [ ] 🟠 Document: what happens if backend server goes down → failover procedure
- [ ] 🟠 Document: what happens if S3 file storage is inaccessible
- [ ] 🟠 Test restore from backup: do this before go-live, not after
- [ ] 🟡 Multi-region backup for critical DB data

---

## PHASE H — Privacy, Legal & Compliance

### H1 · PIPEDA (Canada)
- [ ] 🔴 Conduct PIPEDA assessment (Personal Information Protection and Electronic Documents Act)
- [ ] 🔴 Obtain explicit consent before collecting personal data (opt-in, not pre-ticked)
- [ ] 🔴 Provide right to access and correct personal information
- [ ] 🔴 Implement right to withdrawal of consent (full account deletion)
- [ ] 🔴 Document breach notification procedure (notify affected users within 72 hours)
- [ ] 🟡 Assess applicability of provincial laws (PIPA in Alberta/BC)

### H2 · COPPA / Child Protection
- [ ] 🔴 Do NOT allow children under 13 to create accounts directly
- [ ] 🔴 Require parental/guardian consent for minors (guardian data already collected — use it)
- [ ] 🟠 Review App Store age rating settings (set appropriate age rating)

### H3 · GDPR (If Any EU Users)
- [ ] 🟡 Data processing consent mechanism
- [ ] 🟡 Right to erasure (full account deletion removing all personal data)
- [ ] 🟡 Data portability (export user's own data as JSON/CSV)

### H4 · Image HTTP-Level Caching
- [ ] 🟠 Serve uploaded images via CDN with far-future expiry headers
- [ ] 🟠 Static content: `Cache-Control: max-age=86400`

### H5 · `[GAP]` — SaaS Subscription & Billing (If Multi-Academy)
- [ ] 🟡 Define pricing tiers (Starter / Pro / Enterprise) with student/coach/batch limits
- [ ] 🟡 Integrate billing system (Stripe Billing or Paddle) for subscription management
- [ ] 🟡 Owner dashboard shows current plan, usage, and upgrade prompt
- [ ] 🟡 Automated invoice generation and email on billing cycle
- [ ] 🟡 Grace period on subscription expiry (14 days) before data access is restricted

### H6 · `[GAP]` — Legal Entity & Business Registration
- [ ] 🟠 Confirm business entity is registered before publishing on app stores (Play Store / App Store require a verified business or individual developer account)
- [ ] 🟠 Ensure correct legal name and address in developer accounts

---

## PHASE I — Performance Optimization

### I1 · Backend Query Optimization
- [ ] 🟠 Use `joinedload()` / `selectinload()` for relationships (eliminate N+1 queries)
- [ ] 🟠 Run `EXPLAIN ANALYZE` on all list endpoints with realistic data volume
- [ ] 🟠 Paginate all list endpoints (see Phase C9)
- [ ] 🟠 Cache frequently read data in Redis (see Phase C8)

### I2 · Image Optimization
- [ ] 🟠 Resize images on upload (generate thumbnail + full-size variant)
- [ ] 🟠 Convert uploads to WebP format (30–50% size reduction)
- [ ] 🟠 Serve via CDN with gzip/brotli compression
- [ ] 🟠 Ensure `cached_network_image` (already installed) is used for all remote images
- [ ] 🟠 Lazy load images in list views

### I3 · Flutter App Performance
- [ ] 🟠 Run `flutter analyze` and fix all warnings
- [ ] 🟠 Use `const` constructors wherever possible
- [ ] 🟠 Use `ListView.builder` (not `ListView`) for all long lists
- [ ] 🟠 Implement `keepAlive` for tab screens
- [ ] 🟠 Run `flutter build apk --split-per-abi` to reduce APK size

### I4 · Startup Time
- [ ] 🟡 Profile cold start time (target < 2 seconds)
- [ ] 🟡 Defer non-critical initializations to after first frame

---

## PHASE J — Accessibility

### J1 · Screen Reader Support
- [ ] 🟡 Add `Semantics` widgets to all custom components
- [ ] 🟡 Ensure all interactive elements have meaningful labels
- [ ] 🟡 Test with TalkBack (Android) and VoiceOver (iOS)

### J2 · Text Scaling
- [ ] 🟡 Test app with system font size at largest setting
- [ ] 🟡 Fix any text overflow or clipped content

### J3 · Color Contrast
- [ ] 🟡 Verify WCAG 2.1 AA contrast ratios (4.5:1 for normal text) for dark neumorphic theme
- [ ] 🟡 Adjust colors that fail the contrast check

---

## PHASE K — Documentation

### K1 · API Documentation
- [ ] 🟡 Document all endpoints with request/response examples (tags, summaries, descriptions in FastAPI)
- [ ] 🟡 Create Postman collection for API testing
- [ ] 🟡 Document authentication requirements and role permissions per endpoint

### K2 · Developer Onboarding
- [ ] 🟡 Complete local setup guide (backend + Flutter + PostgreSQL + Redis)
- [ ] 🟡 Common troubleshooting guide
- [ ] 🟡 Git branching strategy documentation
- [ ] 🟡 Architecture Decision Records (ADRs)

### K3 · Operations Runbook
- [ ] 🟠 How to deploy a new backend version
- [ ] 🟠 How to run Alembic migrations in production
- [ ] 🟠 How to restore from backup (step-by-step)
- [ ] 🟠 Incident response procedure (what to do when app goes down)

### K4 · User Documentation
- [ ] 🟡 In-app help/tour for first-time users (each role)
- [ ] 🟡 FAQ section in settings or help screen

### K5 · `[GAP]` — In-App Feedback & Support
- [ ] 🟡 Add in-app feedback form or "Report a problem" button
- [ ] 🟡 Link to support email or help desk from settings
- [ ] 🟡 Crash/bug report option triggered from error screens

---

## PHASE L — Post-Launch Features (Low Priority)
*Ship in follow-up versions after stable launch.*

- [ ] 🟢 Video library for students (`student_video_library_screen.dart`)
- [ ] 🟢 Digital waiver / consent system (digital signature before joining batch)
- [ ] 🟢 Advanced analytics dashboard for owner (trends, revenue, retention)
- [ ] 🟢 Multi-language / localization support (i18n framework)
- [ ] 🟢 Light mode toggle (currently dark-only)
- [ ] 🟢 Bulk attendance import (CSV upload)
- [ ] 🟢 Automated fee reminders (configurable schedule per academy)
- [ ] 🟢 Student portal: video library browser with in-app player
- [ ] 🟢 Coach attendance tracking (separate from student attendance)

---

## Summary — Gap Analysis (Items NOT in Original Plan)

| # | Gap Item | Priority |
|---|----------|----------|
| B11 | Transactional email service (SendGrid/AWS SES) | 🟠 HIGH |
| B12 | Payment gateway integration (Stripe/Square for card processing) | 🟠 HIGH |
| C13 | Data migration plan (local → cloud) | 🔴 CRITICAL |
| C14 | Rollback strategy for bad deployments | 🟠 HIGH |
| C15 | Network security / firewall rules (DB port isolation) | 🟠 HIGH |
| F8  | macOS app support (entitlements, signing, notarization, UI) | 🟠 HIGH |
| F10 | App update management / forced update mechanism | 🟠 HIGH |
| G9  | Disaster recovery plan | 🟠 HIGH |
| H5  | SaaS subscription & billing system | 🟡 MEDIUM |
| H6  | Legal entity & business registration for app stores | 🟠 HIGH |
| K5  | In-app feedback & support mechanism | 🟡 MEDIUM |

---

## Sprint Execution Order

| Sprint | Phases | Goal | Duration |
|--------|--------|------|----------|
| Sprint 1 | A (full) | Security Foundation — no real user data before this | 2 weeks |
| Sprint 2 | B (full) | Complete all pending app features | 2 weeks |
| Sprint 3 | C + D | Production infrastructure + testing | 2 weeks |
| Sprint 4 | E + F | App hardening + App Store preparation | 2 weeks |
| Sprint 5 | G + H | Monitoring, compliance, launch | 1–2 weeks |
| Ongoing | I + J + K + L | Performance, accessibility, docs, post-launch | After launch |

---

*Document generated: February 2026*
*Source: `PRODUCTION_READINESS_PLAN.md` v1.1 + gap analysis*
*Next update: After Sprint 1 completion*
