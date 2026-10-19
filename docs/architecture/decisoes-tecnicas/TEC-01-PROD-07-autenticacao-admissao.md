# Especificação Técnica: Autenticação Híbrida e Admissão de Participantes (TEC-01 & PROD-07)

**Versão:** 1.1 (minuta anotada; proposta original de 18/10/2026 preservada para revisão)
**Data:** 19/10/2026
**Status:** Minuta técnica NÃO aprovada integralmente. Esquema SQL, estados, JWT/refresh, gatilhos e políticas de exclusão abaixo são apenas exemplos anteriores à decisão de 19/10/2026; **não usar como instruções de implementação**.
**Referência:** Requisitos v3.4 (HU-12, HU-13, HU-21, HU-22 e HU-23), PROD-07/TEC-01 e [ADR-001](ADR-001-vsa-monorepo-e-persistencia.md).

> **Nota de compatibilidade da minuta:** foi aprovada a regra de que a correspondência de e-mail é referência para o primeiro vínculo Google/local e que o endereço local novo ou alterado deve ser verificado por código numérico de seis dígitos enviado a ele, com até três tentativas por verificação (HU-22). Também foi aprovado o novo login Google da identidade já vinculada à conta validada, identificada por `sub` (HU-23). Isso não aprova vínculo automático, o mecanismo do primeiro vínculo, reenvio/reinício de tentativas, os efeitos da mudança de endereço nem o esquema abaixo. Sessão opaca revogável mantida no servidor é a direção aprovada, em lugar da proposta de JWT/refresh. O exemplo SQL abaixo contém uma inconsistência (`provider_user_id TEXT NOT NULL` e comentário “NULL para local”), unicidade insuficiente para impedir duplicidades, e `users.email` opcional apesar do mínimo de e-mail em PROD-07. A busca apenas por `ACTIVE` não cobre contas preexistentes pendentes/rejeitadas/bloqueadas. A cláusula de soft delete e a afirmação de consentimento implícito não são decisões aprovadas (OPS-01). Resolver estas questões e as pendências TEC-01/PROD-07 em change OpenSpec específica antes de codificar.

---

## 1. Contexto e Objetivo

Este documento reúne uma **minuta anterior de modelo** de identidade, autenticação Google e local, vínculo e estados; não garante segurança nem define schema ou políticas aprovadas. As decisões HU-22/23 e as lacunas atualizadas estão no requisito v3.4 e em `docs/requirements/decisoes-pendentes.md`.

---

## 2. Modelo de Identidade Interna Única

### 2.1 Princípio
Um participante é representado por **um único `user.id` UUID** imutável, independentemente de quantos provedores de identidade ele utilize.

### 2.2 Esquema de Tabelas

#### `users`
```sql
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name    TEXT NOT NULL,
    display_name_normalized TEXT NOT NULL, -- sem acentos, lower case
    email           TEXT UNIQUE,
    email_verified  BOOLEAN NOT NULL DEFAULT FALSE,
    status          TEXT NOT NULL DEFAULT 'PENDING_APPROVAL' 
                    CHECK (status IN ('PENDING_APPROVAL','ACTIVE','REJECTED','BLOCKED')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    last_login_at   TIMESTAMPTZ,
    deactivated_at  TIMESTAMPTZ
);
```

#### `user_identities`
```sql
CREATE TABLE user_identities (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider        TEXT NOT NULL CHECK (provider IN ('google','local')),
    provider_user_id TEXT NOT NULL,  -- sub do Google, ou NULL para local
    email           TEXT NOT NULL,
    email_verified  BOOLEAN NOT NULL DEFAULT FALSE,
    password_hash   TEXT,  -- NULL para Google; obrigatório para local
    created_at      TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    last_used_at    TIMESTAMPTZ,
    UNIQUE (provider, provider_user_id),     -- evita duplicata no provedor
    UNIQUE (provider, email, user_id)        -- controle de vinculação
);
```

### 2.3 Relação
- Um `user` possui **uma ou mais** `user_identity` (relacionamento 1:N).
- O `user.id` é a chave de todas as demais tabelas (palpites, auditoria, etc.).
- A tabela `users` mantém um `email` canônico opcional (para contato administrativo).

---

## 3. Autenticação Híbrida

