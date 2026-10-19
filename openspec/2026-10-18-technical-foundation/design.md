# Design: Technical Foundation

## Architecture

Monolithic modular architecture with DDD pragmatic and Clean Architecture layers. Backend FastAPI serves as API layer, frontend Next.js as presentation layer. PostgreSQL as data store via Docker Compose.

## Healthchecks

Docker Compose services include health checks:

- backend: HTTP health endpoint at /health, interval 30s, timeout 10s, retries 3.
- frontend: HTTP health endpoint at /api/health, interval 30s, timeout 10s, retries 3.
- postgres: pg_isready command, interval 10s, timeout 5s, retries 3.

## Layer Isolation

Clean Architecture layers: domain, application, infrastructure, presentation. Dependencies flow inward. Domain has no external dependencies. Infrastructure implements ports defined by application layer.

## Input/Output Model

- Backend exposes REST endpoints under /api/v1, JSON request/response.
- Frontend communicates via fetch to backend API.
- Environment variables for configuration, no secrets in code.
- Alembic manages database migrations with versioned scripts.

## Conventions

- Python 3.11+ with FastAPI, Pydantic models.
- TypeScript Strict mode for Next.js.
- Docker Compose for local orchestration.
- Version control for all configuration files.
