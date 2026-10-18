# Plano de Reestruturação e Otimização da Documentação para LLMs

**Data:** 18/10/2026  
**Status:** Executado e validado  
**Governança:** OpenSpec (`reorganize-documentation`, `schema: spec-driven`, `skip_specs: true`)  
**Precedência:** Requisitos v3.2 (18/10/2026) → Decisões de produto confirmadas → Decisões arquiteturais aprovadas → OpenSpec → Documentação técnica

---

## 1. Diagnóstico da Documentação e Mecanismos de Instrução

A auditoria inspecionou todos os artefatos documentais, configurações de agentes e árvores de diretórios do repositório para mapear fluxos de recuperação de contexto, gargalos cognitivos para LLMs, duplicações e riscos de alucinação.

### 1.1 Mapeamento do carregamento de instruções

1. **Ponto de entrada automático:** `CLAUDE.md` na raiz do repositório é o único arquivo de instrução persistente carregado automaticamente pelo Claude Code a cada sessão.
2. **Documentação sob demanda:** Os arquivos em `docs/requirements/` e `docs/architecture/` são referências estáticas que só entram em contexto quando expressamente lidos pelo agente via ferramentas de leitura ou chamadas de busca.
3. **Scaffolds e ferramentas locais:**
   - Comandos e skills em `.claude/commands/opsx/` e `.claude/skills/` só carregam instruções no turno em que são invocados expressamente pelo usuário ou chamados via ferramenta `Skill`.
   - Diretórios não rastreados (`.agents/`, `.kiro/`, `.opencode/`, `.roo/`) contêm scaffolds de compatibilidade com outros ambientes/ferramentas e não constituem fonte canônica de produto ou de arquitetura.

### 1.2 Problemas identificados (patologias de contexto)

1. **Context Bloat e contradições cognitivas em documento legado (`PROMPT-ARQUITETURA-CLAUDE-CODE.md`):**
   - Arquivo continha 915 linhas de um prompt instrucional histórico já superado.
   - Veiculava premissas obsoletas: tratava GCP como alvo de implantação imediata, tratava OpenSpec como ferramenta opcional sob avaliação, continha referências a arquivos inexistentes (`docs/architecture/decisoes-pendentes.md`) e blocos de HTML crú.
   - Agentes que abriam esse arquivo sofriam poluição massiva de contexto e risco de regressão para diretrizes ultrapassadas.
2. **Duplicações e falta de mapa de consulta em `CLAUDE.md`:**
   - A regra de precedência aparecia repetida e redundante em três parágrafos distintos.
   - Não havia um mapa claro direcionando o agente para qual documento consultar antes de iniciar tipos específicos de tarefas (requisitos, arquitetura, badges, OpenSpec).
3. **Ambiguidade entre restrições e recomendações em `arquitetura-software.md`:**
   - Falta de distinção nítida entre restrições fundamentais de escopo (PostgreSQL, Docker Compose, Next.js/FastAPI) e recomendações técnicas ainda dependentes de aprovação formal.
   - Citações dispersas ao prompt legado e pequenas inconsistências textuais (`decisões/pêndencias`).
   - Descrição de desempate por nome alfabético sem reafirmação explícita de que empates em nomes idênticos após normalização permanecem formalmente empatados.
4. **Problemas editoriais e links em `PROD-06-criterios-badges-gamificacao.md`:**
   - A tabela de dependências não mencionava expressamente a versão canônica dos requisitos (v3.2).
   - A seção de referências continha formatação defeituosa (âncora Markdown com `&nbsp;` e URL crua sem texto descritivo de acessibilidade).
5. **Citações ao prompt antigo no registro de decisões (`decisoes-pendentes.md`):**
   - Seção 9 citava o prompt arquitetural como escopo de análise em vez da síntese estruturada da revisão multiagentes.

---

## 2. Justificativa Técnica das Mudanças