### 3.1 Google OAuth 2.0
- **Escopo mínimo:** `openid email profile`
- **Verificação obrigatória:** `email_verified` deve ser `true` no token ID do Google.
- **Fluxo:**
  1. Usuário autoriza via Google.
  2. Backend valida assinatura do token com JWKS do Google.
  3. Extrai `sub` (Google user ID), `email`, `email_verified`, `name`.
  4. Procura `user_identities` por `(provider='google', provider_user_id='sub')`.
  5. Se encontrado → login do `users.id` associado.
  6. Se não encontrado → verifica se existe `user` com mesmo `email` e `status ACTIVE`.
     - **Se existir:** vinculação exige senha local ou confirmação por e-mail (seção 4.2).
     - **Se não existir:** cria `users` com `PENDING_APPROVAL` e nova `user_identity`.

### 3.2 Login Local (E-mail + Senha)
- **Hash de senha:** **Argon2id** (preferencial) ou **bcrypt adaptativo** com custo configurável.
- Configuração recomendada:
  - Argon2id: `memory_cost=64 MiB`, `time_cost=3`, `parallelism=1` (ajustar conforme hardware).
  - bcrypt: `cost=12+` (reavaliar a cada 12 meses).
- **Armazenamento:** somente `password_hash` em `user_identities.password_hash`.
- **Política de senha:** não bloqueante excessiva. Orientações de boas práticas (HU-13), sem lockout por 30 dias do campeonato.

### 3.3 Sessão e Tokens
- **Access token:** JWT curto (15 min) assinado pelo backend, com `user_id`, `roles`, `status`.
- **Refresh token:** HTTP-only, Secure, SameSite=Strict, rotação a cada uso.
- **Revogação:** logout invalida refresh token; bloqueio administrativo (`BLOCKED`) rejeita novos access tokens na validação.

---

## 4. Segurança de Vinculação de Contas

### 4.1 Proteção contra Account Takeover por E-mail
Coincidência de e-mail não é suficiente para vinculação automática.

**Regras:**
1. **Google → conta existente local:** exigir prova de posse da senha local **ou** confirmação por link de e-mail (reenviar para e-mail existente).
2. **Local → Google já vinculado a outro usuário:** impedir criação, retornar erro de conflito.
3. **`email_verified=true` obrigatório** para identidades Google.

### 4.2 Fluxo de Vinculação
```
Usuário loga com Google (email: ana@exemplo.com)
↓
Existe user_identity(provider='google', provider_user_id='sub')?
   SIM → login
   NÃO →
Existe users com email canônico = ana@exemplo.com?
   SIM →
   Usuário já possui senha local?
      SIM → solicitar senha local para confirmar vinculação
      NÃO → enviar e-mail de confirmação com token de 30 min
   NÃO → criar novo user PENDING_APPROVAL
```

---

## 5. Máquina de Estados do Participante

### 5.1 Estados
| Estado | Descrição | Pode palpitar? | Pode ver ranking? | Pode editar perfil? |
|--------|-----------|----------------|-------------------|---------------------|
| `PENDING_APPROVAL` | Aguardando aprovação manual do admin | **NÃO** | **NÃO** | Somente próprio perfil/status |
| `ACTIVE` | Aprovado, participação liberada | **SIM** | **SIM** | **SIM** |
| `REJECTED` | Solicitação negada | **NÃO** | **NÃO** | Somente leitura de perfil |
| `BLOCKED` | Bloqueio administrativo | **NÃO** | **NÃO** | **NÃO** |

### 5.2 Transições Permitidas
```
PENDING_APPROVAL --[admin aprova]--> ACTIVE
PENDING_APPROVAL --[admin rejeita]--> REJECTED
ACTIVE           --[admin bloqueia]--> BLOCKED
ACTIVE           --[admin suspende]--> PENDING_APPROVAL (ou REJECTED)
BLOCKED          --[admin reativa]--> ACTIVE
```

**Transições devem ser executadas por admin autenticado e auditadas.**

### 5.3 Implementação na Camada de Serviço
```python
# Pseudocódigo no endpoint de criação de palpite
def create_prediction(user_id, match_id, ...):
    user = db.get_user(user_id)
    if user.status != 'ACTIVE':
        raise HTTPException(403, "Participante não autorizado")
    # ... continuar fluxo de corte PROD-01 ...
```

