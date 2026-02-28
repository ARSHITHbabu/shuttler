from fastapi.testclient import TestClient

def test_read_main(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_login_invalid(client):
    response = client.post(
        "/auth/login",
        json={"email": "nonexistent@example.com", "password": "password"},
    )
    assert response.status_code == 401
    assert "Invalid email or password" in response.json()["message"]
