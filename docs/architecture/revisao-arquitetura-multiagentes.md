# Revisão arquitetural multiagentes — Bolão Copa FIFA 2027

**Data:** 18/10/2026
**Escopo:** análise e documentação; sem implementação, instalação, inicialização do OpenSpec ou alteração de configuração executável.
**Resultado:** recomendações arquiteturais consolidadas com as decisões de domínio confirmadas em 18/10/2026; permanecem abertas apenas as lacunas residuais descritas neste relatório e no registro canônico.

## 1. Resumo executivo

A base documental contém requisitos de produto detalhados, um registro de decisões e uma proposta arquitetural extensa. Porém, o repositório ainda não contém aplicação, configuração Docker Compose, dependências, testes ou ADRs. A topologia local e a stack estão definidas no escopo desta revisão, mas não implementadas. Windows 11 com WSL 2/Ubuntu é um ambiente requerido agora, embora o fluxo de arquivos, Docker Desktop, hot reload e diagnóstico ainda não estejam documentados nem validados.

A arquitetura recomendada é um monólito modular FastAPI/Python, organizado por funcionalidades e módulos coesos, com Next.js/TypeScript e PostgreSQL em serviços separados no Docker Compose local. Clean Architecture e DDD devem ser aplicados pragmaticamente: domínio sem dependência de framework, casos de uso explícitos, adaptadores apenas onde necessários e sem uma camada/interfaces por rotina. Não há justificativa observada para microserviços, filas ou cache distribuído. A produção não deve ser inferida como réplica do Compose local nem escolhida nesta revisão.

OpenSpec é obrigatório para especificação, planejamento e evolução SDD conforme o escopo decidido nesta revisão. O scaffold tem `schema: spec-driven`; os comentários explicativos devem ser alinhados com a obrigatoriedade, mantendo governança humana/manual. Não há specs ou mudanças OpenSpec reais. Artefatos completos não equivalem a aprovação para implementar.

As decisões de domínio confirmadas e incorporadas ao requisito v3.2 incluem interpretação da pontuação, ranking corrente e critério de rodada concluída, normalização de nomes e política de leitura/escrita durante reabertura do prazo. Permanecem lacunas sobre estados de partidas excepcionais, ponto confiável de entrada, garantia técnica de espera por gravações elegíveis, sequência de mudanças de kickoff e detalhes de governança/rastreabilidade. Essas lacunas não podem ser resolvidas por preferência arquitetural.

## 2. Método, fontes e limites

A revisão foi feita por inspeção documental e inventário do repositório, com análises paralelas independentes de domínio/DDD, OpenSpec/fluxo de trabalho, ambiente/containers e escopo/decisões. Os achados foram consolidados e duplicações removidas. Não foi executado código ou teste de runtime.

Precedência adotada: requisitos de produto aprovados → decisões de produto confirmadas → decisões arquiteturais aprovadas → especificações OpenSpec aprovadas dentro desses limites → recomendações técnicas. As instruções do projeto registram como direção técnica Next.js/TypeScript, FastAPI/Python, PostgreSQL, monólito modular, DDD pragmático, Clean Architecture, Vertical Slices, OpenSpec obrigatório e execução local Compose, em Windows 11 ou WSL 2/Ubuntu.

Fontes examinadas: `CLAUDE.md`; requisito v3.2 (incluindo histórico v3.1); proposta PROD-06 de badges; `docs/requirements/decisoes-pendentes.md`; `docs/architecture/arquitetura-software.md`; prompt arquitetural legado; `openspec/config.yaml`; estrutura de arquivos e estado Git. Os documentos técnicos listados na arquitetura são referências registradas por aquela proposta, não foram revalidados nesta revisão.

**Limites:** não há implementação, Dockerfiles/Compose, `.env.example`, testes, CI ou ADRs a validar. “Não encontrado” refere-se ao checkout inspecionado. Nenhuma compatibilidade de versões, hot reload, inicialização, health check, migração, Windows/Docker Desktop ou produção foi demonstrada empiricamente. Nesta sincronização documental, os comentários explicativos de OpenSpec foram alinhados à adoção obrigatória; schema, comportamento, CLI e comandos não foram alterados nem validados.

## 3. Fatos observados e status das decisões

### Fatos observados

