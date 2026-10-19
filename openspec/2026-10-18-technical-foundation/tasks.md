# Tasks: Technical Foundation Setup

- [ ] Requisito / Decisão: Stack definida (Next.js/TypeScript, FastAPI/Python, PostgreSQL)
  - Tarefa Técnica: Criar estrutura de diretórios backend com Clean Architecture
  - Arquivo / Componente: backend/src/domain, backend/src/application, backend/src/infrastructure, backend/src/presentation
  - Verificação / Teste: Verificar existência de diretórios e separação de responsabilidades

- [ ] Requisito / Decisão: Suporte a Windows 11 WSL 2/Ubuntu e Linux
  - Tarefa Técnica: Configurar docker-compose.yml com serviços backend, frontend, postgres
  - Arquivo / Componente: docker-compose.yml
  - Verificação / Teste: docker compose config --quiet

- [ ] Requisito / Decisão: Health checks para serviços
  - Tarefa Técnica: Adicionar health checks em docker-compose.yml
  - Arquivo / Componente: docker-compose.yml
  - Verificação / Teste: docker compose up --wait

- [ ] Requisito / Decisão: Telemetria de migrações
  - Tarefa Técnica: Inicializar Alembic scaffold
  - Arquivo / Componente: backend/alembic.ini, backend/alembic/versions/
  - Verificação / Teste: alembic --version, alembic revision --autogenerate

- [ ] Requisito / Decisão: Especificações técnicas PROD-01/TEC-01/PROD-07
  - Tarefa Técnica: Criar especificações iniciais em docs/architecture/decisoes-tecnicas/
  - Arquivo / Componente: docs/architecture/decisoes-tecnicas/PROD-01.md, TEC-01.md, PROD-07.md
  - Verificação / Teste: Verificar existência e conteúdo mínimo

- [ ] Requisito / Decisão: Isolamento de camadas Clean Architecture
  - Tarefa Técnica: Definir ports e adapters no backend
  - Arquivo / Componente: backend/src/application/ports/, backend/src/infrastructure/adapters/
  - Verificação / Teste: Verificar imports não violam direção de dependência

- [ ] Requisito / Decisão: Modelo de entrada/saída
  - Tarefa Técnica: Configurar Pydantic models base e FastAPI app
  - Arquivo / Componente: backend/src/presentation/main.py
  - Verificação / Teste: uvicorn run e teste de endpoint /health
