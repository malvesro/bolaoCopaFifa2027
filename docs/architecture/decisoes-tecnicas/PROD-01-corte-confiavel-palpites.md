# Especificação Técnica: Corte Confiável de Palpites e Concorrência na Fronteira (PROD-01)

**Versão:** 1.0  
**Data:** 18/10/2026  
**Status:** Decisão técnica para aprovação  
**Referência:** Requisitos v3.2 (PROD-01, PROD-02, PROD-05), Revisão Arquitetural Multiagentes

---

## 1. Contexto e Objetivo

Este documento especifica a implementação técnica do corte confiável de palpites, garantindo que:
- O horário de corte (1 hora antes do kickoff oficial vigente, BRT/UTC-3) seja respeitado de forma justa, precisa e auditável
- O relógio do cliente seja **estritamente ignorado** para decisões de elegibilidade
- Submissões concorrentes sejam tratadas corretamente, incluindo cenários de reabertura de janela (PROD-02)
- A auditoria seja completa e rastreável

---

## 2. Fonte Autoritativa de Tempo

### 2.1 Princípio Fundamental
**O relógio do cliente (browser, dispositivo móvel) nunca é evidência válida** para elegibilidade de palpite. A única fonte de verdade é o tempo do servidor backend.

### 2.2 Implementação da Fonte de Tempo
- **Sincronização:** Todos os servidores de aplicação (FastAPI) e banco de dados (PostgreSQL) devem sincronizar relógio via **NTP** (preferencialmente com fontes stratum 1/2) ou **PTP** (Precision Time Protocol) em ambientes que exijam precisão sub-milissegundo.
- **Fuso de armazenamento:** Todos os timestamps são armazenados e processados em **UTC** (ISO 8601 com `Z` ou offset `+00:00`).
- **Exibição:** Conversão para BRT (UTC-3) ocorre apenas na camada de apresentação (frontend).

### 2.3 Validação de Sincronização
- Monitoramento contínuo de *clock drift* entre instâncias (alertas se desvio > 100ms)
- Health check que valida sincronização NTP antes de aceitar tráfego

---

## 3. Ciclo de Vida do Timestamp — Distinção Obrigatória

Três timestamps distintos devem ser capturados e persistidos para cada tentativa de palpite:

| Timestamp | Onde Capturado | Finalidade | Obrigatório |
|-----------|----------------|------------|-------------|
| **`received_at`** | Middleware/proxy de ingresso (API Gateway, load balancer, ou middleware FastAPI *mais cedo possível*) | **Decisão de elegibilidade** — comparação com `cutoff_time` | **Sim** |
| **`eligibility_decision_at`** | Camada de serviço (application layer) | Registro do instante da decisão lógica (aceite/rejeição) | Sim |
| **`processed_at` / `persisted_at`** | Banco de dados (PostgreSQL) via `clock_timestamp()` | Auditoria de persistência real; prova de que gravação ocorreu após decisão | Sim |

### 3.1 `received_at` — O Timestamp da Borda
- Deve ser gerado **no ponto de entrada da requisição HTTP**, antes de qualquer processamento de negócio, autenticação, validação de schema, ou fila.
- Implementação recomendada: middleware FastAPI executado *antes* de `Depends(get_db)`, `Depends(get_current_user)`, etc.
- Formato: `datetime` UTC com precisão de microssegundos (ex.: `2027-06-24T18:30:12.123456+00:00`).

### 3.2 Decisão de Elegibilidade
```python
# Pseudocódigo da regra de negócio
cutoff_time = match.kickoff_at - timedelta(hours=1)  # kickoff_at em UTC
is_eligible = received_at < cutoff_time  # ESTritamente menor
```

### 3.3 `processed_at` / `persisted_at`
- Capturado **dentro da transação de banco** no momento do `INSERT`/`UPDATE`.
- No PostgreSQL: usar `clock_timestamp()` (não `now()` / `transaction_timestamp()` / `statement_timestamp()`), pois `clock_timestamp()` reflete o instante real de execução da função.
- Permite auditoria: "a requisição chegou em X, foi decidida em Y, gravou em Z".

---

## 4. Análise das Opções de Timestamp no PostgreSQL

| Função | Retorna | Caso de Uso | Adequado para `persisted_at`? |
|--------|---------|-------------|-------------------------------|
| `transaction_timestamp()` | Início da transação atual | Auditoria de início de transação | **Não** — mesmo valor para toda a transação |
| `statement_timestamp()` | Início do statement atual | Auditoria de início de statement | **Não** — mesmo valor para todo o statement |
| `clock_timestamp()` | Instante real da chamada da função | **Timestamp real de execução** | **SIM** — reflete momento exato da gravação |
| `now()` | Alias de `transaction_timestamp()` | Compatibilidade | **Não** |

**Decisão:** `persisted_at` usa `clock_timestamp()` como valor default da coluna ou no `INSERT` explícito.

