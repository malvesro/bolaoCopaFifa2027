# Proposta: Verificação do e-mail local e vínculo Google/local

## Por quê

O requisito v3.4 (19/10/2026), HU-22/23, registra vínculo entre identidades Google e local por e-mail, exige verificação do endereço local novo ou alterado por código numérico de seis dígitos com até três tentativas por verificação e permite novo login Google de identidade já vinculada à conta validada. TEC-01 e PROD-07 ainda deixam lacunas sobre primeiro vínculo, colisões, efeitos da mudança de endereço e segurança do código; a minuta técnica TEC-01/PROD-07 antecede as decisões e não está aprovada integralmente.

## O que muda

- Especificar cenários de verificação inicial e após mudança de e-mail local, com três tentativas por verificação, sem definir arbitrariamente validade, reenvio ou reinício do limite.
- Especificar o retorno por Google de identidade já vinculada, reconhecida por `sub`, e os cenários de primeiro vínculo por correspondência de e-mail que ainda exigem decisão prévia de segurança; não criar conta/participação duplicada por engano.
- Separar verificação de e-mail, aprovação administrativa (PROD-07) e recuperação de senha (HU-21).
- Preparar design e tarefas verificáveis para identidade, API, frontend e persistência, sujeitos à resolução e aprovação das lacunas.

## Capacidades afetadas

`identity` no backend, `features/auth` no frontend (a criar), contrato de API (a definir), envio externo de e-mail (OPS-03) e autorização administrativa (PROD-07/08). Fonte v3.4 → HU-22/23, TEC-01 e PROD-07 → cenários em `specs/identity-email-link/spec.md` → tarefas em `tasks.md` → testes propostos; nenhuma validação de runtime foi executada.

## Fora de escopo

Recuperação de senha por token da HU-21, escolha de fornecedor de e-mail, implementação de autenticação, edição da change de scaffold `2026-10-18-technical-foundation`, Docker e implantação em nuvem. As políticas ainda abertas não são fixadas por esta proposta.

## Governança

**Status: proposta documental, não aprovada para implementação.** Decisões de produto HU-22/23 informadas pelo solicitante em 19/10/2026 não aprovam automaticamente design, políticas residuais ou tarefas. Responsável e registro da aprovação da change, seu escopo e versões de artefatos devem ser identificados antes de executar tarefas dependentes.