---

## 6. Matriz de Permissões para PEND одежды_APPROVAL

| Recurso | Ação | Permitido? | Justificativa |
|---------|------|------------|---------------|
| `/me` | GET próprio perfil/estado | **SIM** | Transparência mínima |
| `/me` | PATCH próprio nome (antes da aprovação) | **SIM** | Autocorreção ortográfica |
| `/predictions` | POST/PUT palpite | **NÃO** | Participação bloqueada até aprovação |
| `/ranking` | GET | **NÃO** | ranking visível apenas para participantes ativos |
| `/matches/{id}/predictions/public` | GET palpites alheios | **NÃO** | regra de visibilidade pós-corte + status ativo |
| `/admin/users` | ... | **NÃO** | acesso administrativo apenas |

---

## 7. Autorização e Auditoria Administrativa

### 7.1 Aprovação Manual Exclusiva
- Somente administradores com `role='admin'` podem aprovar/rejeitar/bloquear participantes.
- Interface administrativa lista fila `PENDING_APPROVAL` com e-mail, data de solicitação, provedores vinculados.

### 7.2 Auditoria Append-Only

#### `user_status_audit_log`
```sql
CREATE TABLE user_status_audit_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    changed_by      UUID NOT NULL REFERENCES users(id),  -- admin
    old_status      TEXT NOT NULL,
    new_status      TEXT NOT NULL,
    reason          TEXT,
    changed_at      TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    ip_address      INET
);
CREATE INDEX idx_status_audit_user ON user_status_audit_log(user_id, changed_at DESC);
```

**Regras:**
- Não apagar/atualizar registros — apenas INSERT.
- `reason` opcional, mas recomendado para rejeição/bloqueio.
- Trigger `BEFORE UPDATE` em `users.status` garante log automático.

### 7.3 Recuperação de Senha (HU-21)
- Token único por e-mail, expiração 30-60 min, uso único.
- Não expor se e-mail existe (resposta genérica: "Se o e-mail estiver cadastrado, você receberá instruções").
- Somente funciona para identidade `local` com `status ACTIVE`.

---

## 8. Considerações de Privacidade e Segurança

- **Dados pessoais minimizados:** não coletar dados fora do escopo (nome, e-mail).
- **Privacidade:** base legal, retenção e escopo da exclusão/anonimização exigem avaliação própria (OPS-01); esta minuta não aprova consentimento implícito nem soft delete.
- **Não expor palpites alheios antes do corte:** em consultas de palpites de terceiros, o backend verifica autorização e só divulga após o corte vigente e a conclusão das gravações elegíveis anteriores a ele; durante reabertura, novas leituras alheias ficam ocultas até o novo corte. A condição `received_at < cutoff` aplica-se à elegibilidade de **gravação**, não à leitura (requisitos v3.4, §1.3.3/HU-20). A política de estados `ACTIVE` nesta minuta ainda requer decisão PROD-07.
- **Princípio do menor privilégio:** endpoints públicos não retornam `user_identities`, apenas `users.id` e `display_name`.

---

## 9. Checklist original — não autorizado para execução

O checklist a seguir antecede HU-22/23 e ADR-001. Substituir por tarefas da change `openspec/changes/2026-10-19-identity-email-link/` somente após decisões residuais e aprovação humana da change; não executar os itens abaixo como estão.

- [ ] Criar tabelas `users`, `user_identities`, `user_status_audit_log`
- [ ] Implementar middleware de autenticação JWT + validação de `status`
- [ ] Configurar OAuth Google com verificação de `email_verified`
- [ ] Implementar hash Argon2id/bcrypt com custo parametrizável
- [ ] Criar fluxo de vinculação com confirmação por senha ou e-mail
- [ ] Bloquear endpoints de palpite/ranking para `PENDING_APPROVAL`, `REJECTED`, `BLOCKED`
- [ ] Log automático de transições de status via trigger
- [ ] Teste de enumeração de usuários (recuperação de senha genérica)
- [ ] Teste de vinculação maliciosa por coincidência de e-mail

---

**Referências:** Requisitos v3.2 HU-12, HU-13, HU-21; PROD-07 — Admissão de Participantes; Decisões Pendentes.