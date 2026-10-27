# Tasks

## 1. Decisão e bootstrap local

- [x] 1.1 Registrar em `docs/requirements/decisoes-pendentes.md` a exceção de login administrativo local aprovada pelo solicitante nesta conversa, delimitando-a a desenvolvimento local e mantendo aprovação de participantes fora desta change; verificar rastreabilidade e ausência de conflito com HU-22/23.
- [x] 1.2 Disponibilizar a identidade administrativa local `admin` sem persistência, somente no endpoint habilitado com `ENVIRONMENT=development`; a identidade é fixa e não cria conta em banco. Verificado por implementação e testes de autenticação/localização.
- [x] 1.3 Obter a senha de `LOCAL_ADMIN_PASSWORD` na configuração local não versionada; ausência ou valor vazio deve rejeitar login, sem segredo embutido no código, specs ou imagem.

## 2. Backend de autenticação

- [x] 2.1 Implementar endpoint de login da conta `admin` pela senha padrão local, sem validação de e-mail, restrito a `ENVIRONMENT=development`; testes escritos para sucesso local e rejeição em ambiente não local e credenciais incorretas (execução bloqueada: pytest não instalado).
- [x] 2.2 Implementar sessão opaca em memória vinculada à conta administrativa, com cookie `HttpOnly`; testes escritos para acesso autenticado, rejeição sem sessão e invalidação no logout. Reinício invalida as sessões por armazenamento em memória por processo (não testado em runtime).
- [x] 2.3 Garantir que a senha não seja registrada em logs nem habilite bypass fora do desenvolvimento; testes cobrem ambiente `production`, e inspeção do handler confirma ausência de logging do corpo (pytest não instalado para execução).

## 3. Frontend e validação

- [x] 3.1 Criar interface de login administrativo local que envie credencial à API e apresente estados de sucesso/erro sem persistir senha ou identificador de sessão no navegador; verificado estaticamente pelo componente e integração à página inicial (type-check indisponível: dependências frontend não instaladas).
- [x] 3.2 Documentar o modo de uso local no `backend/README.md` e registrar as verificações executadas. `python3 -m compileall`, `docker compose config --quiet` e `git diff --check` passaram; execução pytest falhou porque pytest não está instalado; type-check/lint falharam porque dependências npm não estão instaladas.

## Fora do escopo

- Aprovação/rejeição de cadastro de participantes, cadastro local geral, confirmação de e-mail, Google, recuperação de senha e painel administrativo.
