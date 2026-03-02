
import sys
import os
# Ensure we can import from main.py by adding current directory to sys.path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from main import SessionLocal, OwnerDB, CoachDB, StudentDB, hash_password

def seed_data():
    print("Initializing database session...")
    db = SessionLocal()
    try:
        print("Starting data seeding...")
        
        # 1. Create Owner
        print("\n--- Creating Owner ---")
        if db.query(OwnerDB).filter(OwnerDB.email == "owner@example.com").first():
             print("Owner 'owner@example.com' already exists.")
        else:
            owner = OwnerDB(
                name="Main Owner",
                email="owner@example.com",
                phone="9876543210",
                password=hash_password("password123"),
                role="owner",
                status="active"
            )
            db.add(owner)
            print("✅ Added Owner: owner@example.com / password123")
        
        # 2. Create 10 Coaches
        print("\n--- Creating Coaches ---")
        for i in range(1, 11):
            email = f"coach{i}@example.com"
            if not db.query(CoachDB).filter(CoachDB.email == email).first():
                coach = CoachDB(
                    name=f"Coach User {i}",
                    email=email,
                    phone=f"98765432{i:02d}",
                    password=hash_password("password123"),
                    specialization="Badminton",
                    experience_years=5,
                    status="active"
                )
                db.add(coach)
                print(f"✅ Added Coach: {email} / password123")
            else:
                print(f"Coach '{email}' already exists.")

        # 3. Create 10 Students
        print("\n--- Creating Students ---")
        for i in range(1, 11):
            email = f"student{i}@example.com"
            if not db.query(StudentDB).filter(StudentDB.email == email).first():
                student = StudentDB(
                    name=f"Student User {i}",
                    email=email,
                    phone=f"91234567{i:02d}",
                    password=hash_password("password123"),
                    guardian_name=f"Guardian {i}",
                    guardian_phone=f"99887766{i:02d}",
                    status="active",
                    date_of_birth="2010-01-01",
                    address=f"Address for Student {i}",
                    t_shirt_size="M",
                    blood_group="O+"
                )
                db.add(student)
                print(f"✅ Added Student: {email} / password123")
            else:
                print(f"Student '{email}' already exists.")
        
        db.commit()
        print("\n" + "="*50)
        print("SEEDING COMPLETED SUCCESSFULLY!")
        print("="*50)
        print("You can now login with:")
        print("Owner: owner@example.com / password123")
        print("Coach: coach1@example.com / password123")
        print("Student: student1@example.com / password123")
        
    except Exception as e:
        print(f"\n❌ Error seeding data: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
