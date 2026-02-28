import pytest

@pytest.fixture
def owner_token(client):
    response = client.post(
        "/auth/login",
        json={"email": "owner@test.com", "password": "password123"}
    )
    return response.json()["access_token"]

@pytest.fixture
def coach_token(client):
    response = client.post(
        "/auth/login",
        json={"email": "coach@test.com", "password": "password123"}
    )
    return response.json()["access_token"]

@pytest.fixture
def student_token(client):
    response = client.post(
        "/auth/login",
        json={"email": "student1@test.com", "password": "password123"}
    )
    return response.json()["access_token"]

def test_owner_only_endpoint_as_owner(client, owner_token):
    # Only owners can create coaches
    response = client.post(
        "/coaches/",
        json={
            "name": "New Coach",
            "email": "newcoach@test.com",
            "phone": "9998887776",
            "password": "Password123"
        },
        headers={"Authorization": f"Bearer {owner_token}"}
    )
    assert response.status_code == 200

def test_owner_only_endpoint_as_coach(client, coach_token):
    response = client.post(
        "/coaches/",
        json={
            "name": "Another Coach",
            "email": "another@test.com",
            "phone": "9998887775",
            "password": "Password123"
        },
        headers={"Authorization": f"Bearer {coach_token}"}
    )
    # Coaches cannot create other coaches
    assert response.status_code == 403

def test_owner_only_endpoint_as_student(client, student_token):
    response = client.post(
        "/coaches/",
        json={
            "name": "Student Created Coach",
            "email": "student@test.com",
            "phone": "9998887774",
            "password": "Password123"
        },
        headers={"Authorization": f"Bearer {student_token}"}
    )
    assert response.status_code == 403

def test_coach_allowed_endpoint_as_coach(client, coach_token):
    # Coaches can get list of students (assuming student/ read-only)
    response = client.get(
        "/students/",
        headers={"Authorization": f"Bearer {coach_token}"}
    )
    assert response.status_code == 200

def test_protected_endpoint_without_token(client):
    response = client.get("/students/")
    assert response.status_code == 401
