import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from main import app, Base, get_db

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="module")
def db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="module")
def seeded_db(db):
    from main import OwnerDB, CoachDB, StudentDB, SessionDB, BatchDB, BatchStudentDB, BatchCoachDB, hash_password
    
    # 1. Create Owner
    owner = OwnerDB(
        name="Test Owner",
        email="owner@test.com",
        phone="1234567890",
        password=hash_password("password123"),
        role="owner",
        status="active"
    )
    db.add(owner)
    db.flush() # Get IDs
    
    # 2. Create Coach
    coach = CoachDB(
        name="Test Coach",
        email="coach@test.com",
        phone="1122334455",
        password=hash_password("password123"),
        status="active"
    )
    db.add(coach)
    db.flush()
    
    # 3. Create Session
    session = SessionDB(
        name="Test Session",
        start_date="2024-01-01",
        end_date="2024-12-31",
        status="active"
    )
    db.add(session)
    db.flush()
    
    # 4. Create Batch (assigned to Coach)
    batch = BatchDB(
        batch_name="Morning Batch",
        capacity=20,
        fees="1000",
        start_date="2024-01-01",
        timing="06:00 AM",
        period="Monthly",
        created_by="owner",
        assigned_coach_id=coach.id,
        session_id=session.id,
        status="active"
    )
    db.add(batch)
    db.flush()
    
    # Link coach via BatchCoachDB too
    bc = BatchCoachDB(batch_id=batch.id, coach_id=coach.id)
    db.add(bc)
    
    # 5. Create Students
    # Student 1: Enrolled in Morning Batch
    student1 = StudentDB(
        name="Student Enrolled",
        email="student1@test.com",
        phone="2233445566",
        password=hash_password("password123"),
        guardian_name="Guardian 1",
        status="active"
    )
    db.add(student1)
    db.flush()
    
    bs1 = BatchStudentDB(batch_id=batch.id, student_id=student1.id, status="approved")
    db.add(bs1)
    
    # Student 2: NOT Enrolled in any batch
    student2 = StudentDB(
        name="Student Private",
        email="student2@test.com",
        phone="3344556677",
        password=hash_password("password123"),
        guardian_name="Guardian 2",
        status="active"
    )
    db.add(student2)
    
    db.commit()
    yield db

@pytest.fixture(scope="module")
def client(seeded_db):
    def override_get_db():
        try:
            yield seeded_db
        finally:
            pass
    from main import get_db
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
