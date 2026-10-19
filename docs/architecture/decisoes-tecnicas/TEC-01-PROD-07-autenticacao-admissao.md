# Especificação Técnica: Autenticação Híbrida e Admissão de Participantes (TEC-01 & PROD-07)

**Versão:** 1.0  
**Data:** 18/10/2026  
**Status:** Decisão técnica para aprovação  
**Referência:** Requisitos v3.2 (HU-12, HU-13, HU-21), PROD-07 (Admissão), Mapa de Consulta

---

## 1. Contexto e Objetivo

Este documento define o modelo de identidade, autenticação híbrida (Google OAuth e login local), vinculação de contas e máquina de estados de participantes, garantindo segurança, auditabilidade e governança.

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
- **LGPD:** consentimento implícito no cadastro; política de exclusão (soft delete, manter histórico de palpites anonimizado).
- **Não expor palpites alheios antes do corte:** middleware de autorização valida `user.status == 'ACTIVE'` e `received_at < cutoff` em toda rota de consulta de palpites.
- **Princípio do menor privilégio:** endpoints públicos não retornam `user_identities`, apenas `users.id` e `display_name`.

---

## 9. Checklist de Implementação

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