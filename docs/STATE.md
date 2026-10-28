# STATE.md — Bolão Copa FIFA 2027 / Estado operacional

<!-- Adaptado ao formato de docs/STATE-template.md em 2026-10-27. O histórico abaixo preserva os registros anteriores; não inferir aprovação de produto a partir deste arquivo. -->

## 1. Estado Global do Loop

* **Status da Execução:** `EM_PROGRESSO` — tarefa documental concluída; a implementação de cadastro permanece bloqueada por decisões/aprovação humana.
* **Turno Atual:** não controlado / **Limite Máximo de Turnos:** não definido.
* **Orçamento de API Utilizado:** não disponível / **Teto Máximo:** não definido.
* **Data/Hora da Última Atualização:** `2026-10-27 23:49:25 -03`.
* **Ambiente / Worktree:** `/home/rosner/projetosgit/bolaoCopaFifa2027`, branch `feat/local-admin-authentication`.
* **Sinal do Verificador (Stop Hook):** `PENDENTE` (nenhum Stop Hook foi executado; validação documental `git diff --check` passou).

---

## 2. Objetivo Global & Critérios de Aceitação

### Meta Principal

> **Objetivo:** Manter um registro operacional fiel e atualizado do projeto e das suas validações, sem ultrapassar decisões aprovadas nem confundir planejamento com autorização de implementação.

### Critérios de Aceitação Determinísticos (Stop Condition)

- [x] `git diff --check` sem erros para a alteração documental deste turno.
- [ ] Testes de aplicação, lint/type-check e build: não são critérios desta tarefa documental; continuam não executados conforme o último registro conhecido.
- [ ] Para iniciar fluxos de cadastro/admissão: decisões pendentes resolvidas e aprovação humana explícita do escopo, seguida de implementação e validações próprias. Não concluído.

---

## 3. Escopo Negativo (Zona Proibida / Hard Deny Rules)

- ❌ Não implementar funcionalidades, instalar dependências, alterar configurações executáveis ou criar recursos de nuvem sem autorização apropriada.
- ❌ Não operar em produção, expor segredos, incluir `.env` em commits ou divulgar seu conteúdo.
- ❌ Não fazer ações destrutivas sem inspeção e confirmação; não fazer push sem autorização explícita.
- ❌ Não marcar tarefas OpenSpec como concluídas sem implementação integral e validação correspondente; completude de artefatos ou revisão automatizada não equivale a aprovação humana.
- ❌ Não alterar ou desabilitar testes para forçar aprovação, nem introduzir hardcoding para burlar asserções.
- ❌ Não inferir políticas de produto em aberto nem implementar comportamento que dependa delas.
- ❌ Preservar o registro de tentativas e execuções: a seção 6 é append-only; não remover entradas antigas.

---

## 4. Ancoragem de Contexto e Arquitetura

* **Padrão Arquitetural Utilizado:** monólito modular, DDD pragmático e Clean Architecture; direção aprovada de VSA pragmática em módulos por capacidade, com `backend/` e `frontend/` no mesmo repositório. Stack local definida: Next.js/TypeScript, FastAPI/Python e PostgreSQL em serviços separados via Docker Compose. Versões e configuração concreta ainda não validadas.
* **Dependências Principais:** frontend Next.js/TypeScript; backend FastAPI/Python; PostgreSQL. Não há versões validadas neste estado.
* **Decisões Decisivas Já Tomadas:**
  1. ADR-001 registra VSA pragmática, sessão opaca no servidor e persistência síncrona inicial. Driver, esquema, detalhes de sessão, locks e implementação ainda dependem de design/validação. GCP é possibilidade de portabilidade; nuvem está fora do escopo.
  2. OpenSpec é obrigatório no SDD, com governança humana e rastreabilidade fonte/versão → delta → tarefas → validação; artefatos não autorizam implementação.
  3. Regras aprovadas a preservar: pontuação 6/3/2/1/0; mata-mata pelo placar ao fim de 120 minutos sem gols de pênaltis; corte uma hora antes do kickoff oficial vigente; BRT (UTC−3); ranking/desempates conforme requisitos. Backend impõe prazo e autorização. Alteração oficial do kickoff pode reabrir a janela; nesse período novas leituras de palpites alheios ficam ocultas, sem restaurar confidencialidade de divulgações já observadas.
  4. Google/local: correspondência de e-mail somente após verificação do endereço local novo/alterado por código numérico de seis dígitos enviado a ele, até três tentativas por verificação (HU-22). Identidade Google já vinculada pode autenticar novamente a conta validada por `sub` (HU-23). Primeiro vínculo seguro por coincidência de e-mail, reenvio/reinício de tentativas, proteção do código e colisões ainda exigem decisão. Não confundir com aprovação administrativa ou recuperação HU-21.
  5. Proteger credenciais, sessões, tokens e dados pessoais; não expor palpites alheios antes do corte. Operações administrativas exigem autorização e auditoria; aplicar privilégio mínimo, validação e consultas parametrizadas; não alegar conformidade não verificada.
  6. Fonte normativa do produto: requisitos v3.4 (19/10/2026), além das decisões/pendências e documentos especializados indicados no `CLAUDE.md`.