- `docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md` é a fonte canônica de produto, versão 3.2, de 18/10/2026.
- `docs/requirements/decisoes-pendentes.md` registra decisões de produto e lacunas residuais. O aprovador organizacional não está identificado em vários registros.
- `docs/architecture/arquitetura-software.md` se declara proposta não aprovada. Seus módulos, modelo lógico, mecanismos de locking, transações, persistências e sequência de implementação são recomendações, não decisões arquiteturais formalmente aprovadas.
- O repositório contém `openspec/config.yaml` com `schema: spec-driven`; seus comentários devem ser harmonizados com a adoção obrigatória. `openspec/specs/` e `openspec/changes/archive/` não têm conteúdo além de `.gitkeep`; não foram encontrados specs, propostas ativas ou arquivadas.
- Há scaffolding de instruções/workflows OpenSpec em diretórios de agentes, mas isso não equivale a especificação de produto aprovada nem a execução de CI/testes.
- Não foram encontrados fonte de aplicação, Docker Compose/Dockerfiles, arquivos de ambiente de exemplo, manifests de dependências, testes, CI ou ADRs.
- A seção 27 da arquitetura contém um retrato Git obsoleto: diz que não há commits e que arquivos estão sem rastreamento; o checkout atual possui commits e os documentos-base estão versionados. Existem arquivos de workflow não rastreados, portanto não se deve pressupor que todo scaffold local seja canônico.

### Restrições desta revisão

Esta revisão toma como mandatórios, sem alterar regras de produto: Next.js/TypeScript; FastAPI/Python; PostgreSQL; monólito modular, DDD pragmático, Clean Architecture e Vertical Slices; OpenSpec no fluxo SDD; Docker Compose local com serviços separados ao menos para frontend, backend e banco, persistência local necessária e suporte a Windows 11 ou WSL 2 com Ubuntu. Produção é separada conceitualmente e não foi definida.

### Recomendações, ainda sujeitas a aprovação arquitetural

Os limites de módulo, o modelo de pastas, o uso de ORM, a estratégia de cálculo síncrono, detalhes de lock, cache, política de migrações e organização dos serviços são propostas. Esta revisão recomenda as opções simples detalhadas na arquitetura atualizada, mas não as declara formalmente aprovadas nem as transforma em requisitos de produto.

## 4. Achados por área

### 4.1 Domínio, DDD e limites de módulos

**Evidência:** os requisitos cobrem identidade/admissão, calendário e seleções, palpites, resultados, apuração, ranking, suporte e badges. A arquitetura já propõe módulos próximos desses conceitos, mas também inclui `administration` no exemplo de pastas sem linha correspondente na tabela de responsabilidades. A proposta de gamificação fala em depender de métricas de ranking, embora badges devam reconhecer fatos aprovados e não alterar pontos.

**Risco:** fronteiras apresentadas como contextos autônomos podem criar módulos artificiais, e dependência de badges sobre projeções de ranking pode acoplar regras independentes. “Administração” tende a ser papel/casos de uso autorizados nos módulos donos dos dados, não necessariamente domínio próprio.

**Recomendação:** manter módulos por capacidade de negócio, cada um dono de suas invariantes e dados; coordenar casos de uso por aplicação explícita. Tratar autorização administrativa e auditoria como políticas aplicadas nos casos de uso proprietários; só criar módulo transversal de administração se uma necessidade real exigir. Gamificação permanece fora da implementação automática até aprovação PROD-06; quando aprovada, consumir resultados oficiais/apuração por contrato mínimo, sem depender de ranking salvo critério aprovado que o exija. Não criar agregados ou camadas apenas para refletir a nomenclatura DDD.

### 4.2 Clean Architecture e Vertical Slices

**Evidência:** a arquitetura propõe domínio, aplicação e adaptadores dentro de módulos, com FastAPI/SQLAlchemy fora do domínio. A estrutura de frontend proposta separa `app`, `features`, componentes e `lib`.

**Risco:** replicar três subcamadas completas em cada módulo, criar interfaces para cada chamada ou manter estruturas duplicadas de domínio/transportes/schema aumentaria custo sem benefício demonstrado. O backend também não deve permitir que routers ou consultas de leitura contornem autorização/invariantes.

**Recomendação:** combinar slices verticais por funcionalidade com direção de dependência para regras de domínio. Criar portas/adaptadores apenas para dependências externas ou limites testáveis reais; permitir consultas de leitura específicas, sem duplicar regra e sempre aplicando autorização. No frontend, agrupar UI e cliente/contrato por feature, deixando componentes compartilhados pequenos; não adotar store global sem demanda. A estrutura de diretórios final deve nascer com a aplicação e ser validada pela equipe, não pré-criada nesta revisão.

