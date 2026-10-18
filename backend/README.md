# Backend - FastAPI/Python

Esta diretoria contém a API backend desenvolvida com FastAPI e Python seguindo a arquitetura definida em `docs/architecture/arquitetura-software.md`.

## Estrutura

- `app/entrypoints/http/` - FastAPI, routers, schemas de transporte, middleware
- `app/modules/` - Módulos de domínio organizados por funcionalidade:
  - `identity/` - Identidade e acesso
  - `tournament/` - Torneio e calendário
  - `predictions/` - Palpites
  - `scoring/` - Apuração e pontuação
  - `ranking/` - Ranking e estatísticas
  - `support/` - Suporte
  - `gamification/` - Gamificação
- `app/shared/` - Primitivas realmente comuns (clock, IDs, erros)
- `app/bootstrap/` - Composição/configuração por ambiente
- `tests/` - Testes organizados por categoria:
  - `unit/` - Testes unitários
  - `integration/` - Testes de integração com PostgreSQL
  - `api/` - Testes de API/contrato
  - `contract/` - Testes de contrato
- `migrations/` - Migrações do banco de dados (Alembic)

## Convenções

- Domínio: objetos/valores e políticas puras, sem ORM nem framework
- Aplicação: casos de uso e limites transacionais
- Entrada: routers FastAPI e modelos Pydantic adaptam HTTP aos casos de uso
- Saída: repositórios SQLAlchemy, e-mail, relógio e observabilidade implementam portas
- Persistência: SQLAlchemy 2.x; sessões/transações com escopo explícito por caso de uso
- Validação: Pydantic/HTTP valida forma/tipo; domínio valida regras
- Erros: contrato estável sem revelar detalhes internos
- Configuração: variáveis não secretas por ambiente; segredos via gerenciador aprovado
- Observabilidade: logs estruturados com correlation/request ID