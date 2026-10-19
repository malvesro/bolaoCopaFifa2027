# Design: Technical Foundation

## Arquitetura

Monólito modular com DDD pragmático. O backend FastAPI expõe a API, o frontend Next.js é a camada de apresentação e o PostgreSQL é o repositório de dados, todos orquestrados via Docker Compose. A direção de fatias verticais por caso de uso dentro dos módulos está aprovada no ADR-001; sua implementação não é escopo desta change e exige design específico.

## Estrutura existente (scaffold)

- `backend/app/bootstrap/main.py`: aplicação FastAPI com `/`, `/live` e `/ready`.
- `backend/app/modules/{identity,tournament,predictions,scoring,ranking,support,gamification}/`: apenas diretórios reservados (`.gitkeep`), sem código.
- `backend/app/shared/`, `backend/app/entrypoints/http/`, `backend/migrations/`, `backend/tests/`: reservados, sem código.
- `frontend/app/{layout,loading,not-found,page}.tsx`, `frontend/{features,components,lib,tests}/`.

## Healthchecks

Verificar e alinhar ao que o código expõe, sem presumir:

- backend: o Compose foi alinhado em 19/10/2026 à rota `/live` de `main.py` (antes chamava `/health/live`). `/ready` ainda não consulta o banco. Nada foi validado por execução.
- frontend: endpoint de health a definir (`/api/health` não existe).
- postgres: `pg_isready`.

Intervalos e tentativas: manter os valores já configurados em `docker-compose.yml`, revisando-os na implementação.

## Isolamento de dependências

Regra mínima: o domínio não importa FastAPI nem SQLAlchemy, e módulos não leem tabelas de outros módulos. A ferramenta de verificação (import-linter, Tach ou outra) é decisão pendente.

## Entrada e saída

- A API usa JSON. O prefixo `/api/v1` é proposta, não implementado.
- O frontend consome o backend por HTTP, sem segredos no código.
- Configuração por variáveis de ambiente (`.env.example`). ADR-001 aprova SQLAlchemy síncrono como ponto de partida; `DATABASE_URL`, driver e manifesto ainda precisam ser compatibilizados e validados antes da execução.
- Alembic para migrações em `backend/migrations/` (a inicializar).

## Convenções

- Python 3.11+ com FastAPI e Pydantic; versões a validar.
- TypeScript em modo estrito no Next.js.
- Docker Compose para orquestração local.