### 4.3 Regras de negócio e pendências residuais

**Decisões consolidadas no requisito v3.2:**

1. **Ranking corrente:** usa somente resultados oficialmente apurados, sem pontuação provisória nem zero para partidas pendentes. O terceiro desempate usa todas as rodadas anteriores concluídas; para esse critério, a rodada conclui quando todas as partidas estão apuradas ou oficialmente canceladas/anuladas.
2. **Mudança de kickoff:** preservam-se PROD-02/05; alteração oficial pode reabrir o prazo. Durante a reabertura, participantes podem editar até o novo cutoff e novas consultas de palpites alheios ficam ocultas até então. Divulgação já observada não pode ser revertida.
3. **Pontuação:** “gols de uma equipe” significa acertar exatamente uma das contagens, após verificar placar exato.
4. **Ordenação de nomes:** normalizar ignorando acentos e caixa; nomes iguais após normalização permanecem empatados.

**Pendências residuais:**

5. **Partidas excepcionais:** adiamento e exclusão de cancelada/anulada têm decisões limitadas; efeitos de cancelamento em contagens/histórico, partidas suspensas/abandonadas/retomadas e badges permanecem sem política aprovada.
6. **Corte e concorrência:** permanece por definir o ponto confiável de ingresso, proxy, precisão/associação do timestamp e controles contra falsificação/replay. A decisão de produto determina que a publicação aguarde gravações elegíveis recebidas antes do corte; o mecanismo técnico ainda não está escolhido.
7. **Apuração e badges:** estado de apuração “definitiva”, autorização de correção e comunicação continuam abertos; PROD-06 também aguarda aprovação. A implementação automática de badges deve continuar bloqueada.

**Recomendação:** manter as lacunas no registro canônico e obter decisão humana antes de codificar comportamentos dependentes. Não ajustar requisitos para facilitar implementação nem tratar recomendações arquiteturais como resposta a lacunas de negócio.

### 4.4 Dados, transações e integridade

**Evidência:** a arquitetura recomenda dados oficiais versionados, pontuação derivada e idempotente, unicidade de palpite por participante/partida, constraints para gols não negativos e ranking reconstruível. Propõe serialização da edição do palpite e alteração do calendário, mas reconhece que a semântica do timestamp/driver precisa ser validada.

**Riscos:** uma projeção pode divergir após correção de resultado; atualizações concorrentes podem quebrar corte ou expor ranking parcialmente atualizado; exclusões em cascata podem remover auditoria/histórico; testes com SQLite não provariam locks e transações de PostgreSQL. A eventual complexidade de snapshots/versões pode ser prematura para um grupo e 64 partidas.

**Recomendação:** PostgreSQL como autoridade transacional; constraints para invariantes estáticas; transações explícitas por caso de uso; preservar revisão de resultado e auditoria; recálculo determinístico a partir de fontes autoritativas, com publicação coerente. Começar com projeção simples/recalculável e sem fila ou event sourcing. Escolher locking/isolamento e estratégia de projeção após teste de concorrência em PostgreSQL real e desenho confiável do ingresso. Não assumir retenção, cascata ou política de restauração. Cobrir idempotência, ranking, correção e migrações com testes integrados no próprio PostgreSQL quando houver aplicação.

### 4.5 OpenSpec e SDD

**Evidência:** há scaffold `spec-driven`, sem especificações ou mudanças. Os comentários de configuração devem ser alinhados à adoção obrigatória, sem sugerir governança automática. Há workflows locais, mas não uma convenção do projeto que prove aprovação, referência aos IDs de requisitos, tarefas e validação.

**Risco:** especificações completas podem ser confundidas com autorização de implementação; ausência de baseline dificulta identificar o requisito aprovado; configuração e instruções conflitantes fazem agentes escolherem processos diferentes. Não se deve presumir recursos, versão ou comandos da CLI ainda não verificados.