---

## 5. Semântica Rigorosa da Fronteira do Corte

### 5.1 Regra Matemática
Seja:
- `K` = `kickoff_time` oficial vigente (em UTC, fonte administrativa)
- `C` = `cutoff_time` = `K - 1 hora`
- `R` = `received_at` da requisição (em UTC, fonte servidor)

**Elegível ⇔ `R < C`** (estritamente menor)

### 5.2 Comportamento nos Limites
| Cenário | `received_at` vs `cutoff_time` | Resultado HTTP | Código |
|---------|-------------------------------|----------------|--------|
| Pré-corte (ex.: 61 min antes) | `R < C` | **Aceito** | 200/201 |
| Milissegundo limítrofe (ex.: 3599.999s antes) | `R < C` | **Aceito** | 200/201 |
| **Instante exato do corte** | `R == C` | **Rejeitado** | **409 Conflict** |
| Pós-corte (ex.: 1ms depois) | `R > C` | **Rejeitado** | **409 Conflict** |
| Reabertura ativa (PROD-02) | Novo `C'` calculado, `R < C'` | **Aceito** | 200/201 |

### 5.3 Códigos de Erro
- **409 Conflict** — "Prazo de palpites encerrado para esta partida" (cutoff atingido/ultrapassado)
- **422 Unprocessable Entity** — Payload inválido (ex.: placar negativo, partida inexistente)
- **403 Forbidden** — Participante não autorizado (ex.: `PENDING_APPROVAL`, `BLOCKED`)

> **Nota:** O requisito v3.2 menciona `403 Forbidden` ou `"Prazo encerrado"`. A especificação técnica adota **409 Conflict** por ser semanticamente correto para conflito de estado (recurso não mais editável), mantendo mensagem amigável no body.

### 5.4 Requisição Recebida Antes do Corte, Processada Depois
- Se `received_at < cutoff_time` mas a transação commita *após* o cutoff: **ACEITO**.
- O `received_at` preservado prova elegibilidade. O `persisted_at` pode ser > cutoff — isso é esperado e auditável.

---

## 6. Mecanismo de Concorrência com PostgreSQL

### 6.1 Problema: Corrida na Reabertura (PROD-02)
Quando um admin altera o kickoff, a janela pode reabrir. Múltiplos participantes podem tentar editar/criar palpites simultaneamente para a mesma partida.

### 6.2 Solução: Lock de Linha na Partida (`SELECT ... FOR UPDATE`)
```sql
-- Início da transação de criação/edição de palpite
BEGIN;

-- 1. Lock na partida para serializar decisões de corte/reabertura
SELECT id, kickoff_at, cutoff_at 
FROM matches 
WHERE id = $match_id 
FOR UPDATE;  -- Bloqueia a linha até COMMIT/ROLLBACK

-- 2. Recalcula cutoff vigente (pode ter mudado por admin concorrente)
-- 3. Valida received_at < cutoff_at (usando received_at já capturado no middleware)
-- 4. INSERT/UPDATE na tabela predictions
-- 5. COMMIT (libera lock)
```

### 6.3 Por que `FOR UPDATE` na `matches` e não na `predictions`?
- A condição de corte depende de `matches.kickoff_at` (dado administrativo mutável).
- Lock na partida garante que **nenhuma alteração de kickoff (PROD-02) e nenhuma decisão de palpite ocorram simultaneamente** para a mesma partida.
- Evita *lost update* no cutoff e *race condition* entre reabertura e submissão.

### 6.4 Índices Necessários
```sql
-- Para busca rápida de palpites por partida + usuário
CREATE UNIQUE INDEX uq_predictions_match_user 
ON predictions (match_id, user_id);

-- Para auditoria temporal
CREATE INDEX idx_predictions_received_at ON predictions (received_at);
```

---

## 7. Casos de Teste de Referência (6 Cenários)

| ID | Cenário | `received_at` | `cutoff_time` | `kickoff_time` | Ação Admin | Resultado Esperado |
|----|---------|---------------|---------------|----------------|------------|-------------------|
| **TC-01** | **Pré-corte normal** | `K - 1h - 5min` | `K - 1h` | `K` | Nenhuma | **201 Created** — palpite salvo, `received_at` preservado |
| **TC-02** | **Milissegundo limítrofe** | `K - 1h - 1ms` | `K - 1h` | `K` | Nenhuma | **201 Created** — `<` estrito permite |
| **TC-03** | **Corte exato** | `K - 1h` (exato) | `K - 1h` | `K` | Nenhuma | **409 Conflict** — `R == C` rejeita |
| **TC-04** | **Pós-corte** | `K - 1h + 100ms` | `K - 1h` | `K` | Nenhuma | **409 Conflict** — `R > C` rejeita |
| **TC-05** | **Clock skew do cliente** | Cliente envia `Date: future` mas servidor captura `R = now()` | `K - 1h` | `K` | Nenhuma | **Decisão baseada em `R` do servidor** — header do cliente ignorado |
| **TC-06** | **Submissões concorrentes + reabertura** | T1: `K - 1h - 10s`<br>T2: `K - 1h - 5s`<br>T3 (admin): altera kickoff para `K + 30min` | Inicial: `K - 1h`<br>Novo: `K + 30min - 1h` | `K` → `K + 30min` | Admin altera kickoff entre T1 e T2 | **T1: 201** (lock serializa, T1 vê cutoff antigo, `R < C_old`)<br>**T2: 201** (após commit T1, lock liberado, T2 vê novo cutoff, `R < C_new`) |