### Implementação já registrada

- Login administrativo local de desenvolvimento: `backend/app/modules/identity/local_admin.py`, endpoints `POST/GET/DELETE /admin/session`, disponíveis somente com `ENVIRONMENT=development`.
- Senha via `LOCAL_ADMIN_PASSWORD`; configuração ausente/vazia rejeita login; não há senha literal no código.
- Sessão opaca em memória, cookie `HttpOnly`, revogação no logout; reiniciar backend perde sessões.
- Interface `frontend/features/admin-login.tsx`, montada na página inicial.
- Testes existentes em `backend/tests/api/test_local_admin.py` cobrem configuração ausente, credenciais, ambiente, cookie, sessão e logout.
- `.env` contém configuração local, está ignorado pelo Git e deve permanecer fora de commits e de qualquer divulgação.

### Verificações e ressalvas conhecidas

- Rodada anterior reportada como aprovada: `docker compose config --quiet`, `python3 -m compileall -q backend/app backend/tests`, `git diff --check`, `openspec validate --specs --strict` e `openspec validate local-admin-bootstrap-auth --strict`.
- Pytest e lint/type-check do frontend não foram executados por falta das dependências necessárias; nenhuma dependência foi instalada. Não declarar esses testes como aprovados.
- Na conferência anterior, `git diff --check` terminou sem erros. Nenhum teste de aplicação foi executado nesta conferência documental.

### Change `2026-10-19-identity-email-link`

- OpenSpec reportou artefatos de planejamento completos, mas apply reportou **0/6 tarefas concluídas**; todas permanecem desmarcadas em `openspec/changes/2026-10-19-identity-email-link/tasks.md`.
- A proposta identifica a change como documental e não aprovada para implementação. Completude dos artefatos ou avaliação por `review-loop` não equivale a aprovação humana.
- Decisões/revisões humanas pendentes antes dos fluxos dependentes: ciclo de vida de conta/solicitação (login pré-aprovação, rejeição, reativação, bloqueio e sequência confirmação/aprovação); política própria para confirmação de cadastro local (mecanismo, validade, consumo e limites, sem inferir HU-22); provisionamento administrativo fora do ambiente local e eventual troca obrigatória de senha; prova segura do primeiro vínculo Google/local e questões residuais TEC-01 (Google fora da primeira entrega proposta); autorização/auditoria de aprovação e rejeição, política de dados/migração e integração operacional de e-mail OPS-03; revisão humana de especificação/design/rastreabilidade com aprovador, data e escopo.

---

## 5. Fila de Tarefas (Backlog de Execução)

### Fase 1: Estado e governança documental
- [x] **Task 1.1:** Conferir branch, histórico recente, alterações locais e `git diff --check`; registrar fotografia sem inspecionar `.env`.
- [x] **Task 1.2:** Adaptar este `docs/STATE.md` ao `docs/STATE-template.md`, preservando as informações existentes e registrando a validação documental.

### Fase 2: Decisões e aprovação de produto (não autorizadas por artefatos)
- [/] **Task 2.1:** Obter da pessoa responsável as decisões pendentes e aprovação humana explícita da change e do escopo antes de implementar tarefas dependentes.
- [ ] **Task 2.2:** Revisar a especificação, o design e a rastreabilidade requisito → cenário → tarefa → teste, documentando aprovador, data e escopo conforme a governança.

### Fase 3: Validação e implementação condicionais
- [ ] **Task 3.1:** Quando dependências estiverem disponíveis e sua instalação for autorizada, executar pytest e validações de frontend; registrar resultados reais.
- [ ] **Task 3.2:** Só após decisões e aprovação, aplicar tarefas OpenSpec autorizadas, com cobertura/validação proporcional; não fazer push sem autorização explícita.

---

## 6. Log de Tentativas Descartadas e Aprendizados (Anti-Looping)

Nenhuma tentativa de implementação descartada foi identificada nos registros disponíveis. Não inventar tentativas. As observações de execução e conferência anteriores foram preservadas abaixo; adicionar novos registros somente ao final.