**Recomendação:** usar OpenSpec obrigatoriamente como estrutura de artefatos para mudanças, com governança humana manual. Fluxo mínimo proposto: explorar contexto e pendências; proposta com escopo/fora de escopo e IDs de origem; delta de especificação sem duplicar o requisito canônico; design apenas quando houver impacto estrutural/dados/segurança; tarefas; revisão e aprovação humana identificada antes de implementar quando exigido; validação ligada às tarefas/requisitos; arquivamento/sincronização após conclusão. Cada mudança aplicável deve mapear requisito/decisão e versão → cenário/delta → tarefa → teste/evidência; registrar explicitamente “sem alteração de regra” quando pertinente. Decidir se specs-base serão uma projeção curada de requisitos ou se mudanças citarão diretamente as fontes canônicas. Aprovação deve registrar responsável, data, escopo e artefatos/versões; “pronto para implementação” não significa “aprovado”. Validar detalhes com a versão escolhida antes de usar comandos. Os comentários da configuração devem afirmar o uso obrigatório e deixar claro que governança e aprovações são humanas.

### 4.6 Desenvolvimento local, Windows 11 e WSL 2

**Evidência:** decisão TEC-02 fixa Compose, frontend/backend/banco separados, volumes locais e Dev Container opcional. O checkout não tem Compose ou instruções para Windows 11, WSL 2, Docker Desktop, caminhos, hot reload, portas, rede, health checks, migrações ou diagnóstico.

**Recomendação de desenho (a validar, não verificada):**

- Tratar Docker Desktop com integração WSL 2/Ubuntu como caminho Windows a documentar, e execução Compose nativa Linux como referência de compatibilidade. Manter o repositório no filesystem Linux da distribuição WSL para o fluxo em WSL, em vez de assumir equivalência de bind mounts sob `/mnt/c`; medir watchers/permissões e confirmar as recomendações oficiais da versão efetivamente escolhida.
- Separar serviços `frontend`, `backend` e `db` no Compose local. O browser precisa acessar o frontend publicado no host; a comunicação interna frontend/API e API/PostgreSQL deve usar nomes de serviço/rede interna, não endereços do host embutidos. Não publicar o banco à rede além do necessário ao desenvolvedor.
- Usar volume nomeado local para o diretório de dados PostgreSQL, com ciclo de vida e aviso explícito de que não é backup. Bind mounts de código e hot reload pertencem ao perfil de desenvolvimento; dados persistentes adicionais só devem ganhar volume quando a aplicação tiver esse dado identificado.
- Separar disponibilidade do processo e prontidão para receber tráfego. Banco deve sinalizar prontidão antes do backend executar migrações/servir; ordem de inicialização não substitui retry e diagnóstico. Definir se migrações serão comando explícito/serviço pontual ou passo controlado, evitando múltiplos containers executarem migração concorrente sem coordenação.
- Documentar portas, variáveis requeridas e valores exemplificativos sem segredo em `.env.example`; esclarecer que arquivos com segredos não entram no Git. Incluir diagnóstico para container parado, dependência não pronta, conflito de porta, bind mount/permissão e hot reload. Não inventar comandos até fixar versões/ferramentas.
- Testar inicialização limpa, reinício/recriação mantendo dados, comportamento de hot reload, rede e migrações nos dois ambientes suportados. A experiência deve ser reproduzível, mas não há validação possível até existir Compose.

### 4.7 Segurança e operação

**Evidência:** requisitos e CLAUDE exigem autorização backend, privacidade de palpites, proteção de credenciais e trilha de auditoria. Arquitetura recomenda cookies seguros, CSRF quando aplicável, rate limit, logging estruturado e segredo em runtime. Identidade/sessão, associação Google/local, retenção, acesso administrativo pré-corte, exclusão e provedor de e-mail têm lacunas.

**Riscos:** camada visual/cache não protege confidencialidade; logs e traces podem vazar palpites antes do corte ou tokens; configuração de sessão ainda não decidida; operações administrativas sem matriz de autorização podem exceder privilégio; volume persistente pode gerar falsa expectativa de recuperação.

**Recomendação:** manter autorização e visibilidade em cada rota/consulta do backend, respostas privadas sem cache compartilhado, logs sem segredos/PII ou palpites pré-corte, privilégio mínimo e auditoria de ações administrativas. Escolher autenticação, sessão, CSRF, rate limiting, e-mail e retenção antes da implementação do fluxo correspondente. Não alegar conformidade, backup, restauração ou controles executados que não foram demonstrados.

### 4.8 Produção, documentação e agentes

