# STATE.md — [NOME DO PROJETO / TAREFA]

<!-- =======================================================================
  TEMPLATE DE ESTADO PERSISTENTE (STATE.md) — ENGENHARIA DE LOOP

  Instruções para o Agente de IA:
  1. LEITURA OBRIGATÓRIA: Leia este arquivo no INÍCIO de cada turno para reidratar o contexto.
  2. ESCRITA OBRIGATÓRIA: Atualize este arquivo no FIM de cada turno antes de acionar a validação.
  3. NÃO remova seções obrigatórias nem apague o registro de tentativas descartadas.
======================================================================= -->

## 1. Estado Global do Loop

* **Status da Execução:** `[ EM_PROGRESSO | CONCLUIDO | BLOQUEADO_HUMANO | FALHA ]`
* **Turno Atual:** `[ Ex: 3 ]` / **Limite Máximo de Turnos:** `[ Ex: 15 ]`
* **Orçamento de API Utilizado:** `[ Ex: $0.45 ]` / **Teto Máximo:** `[ Ex: $5.00 ]`
* **Data/Hora da Última Atualização:** `[ YYYY-MM-DD HH:MM:SS TZ ]`
* **Ambiente / Worktree:** `[ Ex: agent/worktree-feature-auth ]`
* **Sinal do Verificador (Stop Hook):** `[ PENDENTE | PASSED | FAILED ]`

<!-- Exemplo de preenchimento nos comentários:
* Status da Execução: EM_PROGRESSO
* Turno Atual: 4 / Limite Máximo de Turnos: 20
* Orçamento de API Utilizado: $1.20 / Teto Máximo: $10.00
* Data/Hora da Última Atualização: 2026-10-27 19:30:00 UTC
* Ambiente / Worktree: agent/worktree-refactor-jwt
* Sinal do Verificador (Stop Hook): FAILED
-->

---

## 2. Objetivo Global & Critérios de Aceitação

### Meta Principal
<!-- Descreva o objetivo final com precisão. O que precisa ser entregue ou corrigido? -->
> **Objetivo:** `[ Insira o objetivo de alto nível aqui ]`

<!-- Exemplo:
> **Objetivo:** Refatorar o módulo de autenticação em `src/auth/` para usar tokens JWT com biblioteca `jose`, garantindo que todas as rotas protegidas sejam validadas e que a suíte de testes passe sem regressões.
-->

### Critérios de Aceitação Determinísticos (Stop Condition)
<!-- Liste os comandos e testes objetivos que PROVAM numericamente que a meta foi atingida. -->
- [ ] Execução do script de testes com código de saída 0: `[ Ex: npm test -- --silent ]`
- [ ] Linter/Checagem estática sem avisos ou erros: `[ Ex: npm run lint ]`
- [ ] Cobertura mínima de código atingida: `[ Ex: >= 85% em src/auth/ ]`
- [ ] Compilação/Build de produção sem falhas: `[ Ex: npm run build ]`

---

## 3. Escopo Negativo (Zona Proibida / Hard Deny Rules)

<!--
  IMPORTANTE: Estas regras protegem o sistema contra Reward Hacking e destruição da suíte de testes.
  O agente está ESTRITAMENTE PROIBIDO de violar estes pontos sob qualquer circunstância.
-->
- ❌ **Proibição 1:** NÃO modificar, deletar ou desabilitar testes existentes dentro da pasta `tests/` para forçar aprovação.
- ❌ **Proibição 2:** NÃO alterar arquivos de configuração global (`tsconfig.json`, `.eslintrc`, etc.) para ignorar erros.
- ❌ **Proibição 3:** NÃO realizar `hardcoding` de valores estáticos em funções para burlar asserções dos testes.
- ❌ **Proibição 4:** `[ Insira outras proibições específicas do projeto, ex: "NÃO usar a biblioteca legada X" ]`

---

## 4. Ancoragem de Contexto e Arquitetura

<!--
  Esta seção serve para reidratar o agente após compacção de contexto (context drift).
  Mantenha resumos concisos da arquitetura e das decisões chave já consolidadas.