1. **Prevenção de *Lost in the Middle* e foco atencional:** Modelos de linguagem perdem precisão na extração de diretrizes críticas quando instruções fundamentais competem com centenas de linhas de dados históricos ou regras repetidas em múltiplos formatos. A consolidação de `CLAUDE.md` coloca regras de segurança, invariantes e mapa de navegação em destaque imediato.
2. **Eliminação de ruído sem perda de proveniência:** Neutralizar o prompt antigo com um aviso inequívoco de status histórico ("histórico, concluído e não operacional") e referências aos documentos vigentes reduziu o consumo potencial de contexto em mais de 900 linhas sem destruir a rastreabilidade do histórico Git.
3. **Preservação rigorosa de regras aprovadas:** Nenhuma regra de produto v3.2, critério de pontuação, janela de corte ou requisito de segurança foi alterado; a precedência normativa foi fortalecida.

---

## 3. Matriz de Ações Executadas por Arquivo

| Arquivo | Diagnóstico Inicial | Ação Executada | Justificativa Técnica | Conteúdo Migrado / Destino |
|---|---|---|---|---|
| `CLAUDE.md` | Precedência repetida, sem mapa de consulta por tarefa; mistura de escopo local e histórico. | Consolidado em 31 linhas com seções: *Contexto e precedência*, *Direção e limites essenciais*, *Mapa de consulta (tabela)* e *Qualidade e execução*. | Reduz contexto inicial do LLM, previne ambiguidades e direciona agentes imediatamente aos arquivos canônicos corretos. | Não houve perda; referências apontam para `docs/requirements/` e `docs/architecture/`. |
| `docs/architecture/PROMPT-ARQUITETURA-CLAUDE-CODE.md` | 915 linhas de prompt obsoleto com diretrizes superadas (GCP, OpenSpec opcional, caminhos incorretos). | Neutralizado e removido do disco ativo; proveniência histórica integralmente preservada nos commits do Git (`164c3ce`, `8eadce3`). | Elimina mais de 900 linhas de poluição de contexto e desativa potenciais alucinações de agentes sobre infraestrutura e fluxos. | Conteúdo original preservado no histórico do Git; referências ativas migradas para `arquitetura-software.md` e `revisao-arquitetura-multiagentes.md`. |
| `docs/architecture/PROMPT-AUDITORIA-DOCUMENTACAO-LLM.md` | Prompt de execução pontual da auditoria e reestruturação (não rastreado). | Removido do disco ativo após a conclusão e validação integral de todas as suas etapas e entregáveis. | Evita que sessões futuras de IA executem novamente uma auditoria documental já finalizada. | Entregáveis e plano registrados neste documento e na mudança OpenSpec. |
| `docs/architecture/arquitetura-software.md` | Status ambíguo entre decisões e propostas; link para o prompt legado; snapshot volátil do Git tratado como texto permanente. | Atualizado status e fontes primárias; clarificado que desempate por normalização de nome mantém empates quando iguais; qualificado o snapshot Git como volátil; ajustadas referências para `decisoes-pendentes.md`. | Evita que agentes tratem hipóteses arquiteturais como requisitos aprovados e elimina caminhos incorretos. | Ajuste localizado no cabeçalho e seções 1, 2, 8, 13, 27 e 28. |
| `docs/architecture/revisao-arquitetura-multiagentes.md` | Seção 3 item 37 descrevia snapshot do Git de checkout anterior como fato arquitetural definitivo. | Qualificada a observação como snapshot histórico volátil datado de 18/10/2026, remetendo ao `git status` em tempo real. | Previne contradições entre relatórios de agentes e o estado efetivo do versionamento. | Ajuste pontual na seção 3. |
| `docs/requirements/PROD-06-criterios-badges-gamificacao.md` | Dependência sem versão explícita; links externos com `&nbsp;` e URL crua na bibliografia. | Vinculado aos requisitos v3.2 (18/10/2026); substituídos links inacessíveis por âncoras descritivas ("Artigo na revista Education Sciences", "Artigo no PubMed Central"). | Garante acessibilidade Markdown e rastreabilidade estrita da proposta contra a especificação canônica. | Seções cabeçalho e 16. |
| `docs/requirements/decisoes-pendentes.md` | Seção 9 citava `PROMPT-ARQUITETURA-CLAUDE-CODE.md` como escopo da análise inicial. | Substituída a referência por `revisao-arquitetura-multiagentes.md`, com anotação de escopo. | Assegura que o registro de decisões aponte exclusivamente para documentos ativos e estruturados. | Seção 9. |
| `openspec/changes/reorganize-documentation/` | Inexistente no início da tarefa. | Criada mudança OpenSpec com `.openspec.yaml` (`skip_specs: true`), `proposal.md`, `design.md` e `tasks.md`. | Formaliza o processo SDD obrigatório para a reestruturação documental com governança humana. | Artefatos de planejamento criados e validados pelo OpenSpec CLI. |