**Evidência:** GCP é uma referência histórica/de portabilidade, sem decisão de produção, deployment ou operação. O prompt `PROMPT-ARQUITETURA-CLAUDE-CODE.md` conserva pressupostos anteriores sobre GCP e localização de pendências; não deve prevalecer sobre os documentos vigentes. O `CLAUDE.md` define OpenSpec obrigatório e governança manual.

**Recomendação:** não projetar produção por analogia com Compose. Registrar depois, em decisão separada, ambiente, operação, disponibilidade, recuperação, região e gestão de segredos antes de qualquer implantação. Manter `CLAUDE.md` curto como índice de fontes e limites; decisões de produto ficam no registro de requisitos, decisões arquiteturais neste diretório e detalhe por mudança nos artefatos OpenSpec. Tratar o prompt antigo como referência histórica ou corrigir seus pressupostos numa alteração posterior; não criar `AGENTS.md` por conveniência. Identificar quais diretórios de workflow não rastreados serão mantidos antes de considerá-los fonte canônica.

## 5. Arquitetura recomendada em síntese

| Área | Recomendação | Status |
|---|---|---|
| Frontend | Next.js + TypeScript; cliente por feature e UI acessível | Restrição do escopo; versões e detalhes pendentes |
| Backend | FastAPI + Python, monólito modular por capacidade de negócio | Restrição de stack; limites finos e versões devem ser aprovados |
| Persistência | PostgreSQL; backend é o único serviço de aplicação com acesso ao banco | Restrição do escopo; schema/migrações não implementados |
| Estilo | DDD pragmático, Clean Architecture e Vertical Slices, com dependências explícitas e poucas abstrações | Restrição/recomendação; evitar camadas mecânicas |
| Desenvolvimento | Compose local: frontend, backend e PostgreSQL em serviços distintos; volume local persistente para dados do banco | Obrigatório; Compose inexistente e compatibilidade a validar |
| Plataforma suportada | Windows 11 por Docker Desktop/WSL 2 com Ubuntu e ambiente WSL 2/Linux | Obrigatório nesta revisão; instruções e testes ausentes |
| Produção | Não presumida como a topologia de desenvolvimento; destino e operação fora desta definição | Decisão ainda necessária em outro escopo |
| SDD | OpenSpec obrigatório; revisão/aprovação manual, rastreabilidade por mudança | Obrigatório; baseline e convenções de projeto ainda pendentes |

## 6. Decisões e ações humanas

1. **Produto — partidas excepcionais/badges:** completar consequências de canceladas/anuladas em contagens e histórico, além de suspensas, abandonadas/retomadas em pontuação, ranking, histórico e badges; aprovar PROD-06 separadamente.
2. **Técnica — corte:** escolher ponto confiável de ingresso e definir associação/auditoria do timestamp, garantias técnicas para aguardar gravações elegíveis e controles contra replay; testar caminho HTTP/infra real.
3. **Técnica — ambiente local:** selecionar versões suportadas e decidir forma de Compose, mounts, hot reload, portas, health/readiness, política de migrações e diagnóstico para Windows/WSL/Linux.
4. **Processo — OpenSpec:** aprovar convenção mínima de baseline/rastreabilidade e registro de aprovação; escolher/confirmar versão antes de documentar comandos.
5. **Técnica — identidade/operação:** resolver sessão, contas Google/locais, e-mail, retenção/exclusão, acesso administrativo, logging e recuperação conforme decisões pendentes existentes.
6. **Arquitetura — produção:** não inferir implantação em nuvem; solicitar definição de produção e operação em escopo próprio, antes de assumir topologia ou controles não aprovados.
7. **Produto/operação — calendário:** definir sequência de alterações sucessivas de kickoff e comunicação aos participantes, preservando as decisões aprovadas de cutoff, reabertura, visibilidade e auditoria.

O registro canônico existente `docs/requirements/decisoes-pendentes.md` mantém as decisões e lacunas de produto, operação e processo; não foi criado um segundo registro em `docs/architecture/` para evitar divergência. As recomendações arquiteturais permanecem nesta arquitetura e neste relatório.

## 7. Validação desta revisão

A validação foi documental: comparação cruzada das fontes, checagem de caminhos/links e separação de fatos, decisões, propostas e pendências. Não havia suíte de testes nem configuração executável para rodar. Não foram testados Docker Compose, Windows 11, WSL 2, hot reload, migrações ou operação em produção. A ausência de tais testes é um limite declarado, não uma aprovação de compatibilidade.
