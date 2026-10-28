# Instruções do projeto — Bolão Copa FIFA 2027

## Contexto e precedência

Este repositório prepara um bolão web para um grupo único da Copa do Mundo Feminina da FIFA Brasil 2027. A fonte normativa do produto é [`docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md), v3.4 (19/10/2026). Consulte os documentos especializados antes de decidir ou alterar a área correspondente; links aqui são referências, não conteúdo carregado automaticamente.

## 🔄 Protocolo de Automação de Ciclo &amp; Estado Persistente (`STATE.md`)

Como a janela de contexto é efêmera e passa por compacção automática (`/compact`), o arquivo `STATE.md` na raiz do repositório é sua **âncora cognitiva primária e memória persistente em disco**. Você deve seguir rigorosamente o ciclo de leitura e escrita abaixo em TODOS os turnos de trabalho. O documento STATE.md deve seguir o conteúdo e formato do  template STATE-template.md.

Todo LOOP (engineering loop) deve ser executado com a skill review-loop para revisão.

### 1. Leitura &amp; Reidratação (Início de Cada Turno / Pós-Compacção)

Antes de executar qualquer tarefa ou criar código com qualquer agente ou subagente:

1. **Leia obrigatoriamente** o arquivo [`docs/STATE.md`](docs/STATE.md).
2. Reidrate sua consciência situacional consultando:
   - O **Objetivo Global** e a **Zona Proibida (Escopo Negativo)**.
   - O estado atual da **Fila de Tarefas** e a próxima tarefa marcada como em andamento `[/]`.
   - O histórico de **Tentativas Descartadas** para nunca repetir estratégias que já falharam.
3. Se o status global no `STATE.md` estiver como `BLOQUEADO_HUMANO` ou `CONCLUIDO`, interrompa a execução e reporte a situação ao usuário.

### 2. Regras de Execução Durante o Turno

- Trabalhe **exclusivamente** na tarefa pendente selecionada no `STATE.md`.
- Respeite rigorosamente as restrições do Escopo Negativo (ex.: é proibido alterar arquivos de teste para forçar aprovação).
- Exija verificação determinística (ex.: execução de `npm test`, `pytest` ou linter com código de saída 0) antes de considerar qualquer alteração concluída.

### 3. Atualização Append-Only &amp; Persistência (Fim do Turno)

Antes de concluir sua resposta no turno ou acionar a validação do `/goal` / `Stop Hook`:

1. **Preservação do Histórico (Append-Only):** NUNCA apague ou sobrescreva entradas antigas no registro de execuções. A seção `## 📜 Log do Histórico (Append-Only)` deve receber novas entradas exclusivamente via **acréscimo de novas linhas ao final**.
2. Anexe a nova entrada contendo:
   - `| [Data/Hora] | Turno N | [Sucesso/Falha] | Ação executada e resultado dos testes determinísticos |`
3. Atualize o cabeçalho de estado e a lista de tarefas:
   - Altere a tarefa atual de `[/]` para `[x]` **somente se** a verificação determinística retornou código de saída 0.
   - Atualize os campos `Última Atualização` e `Próximo Passo Imediato`.

### 4. Trava de Segurança contra Loops Infinitos (Circuit Breaker)

- Se o histórico no `STATE.md` registrar que a **mesma falha ou erro persistiu por 3 turnos consecutivos**:
  1. Interrompa imediatamente modificações automatizadas de código.
  2. Altere o status global no `STATE.md` para `BLOQUEADO_HUMANO`.
  3. Registre no arquivo a causa raiz identificada e as 3 hipóteses descartadas, solicitando orientação do desenvolvedor.

## Direção e limites essenciais

- Stack e topologia local definidas: Next.js/TypeScript, FastAPI/Python e PostgreSQL em serviços separados via Docker Compose. Desenvolvimento deve suportar Windows 11 com WSL 2/Ubuntu e Linux. Versões, configuração concreta e compatibilidade ainda não estão validadas.
- Direção arquitetural: monólito modular, DDD pragmático e Clean Architecture, sem abstrações desnecessárias. [ADR-001](docs/architecture/decisoes-tecnicas/ADR-001-vsa-monorepo-e-persistencia.md) registra as direções aprovadas em 19/10/2026: VSA pragmática em módulos por capacidade com `backend/` e `frontend/` no mesmo repositório, sessão opaca no servidor e persistência síncrona inicial. Driver, esquema, detalhes de sessão, locks e implementação continuam sujeitos a design e validação. GCP é apenas possibilidade de portabilidade; implantação e operação em nuvem estão fora do escopo.
- OpenSpec é obrigatório no SDD, com governança e aprovações humanas. Relacione fonte/versão → delta → tarefas → validação; não trate conclusão dos artefatos como autorização de implementação.
- Preserve as regras aprovadas: pontuação 6/3/2/1/0; mata-mata pelo placar ao fim de 120 minutos, sem gols de pênaltis; corte uma hora antes do kickoff oficial vigente; BRT (UTC−3); ranking e desempates conforme requisito. O backend impõe prazo e autorização. Alteração oficial do kickoff pode reabrir a janela; durante a reabertura, novas leituras de palpites alheios ficam ocultas, sem restaurar confidencialidade de divulgações já observadas. Não invente política para situações pendentes.
- Vincule Google/local por correspondência de e-mail somente após verificação do endereço local novo ou alterado por código numérico de seis dígitos enviado a ele, com até três tentativas por verificação (HU-22). Identidade Google já vinculada pode autenticar novamente a conta validada por `sub` (HU-23); primeiro vínculo seguro por coincidência de e-mail, reenvio/reinício de tentativas, proteção do código e colisões ainda exigem decisão. Não confunda com aprovação administrativa ou recuperação HU-21. Proteja credenciais, sessões, tokens e dados pessoais; não exponha palpites alheios antes do corte. Operações administrativas exigem autorização e auditoria. Use privilégio mínimo, validação e consultas parametrizadas; não alegue conformidade não verificada.
- Não implemente funcionalidades, instale dependências, altere configurações executáveis ou crie recursos de nuvem sem autorização apropriada. Não opere em produção, não exponha segredos e não faça ações destrutivas sem inspeção e confirmação.

## Mapa de consulta (abrir antes de trabalhar)

| Tipo de trabalho                          | Fontes a consultar                                                                                                                                                                                                                                                                                                                                           |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Regra ou comportamento do produto         | [Requisitos v3.4](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md) e [decisões/pendências](docs/requirements/decisoes-pendentes.md); verificar aprovação e lacunas antes de propor mudança.                                                                                                                                                   |
| Arquitetura, dados, segurança ou operação | [Arquitetura](docs/architecture/arquitetura-software.md) e [revisão arquitetural](docs/architecture/revisao-arquitetura-multiagentes.md); recomendações não aprovadas não prevalecem sobre requisitos.                                                                                                                                                       |
| Badges/gamificação                        | [PROD-06](docs/requirements/PROD-06-criterios-badges-gamificacao.md); critérios considerados aprovados em 19/10/2026 (registro em decisões pendentes), mas a implementação segue OpenSpec e permanecem bloqueados resultado definitivo (PROD-06.5), partidas canceladas/anuladas (PROD-06.6) e reabertura de prazo; badges não alteram pontos nem desempate. |
| Especificação ou evolução de mudança      | [`openspec/config.yaml`](openspec/config.yaml), artifacts existentes em `openspec/` e comandos/skills OpenSpec disponíveis. Preservar governança humana; não inicializar nem mudar configuração sem solicitação.                                                                                                                                             |
| Instruções de agentes                     | Este `CLAUDE.md` é o ponto de entrada do Claude Code. Documentos em `docs/` são consultados sob demanda; comandos e skills em `.claude/` aplicam-se quando acionados. Não presuma que arquivos de outras ferramentas ou diretórios não rastreados sejam instruções canônicas.                                                                                |

## Qualidade e execução

Faça mudanças pequenas e revisáveis. Consulte documentação oficial correspondente às versões selecionadas; não invente versões, comandos, dependências ou scripts. Cubra regras de domínio, autorização, concorrência, idempotência, ranking e migrações com validação proporcional. Não há aplicação nem comandos de build/teste confirmados no repositório; não declare testes executados sem executá-los. Não crie `AGENTS.md` sem necessidade concreta de compatibilidade identificada.

## Uso de subagentes

O Claude Code descobre automaticamente os subagentes definidos em `.claude/agents/`; seus papéis e limites devem permanecer nos respectivos perfis, sem duplicação nesta instrução. Delegue quando a especialização ajudar a tarefa, mantendo coordenação e escopo claros. Requisitos aprovados e decisões humanas prevalecem sobre recomendações dos agentes. Nenhum agente resolve lacunas de produto, aprova mudanças em nome do usuário ou transforma artefatos OpenSpec em autorização de implementação.