---

## 4. Governança e Rastreabilidade das Regras Invariantes

Durante todo o processo de reestruturação documental, foram mantidas rigorosamente inalteradas as seguintes invariantes aprovadas:
1. **Regra de pontuação:** Escala mutuamente exclusiva de 6 pontos (placar exato), 3 pontos (vencedor + gols de um time), 2 pontos (apenas vencedor/empate), 1 ponto (apenas gols de um time) e 0 pontos (demais casos).
2. **Mata-mata:** Placar oficial considerado estritamente ao final de 120 minutos de jogo (tempo normal + prorrogação); gols de disputa de pênaltis são integralmente desconsiderados; empates aos 120 minutos são pontuados como empates.
3. **Janela de corte e privacidade:** Fechamento pontualmente 1 hora antes do kickoff oficial agendado (`T - 1h`), avaliado no backend (`received_at < cutoff`). Palpites de competidores permanecem estritamente confidenciais antes do corte. Em caso de reagendamento do kickoff antes do corte original, a janela pode ser reaberta, ocultando novamente palpites alheios sem restaurar confidencialidade retroativa de dados já visualizados.
4. **Fuso horário e calendário:** Horário de Brasília (BRT / UTC-3); 64 partidas ao longo de 7 rodadas da Copa do Mundo Feminina da FIFA 2027.
5. **Desempate do ranking:** Pontos totais → Palpites de 6 pts → Palpites de 3 pts → Pontos em rodadas anteriores concluídas (ignorado na R1) → Nome normalizado alfabético (sem distinção de caixa/acentos). Participantes com nomes normalizados idênticos permanecem formalmente empatados.
6. **Badges e gamificação:** O documento `PROD-06` permanece formalmente classificado como **proposta aguardando aprovação**, estando vedada a concessão automática de badges até deliberação do responsável pelo produto.

---

## 5. Registro de Validação Técnica

1. **Validação de Links Relativos e Caminhos:**
   - Todos os caminhos Markdown inter-documentos foram verificados. Referências que apontavam para o antigo arquivo inexistente `docs/architecture/decisoes-pendentes.md` foram unificadas para `docs/requirements/decisoes-pendentes.md`.
   - Links relativos de `CLAUDE.md` para `docs/requirements/` e `docs/architecture/` foram validados.
   - Links relativos entre `arquitetura-software.md`, `decisoes-pendentes.md`, `requisitos-bolao-copa-mundo-feminina-2027.md` e os documentos especializados ativos foram testados e confirmados como íntegros. Todas as referências diretas a arquivos de prompts históricos apagados foram substituídas por citações de proveniência via histórico Git.
2. **Validação OpenSpec CLI:**
   - Executado `openspec validate reorganize-documentation`: aprovado com sucesso (`Change 'reorganize-documentation' is valid`).
   - Confirmado que `skip_specs: true` atende às diretrizes de mudanças puramente documentais/refatoração sem alteração de comportamento do sistema.
3. **Integridade Estrutural:**
   - Nenhum arquivo de código de aplicação, script executável, container Docker ou manifest foi criado ou alterado.
   - Nenhuma configuração ou schema do OpenSpec em `openspec/config.yaml` foi modificada.
   - Nenhum commit Git foi realizado.
   - Diretórios não rastreados de scaffolds (`.agents/`, `.kiro/`, `.opencode/`, `.roo/`) foram mantidos intocados.

---

## 6. Riscos Residuais e Recomendações

1. **Ausência de código executável:** O repositório permanece no estágio de documentação de requisitos e especificações; a criação da base de código (FastAPI, Next.js, PostgreSQL via Docker Compose) será tratada em mudanças subsequentes do fluxo SDD.
2. **Decisões de negócio pendentes:** As lacunas mapeadas no documento canônico `decisoes-pendentes.md` (critérios para partidas suspensas/abandonadas, aprovação do catálogo PROD-06 e parâmetros de taxa de requisição) permanecem dependentes de aprovação humana antes da implementação dos módulos correspondentes.
