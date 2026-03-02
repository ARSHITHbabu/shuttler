
import sys
import os
import random
import datetime
from datetime import timedelta
import secrets

# Ensure we can import from main.py
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from main import (
    SessionLocal, engine, hash_password,
    OwnerDB, CoachDB, StudentDB, SessionDB, BatchDB, 
    BatchStudentDB, BatchCoachDB, FeeDB, FeePaymentDB, 
    AttendanceDB, PerformanceDB, ScheduleDB
)

# Setup data pools
FIRST_NAMES = ["James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda", "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Charles", "Karen"]
LAST_NAMES = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin"]
SKILLS = ["Serve", "Smash", "Footwork", "Defense", "Stamina", "Drop Shot", "Net Play"]
BATCH_TYPES = ["Morning", "Evening", "Weekend", "Elite", "Beginner"]
LOCATIONS = ["Court A", "Court B", "Main Hall", "Annex", "Center Court"]

def get_random_date(start_date_str, end_date_str):
    start = datetime.datetime.strptime(start_date_str, "%Y-%m-%d")
    end = datetime.datetime.strptime(end_date_str, "%Y-%m-%d")
    delta = end - start
    random_days = random.randrange(delta.days + 1)
    return (start + timedelta(days=random_days)).strftime("%Y-%m-%d")

def generate_schedule_dates(start_date_str, end_date_str, days_of_week=[0, 2, 4]): # Mon, Wed, Fri
    start = datetime.datetime.strptime(start_date_str, "%Y-%m-%d")
    end = datetime.datetime.strptime(end_date_str, "%Y-%m-%d")
    dates = []
    current = start
    while current <= end:
        if current.weekday() in days_of_week:
            dates.append(current.strftime("%Y-%m-%d"))
        current += timedelta(days=1)
    return dates

def clean_database(session):
    print("🧹 Cleaning existing data...")
    # List of tables to truncate (order matters for FKs)
    tables = [
        "fee_payments", "fees", "performance", "attendance", "coach_attendance",
        "batch_students", "batch_coaches", "schedules", "batches", "sessions",
        "students", "coaches", "owners"
    ]
    for table in tables:
        try:
            session.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE"))
        except Exception as e:
            # Fallback for SQLite which doesn't support TRUNCATE
            session.execute(text(f"DELETE FROM {table}"))
    session.commit()
    print("✅ Database cleaned.")

