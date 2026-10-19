# Tasks: Technical Foundation Setup

Convenção: [x] só após executar e registrar a verificação. Caminhos marcados "(a criar)" ainda não existem.

- [ ] Requisito / Decisão: Stack definida (Next.js/TypeScript, FastAPI/Python, PostgreSQL)
  - Tarefa Técnica: Manter o scaffold de módulos; a organização por fatias dentro dos módulos foi aprovada como direção no ADR-001, mas pertence a change específica
  - Arquivo / Componente: backend/app/modules/, backend/app/shared/, backend/app/bootstrap/, frontend/app/, frontend/features/
  - Verificação / Teste: find backend/app/modules -maxdepth 1 -mindepth 1 -type d, comparado com a tabela de módulos da §10 de docs/architecture/arquitetura-software.md

- [ ] Requisito / Decisão: Suporte a Windows 11 WSL 2/Ubuntu e Linux
  - Tarefa Técnica: Validar docker-compose.yml com serviços backend, frontend e postgres
  - Arquivo / Componente: docker-compose.yml
  - Verificação / Teste: docker compose config --quiet

- [ ] Requisito / Decisão: Health checks para serviços
  - Tarefa Técnica: Validar o healthcheck do backend (alinhado a /live em 19/10/2026, não validado por execução) e fazer /ready consultar o banco
  - Arquivo / Componente: docker-compose.yml, backend/app/bootstrap/main.py
  - Verificação / Teste: docker compose up --wait; com o banco parado, GET /ready deve responder erro (teste de integração a criar)

- [ ] Requisito / Decisão: Controle de versão do esquema de banco
  - Tarefa Técnica: Inicializar Alembic
  - Arquivo / Componente: backend/migrations/ (alembic.ini a criar)
  - Verificação / Teste: alembic --version e verificação da configuração de migração; autogeração somente após existirem modelos/metadata aprovados e banco acessível

- [ ] Requisito / Decisão: Especificações técnicas PROD-01/TEC-01/PROD-07
  - Tarefa Técnica: Manter as especificações técnicas e aguardar aprovação humana
  - Arquivo / Componente: docs/architecture/decisoes-tecnicas/PROD-01-corte-confiavel-palpites.md, docs/architecture/decisoes-tecnicas/TEC-01-PROD-07-autenticacao-admissao.md
  - Verificação / Teste: grep -n "para aprovação" nos dois arquivos de docs/architecture/decisoes-tecnicas/

- [ ] Requisito / Decisão: Isolamento de dependências entre módulos
  - Tarefa Técnica: Escolher e configurar a ferramenta de verificação de imports após decisão humana
  - Arquivo / Componente: backend/pyproject.toml (a alterar)
  - Verificação / Teste: Comando da ferramenta falha ao introduzir import proibido

- [ ] Requisito / Decisão: Modelo de entrada/saída
  - Tarefa Técnica: Configurar a aplicação FastAPI e os modelos Pydantic base
  - Arquivo / Componente: backend/app/bootstrap/main.py
  - Verificação / Teste: curl -fsS http://localhost:8000/live e http://localhost:8000/ready após docker compose up --wait

- [ ] Requisito / Decisão: Build reproduzível do backend
  - Tarefa Técnica: Declarar pacotes no setuptools, garantir README.md no passo de instalação, copiar os executáveis (uvicorn) para o estágio final, adicionar __init__.py e .dockerignore
  - Arquivo / Componente: backend/pyproject.toml, backend/Dockerfile, backend/app/ (__init__.py criados), backend/.dockerignore (criado)
  - Verificação / Teste: docker compose build backend

- [ ] Requisito / Decisão: Build reproduzível do frontend
  - Tarefa Técnica: Gerar e versionar o lockfile, criar a configuração do ESLint, criar um estágio de desenvolvimento no Dockerfile e atualizar a imagem Node
  - Arquivo / Componente: frontend/package-lock.json (gerado, a versionar), frontend/.eslintrc.json (criado), frontend/Dockerfile, frontend/.dockerignore (criado)
  - Verificação / Teste: npm ci, npm run lint, npm run type-check e docker compose build frontend

- [ ] Requisito / Decisão: Configuração por ambiente e driver de banco
  - Tarefa Técnica: Projetar e validar a persistência síncrona aprovada como ponto de partida no ADR-001; selecionar driver e alinhar DATABASE_URL/manifesto, usar env_file no Compose e documentar CORS_ORIGINS no .env.example
  - Arquivo / Componente: .env.example, docker-compose.yml, backend/pyproject.toml
  - Verificação / Teste: docker compose config e conexão real ao banco na verificação do /ready
