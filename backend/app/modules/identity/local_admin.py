import secrets
from hmac import compare_digest
from os import getenv

from fastapi import APIRouter, Cookie, HTTPException, Response, status
from pydantic import BaseModel

router = APIRouter(prefix="/admin", tags=["admin-auth"])

_ADMIN_USERNAME = "admin"
_SESSION_COOKIE = "bolao_admin_session"
_sessions: set[str] = set()


class AdminLoginRequest(BaseModel):
    username: str
    password: str


def _development_enabled() -> bool:
    from os import getenv

    return getenv("ENVIRONMENT") == "development"


def _is_admin_session(session_id: str | None) -> bool:
    return bool(session_id and session_id in _sessions)


@router.post("/session", status_code=status.HTTP_204_NO_CONTENT)
def login(payload: AdminLoginRequest, response: Response) -> None:
    if not _development_enabled():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")

    local_admin_password = getenv("LOCAL_ADMIN_PASSWORD", "")
    username_valid = compare_digest(payload.username, _ADMIN_USERNAME)
    password_valid = bool(local_admin_password) and compare_digest(payload.password, local_admin_password)
    if not (username_valid and password_valid):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciais inválidas")

    session_id = secrets.token_urlsafe(32)
    _sessions.add(session_id)
    response.set_cookie(
        key=_SESSION_COOKIE,
        value=session_id,
        httponly=True,
        secure=False,
        samesite="strict",
        path="/",
    )


@router.get("/session")
def current_session(
    session_id: str | None = Cookie(default=None, alias=_SESSION_COOKIE),
) -> dict[str, str]:
    if not _development_enabled():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")
    if not _is_admin_session(session_id):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Autenticação necessária")
    return {"username": _ADMIN_USERNAME}


@router.delete("/session", status_code=status.HTTP_204_NO_CONTENT)
def logout(
    response: Response,
    session_id: str | None = Cookie(default=None, alias=_SESSION_COOKIE),
) -> None:
    if not _development_enabled():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")
    if session_id:
        _sessions.discard(session_id)
    response.delete_cookie(key=_SESSION_COOKIE, path="/", httponly=True, samesite="strict")