def seed_comprehensive_data():
    db = SessionLocal()
    try:
        clean_database(db)

        print("\n🌱 Starting Comprehensive Seeding...")

        # 1. Create Owner
        owner = OwnerDB(
            name="Super Owner",
            email="owner@example.com",
            phone="9999999999",
            password=hash_password("password123"),
            role="owner",
            academy_name="Pro Shuttle Academy",
            status="active"
        )
        db.add(owner)
        db.commit()
        print("✅ Created Owner")

        # 2. Create Coaches (15 coaches)
        coaches = []
        for i in range(15):
            fname = random.choice(FIRST_NAMES)
            lname = random.choice(LAST_NAMES)
            coach = CoachDB(
                name=f"Coach {fname} {lname}",
                email=f"coach{i+1}@example.com",
                phone=f"98000{i:05d}",
                password=hash_password("password123"),
                specialization=random.choice(["Singles", "Doubles", "Physical Training"]),
                experience_years=random.randint(1, 15),
                status="active",
                monthly_salary=random.randint(20000, 50000)
            )
            db.add(coach)
            coaches.append(coach)
        db.commit()
        # Refresh to get IDs
        for c in coaches: db.refresh(c)
        print(f"✅ Created {len(coaches)} Coaches")

        # 3. Create Students (Pool of 100 students)
        students = []
        for i in range(100):
            fname = random.choice(FIRST_NAMES)
            lname = random.choice(LAST_NAMES)
            student = StudentDB(
                name=f"{fname} {lname}",
                email=f"student{i+1}@example.com",
                phone=f"97000{i:05d}",
                password=hash_password("password123"),
                guardian_name=f"Parent of {fname}",
                guardian_phone=f"96000{i:05d}",
                date_of_birth=get_random_date("2005-01-01", "2015-12-31"),
                address=f"Street {i}, City",
                status="active",
                t_shirt_size=random.choice(["S", "M", "L"]),
                blood_group=random.choice(["A+", "B+", "O+", "AB+"])
            )
            db.add(student)
            students.append(student)
        db.commit()
        for s in students: db.refresh(s)
        print(f"✅ Created {len(students)} Students")

        # 4. Define Sessions (History 2025 -> Present 2026)
        sessions_data = [
            {"name": "Winter 2025", "start": "2025-01-01", "end": "2025-03-31"},
            {"name": "Summer 2025", "start": "2025-04-01", "end": "2025-06-30"},
            {"name": "Fall 2025",   "start": "2025-07-01", "end": "2025-09-30"},
            {"name": "Winter 2026", "start": "2026-01-01", "end": "2026-03-31"} # Current/Future
        ]

        total_batches = 0
        total_attendance = 0
        total_performance = 0

        for sess_data in sessions_data:
            session_obj = SessionDB(
                name=sess_data["name"],
                start_date=sess_data["start"],
                end_date=sess_data["end"],
                status="active" if "2026" in sess_data["name"] else "completed"
            )
            db.add(session_obj)
            db.commit()
            db.refresh(session_obj)

            # Create 5-8 batches per session
            num_batches = random.randint(5, 8)
            
            # Shuffle students to assign randomly for this session
            # We'll pick a subset of students for each session to simulate turnover
            session_students = random.sample(students, k=random.randint(40, 80))
            student_idx = 0

            for b_idx in range(num_batches):
                batch_fee = random.choice([1500, 2000, 2500, 3000, 5000])
                batch_type = random.choice(BATCH_TYPES)
                
                batch = BatchDB(
                    batch_name=f"{batch_type} Batch {b_idx + 1} - {session_obj.name}",
                    capacity=20,
                    fees=str(batch_fee),
                    start_date=sess_data["start"],
                    timing=f"{random.randint(6, 18)}:00 - {random.randint(7, 19)}:00",
                    period=f"{batch_type}",
                    location=random.choice(LOCATIONS),
                    created_by="Owner",
                    session_id=session_obj.id,
                    assigned_coach_id=None # Using batch_coaches table
                )
                db.add(batch)
                db.commit()
                db.refresh(batch)
                
                # Assign Coaches (1 to 3 random coaches)
                batch_coaches = random.sample(coaches, k=random.randint(1, 3))
                assigned_coach_names = []
                for coach in batch_coaches:
                    bc = BatchCoachDB(batch_id=batch.id, coach_id=coach.id)
                    db.add(bc)
                    assigned_coach_names.append(coach.name)
                
                # Update legacy field for compatibility if needed, using first coach
                batch.assigned_coach_id = batch_coaches[0].id
                batch.assigned_coach_name = batch_coaches[0].name
                db.commit()

                # Assign Students (Random chunk from session pool)
                # Ensure batches have different sizes (2, 5, 10, etc)
                num_students_in_batch = random.randint(2, 12)
                
                # Check if we have enough students left in our shuffled list
                if student_idx + num_students_in_batch > len(session_students):
                    student_idx = 0 # Reset/Recycle if we run out
                    random.shuffle(session_students)
                
                batch_student_objs = session_students[student_idx : student_idx + num_students_in_batch]
                student_idx += num_students_in_batch

                # Generate Batch Schedule (M/W/F)
                schedule_dates = generate_schedule_dates(sess_data["start"], sess_data["end"])

                for student in batch_student_objs:
                    # 1. Link Student to Batch
                    link = BatchStudentDB(batch_id=batch.id, student_id=student.id, status="active")
                    db.add(link)

                    # 2. Add Fee Record
                    fee_status = random.choices(["paid", "pending", "partial"], weights=[70, 20, 10], k=1)[0]
                    fee = FeeDB(
                        student_id=student.id,
                        batch_id=batch.id,
                        amount=float(batch_fee),
                        due_date=sess_data["start"], # Due at start of session
                        status=fee_status if fee_status != "partial" else "pending", # Logic sets status based on payments
                        payee_student_id=student.id
                    )
                    db.add(fee)
                    db.commit()
                    db.refresh(fee)

                    # 3. Add Payments
                    if fee_status == "paid":
                        payment = FeePaymentDB(
                            fee_id=fee.id,
                            amount=float(batch_fee),
                            paid_date=get_random_date(sess_data["start"], sess_data["end"]),
                            payment_method=random.choice(["Cash", "UPI", "Bank Transfer"]),
                            collected_by="Owner"
                        )
                        db.add(payment)
                    elif fee_status == "partial":
                        partial_amt = round(float(batch_fee) / 2, 2)
                        payment = FeePaymentDB(
                            fee_id=fee.id,
                            amount=partial_amt,
                            paid_date=get_random_date(sess_data["start"], sess_data["end"]),
                            payment_method=random.choice(["Cash", "UPI"]),
                            collected_by="Owner"
                        )
                        db.add(payment)

                    # 4. Add Attendance (Random 80% attendance rate)
                    for date in schedule_dates:
                        # Only mark attendance for past dates or today
                        if date > datetime.datetime.now().strftime("%Y-%m-%d"):
                            continue
                            
                        is_present = random.random() < 0.8
                        att = AttendanceDB(
                            batch_id=batch.id,
                            student_id=student.id,
                            date=date,
                            status="present" if is_present else "absent",
                            marked_by=random.choice(batch_coaches).name,
                            remarks="Good session" if is_present and random.random() > 0.8 else None
                        )
                        db.add(att)
                        total_attendance += 1
                    
                    # 5. Add Performance (Random weekly/monthly checks)
                    # Generate ~3-5 performance entries per student per session
                    for _ in range(random.randint(3, 5)):
                        perf_date = get_random_date(sess_data["start"], sess_data["end"])
                        if perf_date > datetime.datetime.now().strftime("%Y-%m-%d"):
                            continue

                        recorder = random.choice(batch_coaches)
                        perf = PerformanceDB(
                            student_id=student.id,
                            batch_id=batch.id,
                            date=perf_date,
                            skill=random.choice(SKILLS),
                            rating=random.randint(1, 5),
                            comments=random.choice(["Improving", "Needs work", "Excellent", "Good progress", "Inconsistent"]),
                            recorded_by=recorder.name
                        )
                        db.add(perf)
                        total_performance += 1

                total_batches += 1
                db.commit()

        # 5. Set some students to Inactive/Deleted (Simulating dropouts)
        print("Set student statuses (active/inactive/deleted)...")
        all_students = db.query(StudentDB).all()
        for s in all_students:
            rand_val = random.random()
            if rand_val < 0.10: # 10% Inactive
                s.status = "inactive"
            elif rand_val < 0.15: # 5% Deleted
                s.status = "deleted"
            # remaining 85% Active
        db.commit()
        
        print("\n" + "="*50)
        print("✅ COMPREHENSIVE SEEDING COMPLETE")
        print("="*50)
        print(f"Summary:")
        print(f"- 1 Owner (owner@example.com)")
        print(f"- {len(coaches)} Coaches")
        print(f"- {len(students)} Students")
        print(f"- {len(sessions_data)} Sessions (2025-2026)")
        print(f"- {total_batches} Batches created")
        print(f"- {total_attendance} Attendance records")
        print(f"- {total_performance} Performance records")
        print(f"- Fees and payments populated randomly")
        print("\nLogin Credentials:")
        print("Owner: owner@example.com / password123")
        print("Any Student: studentX@example.com / password123")
        print("Any Coach: coachX@example.com / password123")

    except Exception as e:
        print(f"❌ Error during seeding: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_comprehensive_data()
