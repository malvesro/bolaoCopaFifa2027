# Proposta: Cadastro local, verificação de e-mail e admissão

## Por quê

A primeira entrega funcional prioriza o cadastro local, a confirmação do endereço de e-mail e o login por usuário e senha. A participação no bolão continua condicionada à aprovação administrativa (PROD-07). A integração Google fica opcional e fora desta primeira entrega; HU-22/23 e as decisões de vínculo permanecem como escopo futuro independente.

## O que muda

- Especificar solicitação de cadastro local com nome, e-mail e credencial local, confirmação do e-mail e autenticação por usuário/senha após a confirmação.
- Especificar a conta administrativa inicial provisionada por setup controlado. No desenvolvimento local, permitir autenticação sem validação de e-mail usando somente a senha definida em variável de ambiente local não versionada; essa exceção é exclusiva do ambiente local e não define credencial padrão para produção.
- Especificar a aprovação/rejeição administrativa da participação, com autorização e auditoria, mantendo usuários não aprovados impedidos de participar.
- Manter recuperação de senha HU-21 fora desta entrega e a autenticação Google como opcional/futura, sem misturar seus fluxos com confirmação de e-mail local.

## Capacidades afetadas

`identity` no backend, `features/auth` no frontend, contratos de API, envio de e-mail (OPS-03) e autorização administrativa (PROD-07/08). Fontes: requisito v3.4 e decisões PROD-07/08 → cenários em `specs/identity-email-link/spec.md` → tarefas em `tasks.md` → testes propostos. Nenhuma validação de runtime foi executada.

## Fora de escopo

Vínculo/autenticação Google (HU-22/23 e change dedicada futura), recuperação de senha HU-21, seleção de fornecedor de e-mail, implementação, edição da change de scaffold `2026-10-18-technical-foundation`, Docker e implantação em nuvem. Políticas técnicas ainda abertas não são fixadas por esta proposta.

## Governança

**Status: proposta documental, não aprovada para implementação.** A priorização local e o provisionamento inicial aqui registrados não aprovam automaticamente desenho técnico nem tarefas. Registrar a decisão e a aprovação humana da change, seu escopo e versões de artefatos antes de executar tarefas dependentes.
