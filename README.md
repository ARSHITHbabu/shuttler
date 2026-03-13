# Shuttler — Badminton Academy Management System

A production-grade, full-stack mobile application for managing badminton academies. Shuttler provides role-based portals for **Owners**, **Coaches**, and **Students** with comprehensive tools for batch management, fee tracking, attendance, performance analytics, and real-time notifications.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Flutter Setup](#flutter-setup)
  - [Docker Setup](#docker-setup)
- [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [Database Schema](#database-schema)
- [Security](#security)
- [Push Notifications](#push-notifications)
- [File Uploads](#file-uploads)
- [Running Tests](#running-tests)
- [Deployment](#deployment)
- [Roadmap](#roadmap)

---

## Overview

Shuttler streamlines the day-to-day operations of a badminton academy:

| Role | Capabilities |
|------|-------------|
| **Owner** | Full academy management — batches, coaches, students, fees, reports, analytics |
| **Coach** | Manage batches, mark attendance, track performance, upload training videos, handle leave |
| **Student** | View schedule, attendance, fees, performance, BMI, and announcements |

---

## Tech Stack

### Backend
| Layer | Technology |
|-------|-----------|
| Framework | FastAPI 0.115.4 |
| Language | Python 3.11 |
| Database | PostgreSQL 15 |
| ORM | SQLAlchemy 2.0.23 |
| Auth | JWT (python-jose 3.3.0) with refresh token rotation |
| Password Hashing | bcrypt |
| Caching | Redis 7 |
| Task Scheduling | APScheduler 3.10.4 |
| Push Notifications | Firebase Admin SDK 6.3.0 |
| Transactional Email | SendGrid 6.11.0 |
| Payment Gateway | Razorpay 1.4.1 |
| Object Storage | AWS S3 / Cloudflare R2 (boto3 1.34.0) |
| Rate Limiting | SlowAPI |
| Validation | Pydantic v2 |
| Migrations | Alembic + custom `migrate_database_schema()` |
| Containerization | Docker (multi-stage build) |

### Frontend
| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| State Management | Riverpod 2.4.0 |
| Navigation | GoRouter 12.0.0 |
| HTTP Client | Dio 5.3.0 |
| Local Storage | Flutter Secure Storage + Shared Preferences + Hive |
| Charts | fl_chart 0.65.0 |
| Push Notifications | Firebase Cloud Messaging |
| PDF Generation | pdf 3.10.0 |
| Video Playback | video_player 2.8.0 |
| Security | flutter_jailbreak_detection + flutter_windowmanager |
| Connectivity | connectivity_plus + offline request queue |

---

## Architecture

```
shuttler/
├── Backend/                  # FastAPI monolith (Python)
│   └── main.py               # ~9200 lines — models, routes, utilities
│
├── Flutter_Frontend/
│   └── Badminton/lib/
│       ├── main.dart          # App entry point
│       ├── screens/           # 60+ role-based screens
│       ├── models/            # 23 Dart data models
│       ├── core/
│       │   ├── services/      # 35+ API service classes
│       │   ├── network/       # Offline queue, connectivity
│       │   ├── theme/         # AppTheme, neumorphic styles
│       │   └── constants/     # Colors, endpoints, dimensions
│       ├── providers/         # Riverpod state providers
│       └── routes/            # GoRouter configuration
│
├── docker-compose.yml         # PostgreSQL + Redis + App
├── .env.dev / .env.staging / .env.prod
└── PRODUCTION_READINESS_PLAN.md
```

**Request flow:**
```
Flutter (Dio) → FastAPI (JWT middleware) → SQLAlchemy → PostgreSQL
                                         ↓
                                    Redis Cache
                                         ↓
                              Firebase / SendGrid (async)
```

---

## Features

### Authentication & Security
- JWT access + refresh token pair with automatic rotation
- Refresh token revocation on logout (`RevokedTokenDB`)
- Per-user `jwt_invalidated_at` — password change invalidates all sessions
- Multi-session tracking with device info (`ActiveSessionDB`)
- Login audit trail (`LoginHistoryDB`)
- Rate limiting on sensitive endpoints
- Jailbreak / root detection on device (Flutter)
- Screenshot / screen recording prevention (Flutter)
- Input validation: email format, phone format, name length, address length
- Magic byte verification on image uploads (JPEG / PNG / WebP)
- HTML sanitization on announcements and notifications

### Batch Management
- Create and manage training batches within sessions (seasons)
- Assign multiple coaches per batch
- Add / remove students from batches
- Activate / deactivate / permanently delete batches
- Batch capacity control (visible to owners only)

### Fee & Payment Tracking
- Batch-level fee configuration
- Payment status: `paid` / `partial` / `unpaid` / `overdue`
- Supported methods: Cash, Card
- Payment history with per-record deletion
- Razorpay online payment integration
- Daily cron at 09:00 to notify students with overdue fees
- Partial payment badge and filtering across all role portals

### Attendance
- Mark student and coach attendance per batch per date
- Bulk attendance recording
- Historical attendance view per student and per batch
- Date-based and coach-based attendance queries

### Performance & BMI
- Record and update student performance metrics by coach
- BMI history tracking with trend view
- Coach completion status (which students still need entries)
- Push notifications on new performance / BMI entries

### Reports
- Session-wise report generation
- Report history persistence (`ReportHistoryDB`)
- PDF export from Flutter

### Notifications
- **In-app notification center** with read / unread state
- **FCM push notifications** (Firebase Admin SDK)
  - Triggered on: performance entry, BMI record, fee payment, overdue fees (daily cron)
- **Notification preferences** — per-user on/off toggle per category
- Graceful no-op when `FIREBASE_SERVICE_ACCOUNT_PATH` is not configured

### Content & Communication
- Announcements for coaches / students / all with HTML sanitization
- Training video upload (coach), streaming, and role-based access control
- Calendar events (holidays, tournaments, custom)
- Enquiry / lead management (owner)

### Administrative
- Coach and student invitation flows (token-based)
- Registration request workflows (approve / reject)
- Student deactivation and rejoin request handling
- Ownership transfer
- Leave request management (coach submits, owner reviews, modification round-trip)
- Audit log (`AuditLogDB`)
- Analytics dashboard (owner): storage, coach analytics, academy-wide stats

### Offline Support (Flutter)
- Connectivity detection via `connectivity_plus`
- Offline request queue — operations buffered and replayed on reconnect
- Local Hive cache for key data

---

## Project Structure

### Backend (`Backend/main.py`)

The backend is a single monolithic FastAPI file containing:
- **30 SQLAlchemy ORM models** (DB tables)
- **120+ REST API endpoints**
- JWT utilities, middleware, and security helpers
- Background task scheduler (APScheduler)
- Firebase and SendGrid integrations

### Flutter Screens

**Authentication:** Login, Role Selection, Signup, Forgot Password, Registration Pending

**Student (16 screens):** Home, Dashboard, Batches, Attendance, Fees, BMI, Performance, Schedule, Tournaments, Videos, Announcements, Settings, Profile, Profile Completion, More, Help

**Coach (20 screens):** Home, Dashboard, Batches, Students, Attendance, Performance, Salary, Schedule, Reports, Announcements, Video Management, Leave Requests, Calendar, Settings, Profile, Academy Info, More, Help, Registration Pending

**Owner (25+ screens):** Home, Dashboard, Batches, Coaches, Students, Student Profiles, Attendance, Fees, Coach Salaries, BMI Tracking, Performance, Reports, Sessions, Calendar, Announcements, Notifications, Requests, Owner Management, Academy Details, Academy Setup, Videos, Settings, Profile, More, Help, Privacy & Terms

---

## Getting Started

### Prerequisites

- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- Flutter SDK 3.x
- Docker & Docker Compose (optional)
- Firebase project with FCM enabled (optional)

---

### Backend Setup

```bash
cd Backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env — see Environment Variables section below

# Start the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`.
Interactive docs: `http://localhost:8000/docs`

On first startup, `Base.metadata.create_all()` creates all tables and `migrate_database_schema()` applies any missing column migrations automatically.

---

### Flutter Setup

```bash
cd Flutter_Frontend/Badminton

# Install dependencies
flutter pub get

# Configure the backend URL
# Edit lib/core/constants/api_endpoints.dart
# Set BASE_URL to your backend address

# Run on device or emulator
flutter run
```

For push notifications, place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the appropriate platform directories.

---

### Docker Setup

```bash
# Start all services (PostgreSQL, Redis, FastAPI backend)
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

The stack exposes:
- Backend API: `http://localhost:8000`
- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`

---

## Environment Variables

Create `Backend/.env` based on `.env.example`:

```env
# Database
DATABASE_URL=postgresql://shuttler:secret@localhost:5432/shuttler

# JWT
SECRET_KEY=your-256-bit-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=30

# Redis
REDIS_URL=redis://localhost:6379/0

# Firebase (push notifications — optional)
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/serviceAccountKey.json

# SendGrid (transactional email — optional)
SENDGRID_API_KEY=SG.xxxxx
SENDGRID_FROM_EMAIL=noreply@youracademy.com

# Razorpay (payments — optional)
RAZORPAY_KEY_ID=rzp_xxx
RAZORPAY_KEY_SECRET=xxxxx

# S3 / R2 (file storage — optional, falls back to local uploads/)
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_S3_BUCKET=shuttler-uploads
AWS_REGION=ap-south-1

# App
ENVIRONMENT=development   # development | staging | production
UPLOAD_DIR=uploads
```

---

## API Reference

Full interactive documentation is available at `/docs` (Swagger UI) and `/redoc`.

### Key Endpoint Groups

| Group | Base Path | Description |
|-------|-----------|-------------|
| Auth | `/auth/*` | Login, logout, refresh, change password |
| Owners | `/owners/*` | Owner CRUD |
| Coaches | `/coaches/*` | Coach CRUD, invitations |
| Students | `/students/*` | Student CRUD, deactivation, rejoin |
| Batches | `/batches/*` | Batch management, student assignment |
| Sessions | `/sessions/*` | Training season management |
| Attendance | `/attendance/*`, `/coach-attendance/*` | Attendance tracking |
| Fees | `/fees/*` | Fee configuration and payment recording |
| Performance | `/performance/*` | Performance metrics |
| BMI | `/bmi-records/*` | BMI tracking |
| Notifications | `/api/notifications/*` | In-app notifications + preferences |
| Announcements | `/api/announcements/*` | Announcements |
| Reports | `/api/reports/*` | Session-wise report generation |
| Calendar | `/api/calendar-events/*` | Events and holidays |
| Videos | `/video-resources/*` | Training video management |
| Leave | `/leave-requests/*` | Coach leave management |
| Analytics | `/analytics/*` | Owner dashboard analytics |
| Health | `/health`, `/health/db`, `/health/redis` | Service health checks |

### Authentication

All endpoints (except `/auth/login`, `/health`, and public registration routes) require a Bearer token:

```
Authorization: Bearer <access_token>
```

**Login:**
```http
POST /auth/login
Content-Type: application/json

{
  "email": "owner@academy.com",
  "password": "SecurePass123!",
  "user_type": "owner"
}
```

**Response:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "user": { "id": 1, "name": "...", "email": "..." }
}
```

**Refresh:**
```http
POST /auth/refresh
Content-Type: application/json

{ "refresh_token": "eyJ..." }
```

---

## Database Schema

The application uses **30 PostgreSQL tables**:

**Auth & Users:** `coaches`, `students`, `owners`, `active_sessions`, `password_reset_tokens`, `revoked_tokens`, `login_history`

**Core:** `sessions`, `batches`, `batch_students`, `batch_coaches`

**Financial:** `fees`, `fee_payments`, `coach_salaries`

**Operations:** `attendance`, `coach_attendance`, `performance`, `bmi_records`

**Content:** `announcements`, `notifications`, `notification_preferences`, `calendar_events`, `video_resources`, `video_targets`

**Administrative:** `enquiries`, `schedules`, `tournaments`, `leave_requests`, `student_registration_requests`, `coach_registration_requests`, `invitations`, `coach_invitations`, `report_history`, `audit_logs`, `archive_records`

Tables are auto-created on startup. Missing columns on existing tables are added by `migrate_database_schema()` without data loss.

---

## Security

### Implemented (Phase A — Complete)

- **A1** — JWT auth with refresh token rotation and per-user invalidation
- **A2** — Password complexity enforcement (min 8 chars, upper, lower, digit, special)
- **A3** — Rate limiting on login and sensitive endpoints (SlowAPI)
- **A4** — HTTPS enforcement headers
- **A5** — SQL injection prevention via SQLAlchemy parameterized queries
- **A6** — CORS configured per environment
- **A7** — Input validation — email, phone, name, address format and length
- **A8** — HTML sanitization on user-generated content (announcements, notifications)
- **A9** — Image upload magic byte verification (JPEG / PNG / WebP only)
- **A10** — Video upload path traversal prevention + UUID-based filenames
- **A11** — JWT middleware blocks all unauthenticated requests to protected routes
- **A12** — Pydantic field validators on all create/update models
- **A13** — Login audit trail (`LoginHistoryDB`)
- **A14** — Multi-session management with device tracking
- **A15** — Jailbreak / root detection (Flutter)
- **A16** — Screen capture prevention (Flutter, `flutter_windowmanager`)

### File Upload Security

- Images: JPEG, PNG, WebP only (magic byte verified); max 5 MB; UUID-renamed
- Videos: max 500 MB; path traversal sanitized; UUID-renamed

---

## Push Notifications

FCM push notifications are sent for:

| Event | Recipient |
|-------|-----------|
| New performance entry | Student |
| Performance updated | Student |
| New BMI record | Student |
| Fee payment recorded | Student |
| Overdue fee reminder | Student (daily cron, 09:00) |

**Setup:**
1. Create a Firebase project and enable FCM
2. Download the service account JSON key
3. Set `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`

If the env var is absent, the app runs normally — push notifications are silently skipped.

**Notification Preferences:** Each user can toggle notification categories on/off via `GET/PUT /api/notifications/preferences`. Preferences are respected before creating in-app notifications and sending FCM messages.

---

## File Uploads

| Endpoint | Max Size | Allowed Types | Storage |
|----------|----------|---------------|---------|
| `POST /api/upload/image` | 5 MB | JPEG, PNG, WebP | Local `uploads/` or S3/R2 |
| `POST /upload` | 5 MB | JPEG, PNG, WebP | Local `uploads/` or S3/R2 |
| `POST /video-resources/upload` | 500 MB | Any video | Local `uploads/` or S3/R2 |

All uploaded files are renamed to a UUID before storage. The original filename is never used on disk.

---

## Running Tests

```bash
cd Backend

# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=. --cov-report=html
```

---

## Deployment

### Production Checklist

See [PRODUCTION_READINESS_PLAN.md](PRODUCTION_READINESS_PLAN.md) for the full checklist.

**Key steps:**

1. **Environment** — Use `.env.prod`; never commit secrets
2. **Database** — Use a managed PostgreSQL instance; enable connection pooling (PgBouncer)
3. **Redis** — Use managed Redis for caching and session data
4. **Reverse Proxy** — Nginx in front of uvicorn; TLS via Let's Encrypt
5. **Process Manager** — Gunicorn + uvicorn workers, or Docker with restart policies
6. **Object Storage** — Configure S3 / R2 for file uploads (set `AWS_*` env vars)
7. **Firebase** — Set `FIREBASE_SERVICE_ACCOUNT_PATH` for push notifications
8. **Email** — Set `SENDGRID_API_KEY` for transactional emails
9. **Monitoring** — Enable health checks (`/health`, `/health/db`, `/health/redis`)
10. **Backups** — Automated PostgreSQL backups; test restore procedure

### Docker Production

```bash
# Build and start
docker-compose -f docker-compose.yml up -d --build

# Scale backend workers
docker-compose up -d --scale backend=3
```

### Flutter Release Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## Roadmap

### Phase B — Core Features (Sprint 2)
- [x] B1 — Multiple coach assignment per batch
- [x] B2 — Partial payment status
- [x] B3 — Payment method standardization (Cash / Card)
- [x] B4 — Session-wise reports
- [x] B5 — FCM push notifications
- [x] B6 — In-app notification center
- [x] B7 — Notification preferences
- [ ] B8 — Performance entry completion status (Coach portal)
- [ ] B10 — Database table cleanup
- [ ] B11 — Transactional email service
- [ ] B12 — Payment gateway integration (Razorpay)

### Phase C — Scale & Polish
- [ ] C7 — S3 / R2 production file storage
- [ ] C8 — Redis caching layer
- [ ] C9 — Full Alembic migration pipeline
- [ ] C10 — Comprehensive test coverage

---

## License

This project is proprietary. All rights reserved.

---

*Built with FastAPI, Flutter, and PostgreSQL.*
