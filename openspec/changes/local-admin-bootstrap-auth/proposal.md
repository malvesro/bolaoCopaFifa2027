# Proposal

## Why

O desenvolvimento local precisa de uma conta administrativa inicial simples para permitir validar o fluxo de administração sem depender de e-mail. A senha dessa conta é fornecida por `LOCAL_ADMIN_PASSWORD` em configuração local não versionada e nunca deve ser incluída em código ou configuração de produção.

## What Changes

- Especificar o provisionamento controlado de uma conta administrativa inicial para desenvolvimento local.
- Permitir, somente no ambiente local, autenticar a conta inicial usando a senha configurada em `LOCAL_ADMIN_PASSWORD`, sem validação de e-mail; configuração ausente ou vazia não autentica.
- Manter aprovação/rejeição de cadastro e participação dos demais usuários como responsabilidade administrativa, com auditoria.
- Proibir a senha padrão e o bypass de verificação de e-mail fora do ambiente local.
- Tratar a alteração como proposta de regra de produto a registrar nas fontes canônicas antes da implementação; não alterar os fluxos Google HU-22/23.

## Capabilities

### New Capabilities

### Modified Capabilities
- `identity-email-link`: especificar autenticação administrativa local inicial por senha padrão sem validação de e-mail, mantendo restrições fora do ambiente local e aprovação administrativa de participantes.

## Impact

Afeta a especificação OpenSpec de identidade, o provisionamento/configuração local e os casos de uso de identidade e administração no backend e frontend. Não instala dependências nem altera código. Requer atualização aprovada de PROD-07/08 e das decisões pendentes antes da implementação; a credencial não deve ser incorporada a imagens nem a configurações de produção.
