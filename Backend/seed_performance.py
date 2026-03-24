"""
Seed random performance data for all existing students.
Run from Backend/ directory: python seed_performance.py
"""
import random
from datetime import date, timedelta
from dotenv import load_dotenv
import os
import sys

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL environment variable is not set. Check your .env file.")

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
db = Session()

def main():
    # 1. Get all students with their batch enrollments
    rows = db.execute(text("""
        SELECT s.id AS student_id, b.id AS batch_id
        FROM students s
        JOIN batch_students bs ON bs.student_id = s.id
        JOIN batches b ON b.id = bs.batch_id
        WHERE 1=1
    """)).fetchall()

    if not rows:
        print("No active students with batch enrollments found.")
        sys.exit(0)

    print(f"Found {len(rows)} student-batch pairs.")

    # 2. Get active skills
    skill_rows = db.execute(text(
        "SELECT name FROM performance_skills WHERE is_active = true"
    )).fetchall()
    skills = [r[0] for r in skill_rows]

    if not skills:
        # Fall back to default skills if none configured
        skills = ["Serve", "Smash", "Footwork", "Defense", "Stamina"]
        print(f"No skills in DB, using defaults: {skills}")
    else:
        print(f"Skills: {skills}")

    # 3. Generate dates: past 8 weeks, ~2 sessions/week (Mon & Thu)
    today = date.today()
    session_dates = []
    for weeks_back in range(8, 0, -1):
        monday = today - timedelta(days=today.weekday()) - timedelta(weeks=weeks_back - 1)
        thursday = monday + timedelta(days=3)
        if monday <= today:
            session_dates.append(monday)
        if thursday <= today:
            session_dates.append(thursday)

    print(f"Generating records for {len(session_dates)} session dates.")

    # 4. Insert performance records
    inserted = 0
    for student_id, batch_id in rows:
        # Each student attends ~75% of sessions
        attended = random.sample(session_dates, k=int(len(session_dates) * 0.75))
        attended.sort()

        for session_date in attended:
            date_str = session_date.isoformat()

            # Check for existing record for this student/batch/date
            existing = db.execute(text("""
                SELECT id FROM performance
                WHERE student_id = :sid AND batch_id = :bid AND date = :d
                LIMIT 1
            """), {"sid": student_id, "bid": batch_id, "d": date_str}).fetchone()
            if existing:
                continue  # Skip — already seeded

            first_skill = True
            for skill in skills:
                rating = random.randint(2, 5)
                comment = None
                if first_skill and random.random() < 0.3:
                    comment = random.choice([
                        "Good improvement this session",
                        "Needs more practice",
                        "Excellent footwork shown",
                        "Great attitude and effort",
                        "Focus on consistency",
                    ])
                    first_skill = False

                db.execute(text("""
                    INSERT INTO performance (student_id, batch_id, date, skill, rating, comments, recorded_by)
                    VALUES (:sid, :bid, :d, :skill, :rating, :comments, :recorded_by)
                """), {
                    "sid": student_id,
                    "bid": batch_id,
                    "d": date_str,
                    "skill": skill,
                    "rating": rating,
                    "comments": comment,
                    "recorded_by": "coach",
                })
                inserted += 1

    db.commit()
    print(f"\nDone! Inserted {inserted} performance skill rows.")
    print(f"({inserted // len(skills) if skills else inserted} performance entries across all students)")

if __name__ == "__main__":
    try:
        main()
    finally:
        db.close()