import pytest

@pytest.fixture
def coach_token(client):
    response = client.post(
        "/auth/login",
        json={"email": "coach@test.com", "password": "password123"}
    )
    return response.json()["access_token"]

@pytest.fixture
def student1_token(client):
    response = client.post(
        "/auth/login",
        json={"email": "student1@test.com", "password": "password123"}
    )
    return response.json()["access_token"]

@pytest.fixture
def student2_token(client):
    response = client.post(
        "/auth/login",
        json={"email": "student2@test.com", "password": "password123"}
    )
    return response.json()["access_token"]

def test_coach_access_enrolled_student(client, coach_token):
    # Student 1 is in coach's batch
    response = client.get(
        "/students/1",
        headers={"Authorization": f"Bearer {coach_token}"}
    )
    assert response.status_code == 200

def test_coach_access_private_student_idor(client, coach_token):
    # Student 2 is NOT in coach's batch
    response = client.get(
        "/students/2",
        headers={"Authorization": f"Bearer {coach_token}"}
    )
    # The A15 IDOR protection should return 403
    assert response.status_code == 403

def test_student_access_self(client, student1_token):
    response = client.get(
        "/students/1",
        headers={"Authorization": f"Bearer {student1_token}"}
    )
    assert response.status_code == 200

def test_student_access_other_student_idor(client, student1_token):
    # Student 1 tries to access Student 2's data
    response = client.get(
        "/students/2",
        headers={"Authorization": f"Bearer {student1_token}"}
    )
    assert response.status_code == 403
