# Backend - FastAPI/Python

Esta pasta contém o scaffold da API FastAPI/Python. A direção aprovada no `docs/architecture/decisoes-tecnicas/ADR-001-vsa-monorepo-e-persistencia.md` organiza casos de uso em fatias verticais por módulo; o scaffold atual de camadas não fixa a estrutura da implementação.

## Estrutura

- `app/entrypoints/http/` - Diretório reservado do scaffold; routers podem pertencer às fatias conforme design da change de VSA
- `app/modules/` - Módulos por capacidade (atualmente apenas scaffold; fatias por caso de uso serão criadas nas changes):
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
- Casos de uso: fatias por capacidade reúnem entradas, aplicação e saídas necessárias; não duplicar regras proprietárias do domínio
- Entrada: routers FastAPI e modelos Pydantic adaptam HTTP aos casos de uso, conforme design específico
- Saída: repositórios SQLAlchemy, e-mail, relógio e observabilidade implementam portas quando necessárias
- Persistência: SQLAlchemy síncrono como direção inicial; driver, URL, versões e escopo concreto de transações ainda precisam de change e validação
- Validação: Pydantic/HTTP valida forma/tipo; domínio valida regras
- Erros: contrato estável sem revelar detalhes internos
- Configuração: variáveis não secretas por ambiente; segredos via gerenciador aprovado
- Observabilidade: logs estruturados com correlation/request ID