| Turno | Abordagem Testada | Resultado / Erro Observado | Causa Raiz | Ação Tomada / por que foi Descartado |
| :---: | :--- | :--- | :--- | :--- |
| Histórico anterior | Login administrativo local em desenvolvimento, configurado por ambiente | Implementação registrada nos commits `b4ddab0` e `6ce1a25`; testes do endpoint existentes. Pytest e validações frontend não executados por falta de dependências. | As dependências necessárias não estavam instaladas; instalação não foi autorizada/realizada. | Preservar a implementação existente; não afirmar que pytest ou verificações frontend passaram. |
| Histórico anterior | Tentativa de adicionar o symlink `.claude/skills/review-loop` | A tentativa de adicionar o caminho falhou. | Causa não detalhada no estado anterior. | Não foi feito workaround; o symlink aponta para `.agents/skills/review-loop/` e não deve ser commitado automaticamente. |
| Histórico anterior | Conferir estado da árvore Git após mudança de branch/commits | Branch `feat/local-admin-authentication`, `HEAD`/upstream em `160c635`; somente `CLAUDE.md` modificado, remoção de `docs/implementation-status-2026-10-27.md` e `docs/STATE.md` não rastreado. `git diff --check` sem erros. | Não aplicável; fotografia da árvore naquele momento. | Preservar como observação histórica, não como estado continuamente atualizado. |
| Turno atual | Adaptar `docs/STATE.md` ao template, preservando histórico e ressalvas | `git diff --check` terminou com código de saída 0, sem saída/erros. | Não aplicável; edição documental. | Concluído e validado; nenhuma validação de aplicação foi executada. |
| Turno atual | Criar commits convencionais separados por grupo lógico | Commits `aacd9be` e `38b5e94` criados. `git diff --cached --check` passou para ambos os conjuntos efetivamente commitados. Estado final: somente `docs/STATE-template.md` permanece não rastreado. | Validação inicial do staging amplo falhou por whitespace final preexistente no template e espaço acidental no estado; removido o espaço acidental e excluído o template do staging. | Commit separado para protocolo (`CLAUDE.md`) e estado (`docs/STATE.md` + remoção do relatório antigo). Template mantido fora do commit; nenhuma dependência ou teste de aplicação executado. |

---

## 7. Próximo Passo Imediato

* **Tarefa Atual:** `Task 2.1 — Obter decisões pendentes e aprovação humana explícita antes de implementar a change de cadastro/admissão.`
* **Ação Exata no Próximo Turno:** `Consultar a pessoa responsável para resolver as políticas pendentes e confirmar aprovação/escopo. Não implementar fluxos dependentes até haver decisão e aprovação registradas.`
* **Condição de Sucesso do Turno:** `Decisões e aprovação humana documentadas com escopo identificável; na ausência delas, manter implementação bloqueada e registrar a pendência, sem marcar tarefas OpenSpec concluídas.`

---

## 8. Protocolo de Manutenção Deste Arquivo (Regras do Sistema)

- Ler `docs/STATE.md` no início de cada turno de trabalho e após compactação de contexto.
- Trabalhar apenas na tarefa pendente selecionada, respeitando escopo negativo e precedência de requisitos/aprovações.
- Atualizar estado, fila, próxima ação e log ao final; a seção 6 é append-only. Marcar tarefa como concluída somente após verificação determinística com código de saída 0 quando aplicável.
- Se a mesma falha ou erro persistir por três turnos consecutivos, interromper modificações automatizadas, marcar `BLOQUEADO_HUMANO`, registrar causa raiz e três hipóteses descartadas, e solicitar orientação.
- Não declarar teste, aprovação ou implementação sem evidência verificável.

### Fotografia histórica preservada do estado anterior — 27/10/2026

- O estado anterior dizia que os commits `b4ddab0` (login admin local) e `6ce1a25` (senha local por ambiente) existiam no histórico e que, naquela fotografia, não havia evidência de push; mencionava `origin/main` em `c890d22`. Em conferência posterior, o branch observado já era `feat/local-admin-authentication`, alinhado ao upstream em `160c635`; o `HEAD` não era `loop`. Manter essas referências como fotografias em momentos distintos, não como afirmações simultâneas.
- O estado inicial listava como modificados os três artefatos da change `2026-10-19-identity-email-link` e `skills-lock.json`; não rastreado o symlink `.claude/skills/review-loop`; ignorados `.env` e artefatos/cache. Na conferência posterior, nenhum dos arquivos OpenSpec ou `skills-lock.json` apareceu como modificado. O estado atual da árvore pode ter mudado desde então; inspecionar novamente antes de qualquer ação Git.
- Próximos passos históricos preservados: ler requisitos v3.4 e decisões pendentes antes de alterar comportamento; confirmar decisões/aprovação humana; manter `.env` ignorado; instalar dependências apenas com autorização; executar validações faltantes quando possível; não fazer push sem autorização.
- O arquivo foi renomeado de `docs/implementation-status-2026-10-27.md` para `docs/STATE.md`; `CLAUDE.md` passou a exigir leitura/atualização do estado e leitura após compactações e no início de iterações de loop/goal.