### 7.1 Detalhamento do TC-06 (Concorrência + Reabertura)
```
Tempo        Thread Usuário A          Thread Usuário B          Thread Admin
----         ----------------          ----------------          ------------
t0           POST /predictions                                  
             received_at = t0                                      
             SELECT match FOR UPDATE  (lock obtido)              
             valida t0 < C_old  ✓                                 
             INSERT prediction                                    
             COMMIT (lock liberado)                               
                                                      
             (reabre janela)         POST /predictions           
                                    received_at = t1            
                                                      ALTER kickoff
                                                      UPDATE matches
                                                      SET kickoff_at = K+30min
                                                      WHERE id = X
                                                      COMMIT
                                    SELECT match FOR UPDATE (espera lock admin)
                                    lock obtido
                                    recalcula C_new = (K+30min) - 1h
                                    valida t1 < C_new  ✓
                                    INSERT/UPDATE prediction
                                    COMMIT
```
**Resultado:** Ambos aceitos. O lock serializa acesso à linha `matches`, garantindo que cada thread veja o `cutoff_time` vigente no momento de sua validação.

---

## 8. Integração com PROD-02 (Reabertura por Alteração de Kickoff)

- Alteração de `kickoff_at` em `matches` **deve** ser feita dentro de transação com `SELECT ... FOR UPDATE` na mesma linha.
- Isso garante exclusão mútua entre: (a) admin alterando kickoff, (b) usuários submetendo palpites.
- O `received_at` da requisição do usuário **não muda** — a elegibilidade é avaliada contra o `cutoff_time` vigente *no momento da validação dentro da transação* (após obter o lock).

---

## 9. Auditoria e Rastreabilidade

### 9.1 Tabela de Auditoria Sugerida (`prediction_audit_log`)
```sql
CREATE TABLE prediction_audit_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prediction_id   UUID NOT NULL REFERENCES predictions(id),
    user_id         UUID NOT NULL REFERENCES users(id),
    match_id        UUID NOT NULL REFERENCES matches(id),
    action          TEXT NOT NULL,  -- 'CREATE', 'UPDATE', 'REJECT_CUTOFF', 'REJECT_INVALID'
    received_at     TIMESTAMPTZ NOT NULL,      -- timestamp da borda
    cutoff_at       TIMESTAMPTZ NOT NULL,      -- cutoff vigente na validação
    kickoff_at      TIMESTAMPTZ NOT NULL,      -- kickoff vigente na validação
    decision        TEXT NOT NULL,  -- 'ACCEPTED', 'REJECTED'
    http_status     INT NOT NULL,
    request_ip      INET,
    user_agent      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);
```

### 9.2 Campos Obrigatórios no Log
- `received_at` (prova de anterioridade ao corte)
- `cutoff_at` e `kickoff_at` vigentes no momento da decisão
- Decisão final e HTTP status
- IP/UA para forense (LGPD: minimização, retenção limitada)

---

## 10. Checklist de Implementação

- [ ] Middleware FastAPI captura `received_at` **antes** de qualquer `Depends()`
- [ ] `received_at` passado via `request.state.received_at` para camada de serviço
- [ ] Serviço de palpites abre transação, faz `SELECT match FOR UPDATE`, valida `received_at < cutoff_at`
- [ ] `persisted_at` usa `clock_timestamp()` no `INSERT`/`UPDATE`
- [ ] Rejeição no corte exato (`>=`) retorna **409 Conflict** com mensagem padronizada
- [ ] Admin `PATCH /matches/{id}/kickoff` usa `SELECT FOR UPDATE` na mesma linha
- [ ] Índices criados, migrações versionadas (Alembic)
- [ ] Testes automatizados cobrem TC-01 a TC-06
- [ ] Monitoramento de *clock drift* entre instâncias ativo

---

## 11. Referências

- Requisitos v3.2 — Seção 1.3.3 (Horário da partida, prazo dos palpites e transparência)
- PROD-02 / PROD-05 — Reabertura de janela por alteração de kickoff
- Revisão Arquitetural Multiagentes — Seção "Concorrência e Corte"
- PostgreSQL Docs: [Date/Time Functions](https://www.postgresql.org/docs/current/functions-datetime.html)