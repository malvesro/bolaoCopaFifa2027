from fastapi.testclient import TestClient

from app.bootstrap.main import app
from app.modules.identity import local_admin

client = TestClient(app)


def setup_function() -> None:
    local_admin._sessions.clear()


def test_local_admin_login_rejects_missing_password_configuration(monkeypatch) -> None:
    monkeypatch.setenv("ENVIRONMENT", "development")
    monkeypatch.delenv("LOCAL_ADMIN_PASSWORD", raising=False)

    response = client.post("/admin/session", json={"username": "admin", "password": "anything"})

    assert response.status_code == 401
    assert not local_admin._sessions


def test_local_admin_login_sets_httponly_cookie(monkeypatch) -> None:
    monkeypatch.setenv("ENVIRONMENT", "development")
    monkeypatch.setenv("LOCAL_ADMIN_PASSWORD", "local-test-password")

    response = client.post("/admin/session", json={"username": "admin", "password": "local-test-password"})

    assert response.status_code == 204
    assert response.cookies.get("bolao_admin_session")
    assert "httponly" in response.headers["set-cookie"].lower()


def test_local_admin_login_rejects_invalid_credentials(monkeypatch) -> None:
    monkeypatch.setenv("ENVIRONMENT", "development")
    monkeypatch.setenv("LOCAL_ADMIN_PASSWORD", "local-test-password")

    response = client.post("/admin/session", json={"username": "admin", "password": "wrong"})

    assert response.status_code == 401
    assert not local_admin._sessions


def test_local_admin_login_is_disabled_outside_development(monkeypatch) -> None:
    monkeypatch.setenv("ENVIRONMENT", "production")
    monkeypatch.setenv("LOCAL_ADMIN_PASSWORD", "local-test-password")

    response = client.post("/admin/session", json={"username": "admin", "password": "local-test-password"})

    assert response.status_code == 404
    assert not local_admin._sessions


def test_session_endpoints_are_disabled_outside_development(monkeypatch) -> None:
    monkeypatch.setenv("ENVIRONMENT", "production")
    monkeypatch.setenv("LOCAL_ADMIN_PASSWORD", "local-test-password")

    assert client.get("/admin/session").status_code == 404
    assert client.delete("/admin/session").status_code == 404


def test_session_requires_auth_and_logout_revokes_it(monkeypatch) -> None:
    monkeypatch.setenv("ENVIRONMENT", "development")
    monkeypatch.setenv("LOCAL_ADMIN_PASSWORD", "local-test-password")
    assert client.get("/admin/session").status_code == 401

    login_response = client.post("/admin/session", json={"username": "admin", "password": "local-test-password"})
    assert login_response.status_code == 204
    assert client.get("/admin/session").json() == {"username": "admin"}

    logout_response = client.delete("/admin/session")
    assert logout_response.status_code == 204
    assert client.get("/admin/session").status_code == 401