-->
* **Padrão Arquitetural Utilizado:** `[ Ex: Clean Architecture / Módulo isolado em src/auth/ ]`
* **Dependências Principais:** `[ Ex: jose@5.x, bcrypt@5.x ]`
* **Decisões Decisivas Já Tomadas:**
  1. `[ Decisão 1: Ex - Substituição do jsonwebtoken por jose para suporte nativo a Edge Runtime. ]`
  2. `[ Decisão 2: Ex - Armazenamento de Refresh Token em cookie HTTPOnly com atributo SameSite=Lax. ]`

---

## 5. Fila de Tarefas (Backlog de Execução)

<!--
  Utilize os marcadores de status:
  - [x] Concluído
  - [/] Em Andamento (Apenas UMA tarefa por vez)
  - [ ] Pendente
-->

### Fase 1: Preparação e Mapeamento
- [x] **Task 1.1:** Mapear todos os pontos de integração da biblioteca antiga `jsonwebtoken`.
- [x] **Task 1.2:** Criar suíte de testes de regressão antes das alterações.

### Fase 2: Implementação do Core
- [/] **Task 2.1:** Implementar a nova classe `JwtProvider` usando a biblioteca `jose`.
- [ ] **Task 2.2:** Atualizar o middleware de autenticação HTTP (`auth.middleware.ts`).
- [ ] **Task 2.3:** Ajustar as rotas de login e refresh token.

### Fase 3: Validação e Qualidade
- [ ] **Task 3.1:** Rodar suíte completa de testes e corrigir eventuais falhas.
- [ ] **Task 3.2:** Validar regras de tipo (`npm run typecheck`) e linter.

---

## 6. Log de Tentativas Descartadas e Aprendizados (Anti-Looping)

<!--
  REGISTRO CRÍTICO: Previne que o agente repita os mesmos erros em turnos futuros.
  A cada tentativa que falhar no teste ou no Stop Hook, registre o que aconteceu aqui.
-->

| Turno | Abordagem Testada | Resultado / Erro Observado | Causa Raiz | Ação Tomada / Por que foi Descartado |
| :---: | :--- | :--- | :--- | :--- |
| `1` | `[ Ex: Tentar usar SameSite=Strict no cookie ]` | `[ Ex: Teste de integração do dashboard falhou ]` | `[ Ex: O redirecionamento OAuth cross-site perdeu o cookie ]` | `[ Ex: Descartado. Mantido SameSite=Lax para rotas de callback ]` |
| `2` | `[ Ex: Executar verifyJWT de forma síncrona ]` | `[ Ex: UnhandledPromiseRejection ]` | `[ Ex: A função jose.jwtVerify é estritamente assíncrona ]` | `[ Ex: Convertido middleware para async/await ]` |
| `N` | `[ Descreva a tentativa ]` | `[ Descreva o erro ou falha ]` | `[ Explique por que falhou ]` | `[ Explique a decisão ]` |

---

## 7. Próximo Passo Imediato

<!--
  Esta é a instrução exata para a ação do PRÓXIMO turno.
  Deve ser clara, focada e vinculada à tarefa atualmente em andamento [/].
-->
* **Tarefa Atual:** `[ Task 2.1: Implementar a nova classe JwtProvider ]`
* **Ação Exata no Próximo Turno:** `[ Ex: Finalizar a implementação do método verify() em src/auth/jwt.provider.ts e rodar 'npm test tests/jwt.test.ts' para verificar a asserção de expiração. ]`
* **Condição de Sucesso do Turno:** `[ Ex: O arquivo tests/jwt.test.ts deve passar com 0 erros. ]`

---

## 8. Protocolo de Manutenção Deste Arquivo (Regras do Sistema)

```
[INSTRUÇÕES AUTOMÁTICAS PARA O AGENTE DE IA]
- Antes de qualquer alteração de código, verifique se a 'Tarefa Atual' da Seção 7 corresponde ao seu plano.
- Nunca conclua o turno sem atualizar as seções 1, 5, 6 e 7 do STATE.md.
- Se você tentar a mesma solução 2 vezes sem sucesso, PARE, registre a falha na Seção 6 e mude a estratégia no turno 3.
- Se atingir 3 falhas consecutivas na mesma tarefa, marque o 'Status da Execução' na Seção 1 como BLOQUEADO_HUMANO e encerre a sessão.
```
