import pytest

def test_owner_login(client):
    response = client.post(
        "/auth/login",
        json={"email": "owner@test.com", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["userType"] == "owner"
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["user"]["email"] == "owner@test.com"

def test_coach_login(client):
    response = client.post(
        "/auth/login",
        json={"email": "coach@test.com", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["userType"] == "coach"
    assert "access_token" in data

def test_student_login(client):
    response = client.post(
        "/auth/login",
        json={"email": "student1@test.com", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["userType"] == "student"

def test_invalid_login(client):
    response = client.post(
        "/auth/login",
        json={"email": "owner@test.com", "password": "wrongpassword"}
    )
    # The unified_login returns 401 via handle_failed_login
    assert response.status_code == 401

def test_logout(client):
    # First login to get token
    login_resp = client.post(
        "/auth/login",
        json={"email": "owner@test.com", "password": "password123"}
    )
    token = login_resp.json()["access_token"]
    refresh_token = login_resp.json()["refresh_token"]
    
    # Logout
    response = client.post(
        "/auth/logout",
        json={"refresh_token": refresh_token},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    
    # Try to use same token again
    response_again = client.get(
        "/auth/me",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response_again.status_code == 401
