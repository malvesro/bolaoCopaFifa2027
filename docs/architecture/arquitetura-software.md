# Arquitetura de Software — Bolão da Copa do Mundo Feminina da FIFA Brasil 2027

**Versão:** 0.4 (alinhamento das direções aprovadas em 19/10/2026)
**Elaboração:** 18/10/2026; atualização: 19/10/2026
**Status:** Proposta arquitetural com direções aprovadas delimitadas no [ADR-001](decisoes-tecnicas/ADR-001-vsa-monorepo-e-persistencia.md). Demais mecanismos e detalhes deste documento permanecem recomendações até decisão específica.
**Fonte primária do produto:** [requisitos v3.4](../requirements/requisitos-bolao-copa-mundo-feminina-2027.md), de 19/10/2026 (regras v3.2 preservadas).

> Este documento reúne restrições de escopo, as direções aprovadas no ADR-001 e recomendações arquiteturais; não descreve componentes implementados nem aprova regras de produto. As regras aprovadas permanecem na [fonte de requisitos](../requirements/requisitos-bolao-copa-mundo-feminina-2027.md). O desenvolvimento local será via Docker Compose em Windows 11 com WSL 2/Ubuntu ou ambiente Linux; produção não é presumida como idêntica e GCP não está selecionado. O [registro de decisões pendentes](../requirements/decisoes-pendentes.md) é a fonte canônica para pendências de produto, operação e processo; não há registro paralelo nesta arquitetura.

## 1. Resumo executivo

A topologia local obrigatória é Docker Compose com serviços separados para frontend Next.js/TypeScript, API FastAPI/Python e PostgreSQL, e volumes locais para dados que precisam sobreviver à recriação de containers (incluindo os dados PostgreSQL). O ambiente suportado inclui Windows 11 com Docker Desktop e WSL 2/Ubuntu, além de WSL 2/Linux. O Dev Container no VS Code pode ser usado, mas não é obrigatório. Volumes locais não constituem backup. Existe um scaffold de Compose (`docker-compose.yml`, `.env.example` e Dockerfiles), ainda não validado por execução; a compatibilidade precisa ser verificada.

A arquitetura deve facilitar portabilidade futura ao GCP, mas implantação e gerenciamento de recursos GCP não fazem parte do projeto. Não se prescrevem Cloud Run, Cloud SQL, CI/CD de produção, operação de nuvem, objetivos de recuperação nem serviços gerenciados como entregáveis.

As propriedades críticas permanecem integridade temporal e privacidade dos palpites, apuração idempotente, auditoria administrativa e ranking determinístico. Validações de domínio pertencem ao backend. Conta Google e identidade local usam correspondência por e-mail para o primeiro vínculo, após verificação do endereço local novo ou alterado por código numérico de seis dígitos enviado ao endereço, com até três tentativas por verificação (HU-22). Identidade Google já vinculada pode voltar a autenticar a conta validada, reconhecida por `sub` (HU-23). Fluxo seguro do primeiro vínculo e detalhes de sessão ainda exigem especificação; HU-21 mantém recuperação separada.

Em 19/10/2026 existem apenas scaffold (entrypoint de healthcheck, manifests de dependências, Compose e Dockerfiles); não há regra de negócio implementada, dados de partidas, testes nem comandos de build/teste confirmados por execução. Esta documentação não cria esses artefatos nem implementa funcionalidades.

## 2. Objetivo e escopo

Preparar decisões técnicas e um plano incremental para o produto definido em `docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`. O produto atende um grupo único, sem ligas públicas ou multi-tenancy, para 32 seleções, 8 grupos e 64 partidas previstas entre 24/06 e 25/07/2027. Resultados são inseridos por administradores; API paga de resultados, vídeo e movimentação financeira estão fora do escopo aprovado.

Incluem-se decisões e recomendações de arquitetura para desenvolvimento local, segurança, persistência, testes e portabilidade. A implantação e gestão GCP não fazem parte do escopo. Não se incluem implementação, telas funcionais, endpoints, migrações, criação de infraestrutura ou scripts de deploy.

## 3. Fontes consultadas e hierarquia

### Fontes do projeto

1. `docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`, versão 3.4, 19/10/2026 — fonte canônica; complementa HU-22 e acrescenta HU-23 às regras v3.2 preservadas.
2. Prompt histórico de elaboração arquitetural (preservado no histórico Git anterior à reestruturação documental) — orientou a análise inicial; não é instrução vigente nem aprovação de decisões técnicas.
3. `docs/requirements/decisoes-pendentes.md` — registro das decisões e lacunas residuais.
4. `openspec/config.yaml` e estrutura do repositório — configuração `spec-driven`; OpenSpec é obrigatório para especificação, planejamento e evolução SDD neste projeto, com governança manual. Os comentários explicativos foram alinhados nesta atualização documental; não houve alteração do schema nem do comportamento.

### Precedência

Requisitos formalmente aprovados → decisões de produto confirmadas → decisões arquiteturais aprovadas → especificações OpenSpec aprovadas dentro desses limites → este documento e solicitações pontuais compatíveis → documentação técnica e boas práticas. Referências técnicas justificam implementação, nunca alteram regra de negócio.

### Referências técnicas consultadas em 18/10/2026

As páginas abaixo foram acessadas; os resumos referem-se ao conteúdo obtido nessa data. Não foram consultados preços nem feitas medições. Diferencie-se: **fato documentado** é conteúdo da fonte; **inferência** é consequência aplicada a este projeto; **recomendação** é proposta ainda sujeita a aprovação.

- Next.js Docs, incluindo [Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components): App Router usa Server Components por padrão; Client Components são apropriados para estado, eventos e APIs de navegador. Módulos importados por Client Component integram seu grafo de cliente. (Fato.)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/): documentação de tipos, funções, módulos e opções de compilador. (Fato; não determina arquitetura de aplicação.)
- [FastAPI](https://fastapi.tiangolo.com/): framework baseado em Starlette e Pydantic, validação/serialização tipada, OpenAPI, dependências, `APIRouter` e recursos de teste. (Fato.)
- [Python 3 Documentation](https://docs.python.org/3/): página acessada identificava documentação 3.15.0 e versão 3.16 em desenvolvimento. Isso não prova compatibilidade do ecossistema proposto; versão de Python permanece por selecionar. (Fato e limitação.)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/current/): documentação consultada identificava PostgreSQL 18.6 e apontava capítulos de concorrência/controle transacional, constraints e tipos de data/hora. A página de conteúdo não foi usada para afirmar semânticas detalhadas de comandos. (Fato.)
- [SQLAlchemy 2.0](https://docs.sqlalchemy.org/en/20/): ORM e Core, sessões/conexões, transações e suporte assíncrono documentados. (Fato.)
- [Alembic](https://alembic.sqlalchemy.org/en/latest/): ferramenta de migração de banco associada a SQLAlchemy, com revisões e suporte a autogeração. (Fato.)
- [Google Cloud Well-Architected Framework](https://docs.cloud.google.com/architecture/framework): seis pilares — excelência operacional, segurança/privacidade/conformidade, confiabilidade, otimização de custos, desempenho e sustentabilidade. (Fato.)
- [Cloud Run](https://docs.cloud.google.com/run/docs): serviço gerenciado para workloads em contêiner, com escalabilidade e guias de autenticação/operação. [Cloud SQL for PostgreSQL](https://docs.cloud.google.com/sql/docs/postgres): banco PostgreSQL gerenciado, conectividade, alta disponibilidade, backup e recuperação. (Fatos.)
- [Secret Manager](https://docs.cloud.google.com/secret-manager/docs): armazenamento e controle de acesso IAM para dados sensíveis; a página acessada não descreveu identidade de workload. (Fato e limitação.)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/): framework de requisitos para verificar controles de segurança de aplicações web; a página mostrava v5.0.0. [OWASP API Security](https://owasp.org/www-project-api-security/): projeto mantém Top 10 e boas práticas, mas a página acessada não identificava a edição atual. (Fatos; não se declara conformidade.)
- [Claude Code Overview](https://code.claude.com/docs/en/overview): documentação descreve `CLAUDE.md` de projeto como arquivo de instruções persistentes lido no início da sessão. (Fato.)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec): README apresenta fluxo spec-driven com proposta, especificações, design e tarefas, seguidos de aplicação e arquivamento. O repositório contém scaffold local, mas sua configuração não registra regras específicas do produto. (Fato.)

Não foram acessadas páginas específicas de versões suportadas, preços, Cloud SQL conexão privada/IAM, critérios atuais do OWASP API Top 10, política de suporte ou detalhes de recuperação. Validar essas matérias antes de fechar versões, orçamento ou desenho de rede.

## 4. Requisitos arquiteturalmente relevantes

### Funcionais

- Cadastro, autenticação, alteração e recuperação de senha por e-mail, com token único de duração entre 30 e 60 minutos conforme HU-21. Para o primeiro vínculo Google/local por e-mail, verificar o endereço local novo ou alterado pelo código de seis dígitos da HU-22, com até três tentativas por verificação; a identidade Google já vinculada retorna por `sub` conforme HU-23. Não confundir os fluxos nem dispensar admissão administrativa.
- Palpites inteiros não negativos, editáveis até uma hora antes do kickoff oficial vigente; requisições recebidas no cutoff ou depois são rejeitadas, embora as recebidas antes possam concluir depois. A publicação aguarda gravações elegíveis em andamento; alteração oficial do kickoff pode reabrir a janela, período em que novas consultas alheias ficam ocultas até o novo cutoff.
- Administração de calendário, seleções/classificação de mata-mata, resultados oficiais e correções auditáveis.
- Pontuação 6/3/2/1/0, explicação de pontos, ranking com quatro critérios além de pontos totais, visão rodada a rodada, grupos/chaveamento, estatísticas/badges e chamados de suporte.

### Não funcionais / qualidade

- Integridade temporal e concorrente do corte; autorização consistente em qualquer rota/consulta.
- Cálculo determinístico, auditável e idempotente após correção de resultado.
- Confidencialidade de palpites e dados pessoais antes/de acordo com a regra; não há compromisso de backup/recuperação; riscos e limitações devem ser comunicados.
- Baixa complexidade operacional, testabilidade, acessibilidade, responsividade e rastreabilidade.

## 5. Restrições e premissas

- Grupo único; não adicionar tenant/ligas independentes.
- Stack obrigatória neste escopo: Next.js/TypeScript, FastAPI/Python e PostgreSQL, em serviços separados no Docker Compose local. Versões continuam por selecionar. Windows 11 com Docker Desktop/WSL 2/Ubuntu e WSL 2/Linux são ambientes a suportar; a compatibilidade ainda não foi validada. Produção não é presumida idêntica ao desenvolvimento e GCP não está selecionado.
- Na análise de 18/10/2026 nada disso existia; em 19/10/2026 há scaffold (entrypoint, manifests, READMEs, Compose e Dockerfiles). Continuam ausentes CI, testes, dado oficial de partidas e comandos de build/teste confirmados.
- OpenSpec é obrigatório para especificação, planejamento e evolução SDD, com governança manual. `openspec/config.yaml` mantém `schema: spec-driven`; comentários explicativos alinhados nesta atualização documental. Ainda não há specs-base; existe a change proposta `2026-10-18-technical-foundation` em `openspec/changes/`, sem aprovação formal registrada.
- Requisito define BRT como UTC-3 permanente e todas as exibições neste fuso. Recomenda-se armazenar instantes em UTC e apresentar com offset fixo UTC-03:00 conforme requisito; mudanças oficiais de calendário devem ser atualizações de dados auditáveis, não suposições em código.
- Não se assume volume de usuários, orçamento, disponibilidade, residência de dados, fornecedor de e-mail ou equipe de operação. Não há backup/recuperação no escopo decidido.

## 6. Definidas versus pendentes

### Definido na fonte de requisitos

O requisito v3.4 preserva da v3.2 o placar de mata-mata ao final de 120 minutos sem gols de pênaltis, corte de uma hora e semântica de recepção, publicação após conclusão das gravações elegíveis, sete rodadas, pontuação, ranking corrente e ordem dos critérios de desempate, grupo único e escopo excluído. Recuperação por token único de 30 a 60 minutos e resposta anti-enumeração (HU-21) também permanecem definidos; HU-22 exige reverificação do endereço local alterado por código de seis dígitos, com até três tentativas por verificação, e HU-23 permite retorno de identidade Google já vinculada por `sub`. Não flexibilizar regras por conveniência técnica. Permanecem abertas as políticas para partidas suspensas/abandonadas/retomadas e alguns efeitos de cancelamento, descritos no [registro canônico de decisões pendentes](../requirements/decisoes-pendentes.md). Os resumos e exemplos desta arquitetura são contextuais; em caso de divergência, prevalece o requisito aprovado.

### Direção definida e recomendações

**Definido neste escopo:** stack Next.js/TypeScript, FastAPI/Python e PostgreSQL; execução local por Compose em serviços separados com persistência local; monólito modular, DDD pragmático, Clean Architecture, organização por funcionalidades e OpenSpec obrigatório para SDD. Windows 11 com WSL 2/Ubuntu também deve ser suportado.

**Direção aprovada em 19/10/2026 (ADR-001):** `backend/` e `frontend/` no mesmo repositório, toolchains separados, módulos backend por capacidade com fatias verticais por caso de uso e domínio proprietário sem duplicação de invariantes; contratos de API entre runtimes. SQLAlchemy síncrono, recálculo coerente síncrono inicialmente e sessão opaca revogável no servidor são pontos de partida sujeitos a design/validação. Pontuação, ranking e badges são derivados reconstruíveis. **Ainda sujeitos a decisão e prova:** nomes de arquivos, APIs entre módulos, driver/URL, schema, locking, cookie/CSRF, desempenho e casos excepcionais de produto. Não introduzir fila, cache distribuído ou microserviços sem necessidade mensurável.

### Pendências de produto, operação e processo

Ver seção 22 e o registro canônico. Recomendações técnicas permanecem recomendações, não regras vigentes. As lacunas bloqueiam somente os fluxos cujo comportamento dependa delas; versões e detalhes de Compose impedem afirmar compatibilidade e experiência local reproduzível.

## 7. Atributos de qualidade e prioridades

1. **Integridade e justiça:** mesma regra e mesmo instante autoritativo para todas as gravações; resultados e cálculos reproduzíveis.
2. **Confidencialidade:** palpites não são recuperáveis por participante alheio antes do corte, inclusive por APIs alternativas, cache, logs ou consultas agregadas.
3. **Auditabilidade:** autor, momento, motivo e valores anteriores/novos de ações administrativas; capacidade de reproduzir projeções.
4. **Simplicidade operacional:** um backend modular, um PostgreSQL local no Compose e sem infraestrutura distribuída prematura; banco gerenciado somente seria avaliado em escopo futuro.
5. **Testabilidade:** regras puras isoladas de HTTP/ORM; testes integrados com PostgreSQL para semântica transacional.
6. **Usabilidade inclusiva:** interfaces responsivas, acessíveis, com erros e prazos explícitos; datas sempre no fuso definido.
7. **Evolução segura:** mudanças de requisitos e schema revisadas e migradas incrementalmente.

## 8. Visão arquitetural geral

### Diagrama de contexto

```mermaid
flowchart LR
  P[Participante] -->|Web HTTPS| FE[Aplicação web do Bolão]
  A[Administrador] -->|Web HTTPS e ações autorizadas| FE
  FE -->|API HTTPS autenticada| API[API do Bolão]
  API --> DB[(PostgreSQL)]
  API --> MAIL[Provedor externo de e-mail a selecionar]
  API --> OBS[Logs e métricas operacionais]
  ADM[Responsável por calendário e resultados oficiais] -->|Dados confirmados| API
```

### Topologia de desenvolvimento local definida

```mermaid
flowchart TB
  B[Browser] -->|HTTP local| WEB[Frontend Next.js]
  WEB -->|API local| API[Backend FastAPI]
  API --> DB[(PostgreSQL local)]
  WEB --- WV[(Volume local do frontend, se necessário)]
  API --- AV[(Volume local de desenvolvimento, se necessário)]
  DB --- DV[(Volume local persistente de dados)]
  DEV[Desenvolvedor / VS Code opcionalmente com Dev Container] --> B
```

A topologia representa serviços separados via Docker Compose para frontend, backend e banco. Os volumes locais servem à persistência do ambiente de desenvolvimento/testes; políticas exatas de montagem, nomes e ciclo de vida serão definidas e validadas na change `2026-10-18-technical-foundation`; o `docker-compose.yml` atual é scaffold. O volume do banco preserva dados entre reinicializações normais, mas não protege contra exclusão, corrupção ou perda do armazenamento e não é backup.

GCP é somente um possível destino de portabilidade. Não há diagrama de produção aprovado nem atividade de implantação/gestão GCP prevista nesta arquitetura.

## 9. Arquitetura recomendada e alternativas

**Direção aprovada (ADR-001):** monólito modular no serviço Python, executado localmente como serviço de backend separado do frontend e do PostgreSQL via Docker Compose. Módulos compartilham deployment do backend e banco, mas mantêm autoridade e dependências explícitas; casos de uso coordenam operações entre módulos. Fatias por caso de uso pertencem aos módulos, sem transformar cada tela em módulo nem exigir pasta mista Python/TypeScript; não se introduz RPC interno.

**Por quê:** escala e operação de um grupo único não justificam microserviços. Transações PostgreSQL podem simplificar a gravação de palpite/corte e o registro de resultado/auditoria, mas os mecanismos concretos precisam ser validados com concorrência real. Frontend separado atende à topologia local exigida sem particionar artificialmente o domínio.

**Alternativas consideradas:**

- Next.js full-stack como backend único: menor número inicial de serviços, mas conflita com a direção FastAPI/Python e divide regras entre runtimes. Poderá ser reconsiderado se a equipe escolher um stack único antes da implementação.
- Frontend e API no mesmo processo/deployment: menor custo/complexidade inicial, mas acopla escalabilidade, exposição e release; pode ser apropriado em hospedagem restrita. Não se assume compatibilidade de execução Next.js com o destino sem validar.
- Microserviços/eventos/filas: isolamento e escala independentes, mas acrescentam consistência eventual, operação e observabilidade sem necessidade demonstrada. Não recomendado inicialmente.
- Portabilidade GCP: serviços gerenciados podem ser avaliados futuramente como destino por quem vier a operar o sistema. Esta equipe não selecionará nem implantará hospedagem GCP; scripts de portabilidade ainda não foram decididos.

## 10. Módulos de domínio e dependências

Cada módulo controla suas invariantes e expõe casos de uso/contratos. As fronteiras são propostas de organização, não microserviços.

| Módulo | Autoridade e responsabilidades | Casos de uso principais | Dependências permitidas / proibidas |
|---|---|---|---|
| Identidade e acesso | Identidade de participante, credenciais, sessão e papéis | Cadastro/entrada conforme política; login; troca/recuperação de senha; autorização | Pode ser consultado por todos via interfaces de identidade; não depende de Palpites ou Ranking. Não expõe senha/token. |
| Torneio e calendário | Seleções, grupos, rodadas, partidas, horários, estado de calendário e chaveamento | Publicar/alterar calendário; registrar classificação e confrontos | Não depende de pontuação. Fornece partida e versão/estado a Palpites e Administração. |
| Palpites | Um palpite por participante-partida, valor, momento de gravação e regra de abertura/visibilidade | Criar/editar, consultar próprio, consultar grade após corte | Consulta calendário para prazo; consulta Identidade para escopo; não lê diretamente tabelas de outros módulos. |
| Resultados oficiais e auditoria | Resultado de 120 min e revisões administrativas; trilha de alterações | Lançar/corrigir resultado, apurar e solicitar recálculo | Consulta partida; chama Apuração em transação/orquestração; auditoria registra ação/ator. Não altera palpites. |
| Apuração e pontuação | Função de pontuação pura e resultado calculado por palpite/versão de resultado | Calcular/recalcular, explicar pontuação, registrar versão do cálculo | Recebe palpites/resultados por contratos; não decide calendário nem identidade. Idempotência por chaves naturais/versões. |
| Ranking e estatísticas | Agregados e projeções por participante/rodada | Consultar ranking e histórico; explicar desempate; atualizar projeções | Consome dados de apuração e participantes; não muda resultados. Projeção reconstruível. |
| Suporte | Chamados, protocolo, estado e respostas | Abrir, consultar e administrar chamado | Consulta identidade; acesso restrito ao chamado. Retenção pendente. |
| Gamificação | Definições e concessões de badges após critérios aprovados | Calcular concessão e exibir badges | PROD-06 considerada aprovada em 19/10/2026; a concessão automática depende de OpenSpec e das lacunas PROD-06.5/06.6 (resultado definitivo, partidas canceladas). Consumir palpites válidos, calendário/rodadas e pontuação por partida por contrato; não depender de ranking e não alterar pontos. |

### Regras de dependência

- Domínio não importa FastAPI, SQLAlchemy, SDK de e-mail, Cloud SDK ou componentes de UI.
- Aplicação orquestra domínio e portas de persistência/relógio/e-mail; adaptadores HTTP, SQL e provedores implementam portas.
- Dependências direcionam-se para regras de domínio; módulos não leem/escrevem tabelas alheias diretamente.
- HTTP valida sintaxe/autenticação e mapeia erros; domínio/aplicação impõem invariantes. DB reforça unicidade e integridade.
- Leitura otimizada pode usar consultas/projeções específicas, sem permitir que UI bypass autorização.

## 11. Backend Python/FastAPI

Estrutura conceitual aprovada em **direção**, não como árvore obrigatória de arquivos (módulos existentes no scaffold; fatias/portas a criar conforme casos de uso):

```text
backend/
  app/
    bootstrap/                # composição/configuração por ambiente
    modules/<capacidade>/
      slices/<caso_de_uso>/   # fluxo vertical com entrada, aplicação e saída necessárias
      domain/                 # invariantes compartilhadas quando houver regra própria
      public_api.py           # exemplo de contrato público; nome a definir em design
    shared/                   # somente primitivas efetivamente compartilhadas
  tests/                      # integração/API/contrato; unitários próximos às fatias quando útil
```

`backend/app/entrypoints/http/` e as pastas de camadas já presentes são scaffold, **não** exigência de concentrar todos os routers em uma camada nem de replicar três subcamadas por módulo. A capacidade dona de resultados oficiais/auditoria e a localização da política temporal exigem design antes de criar novas pastas.

- **Domínio:** invariantes proprietárias puras (pontuação, estado de janela), sem ORM nem framework; fatias chamam o domínio em vez de copiar regra.
- **Caso de uso:** reúne entradas, política de aplicação, persistência/integração estritamente necessárias e limite transacional; entre módulos, usar contratos explícitos, sem importar internals de outra fatia.
- **Entrada:** routers FastAPI e modelos Pydantic adaptam HTTP aos casos de uso. Erros de domínio têm mapeamento uniforme e mensagens sem dados sensíveis.
- **Saída:** repositórios SQLAlchemy, e-mail, relógio e observabilidade implementam portas quando houver necessidade real. Alembic mantém revisões versionadas; avaliar autogeneração, revisar manualmente, testar upgrade e downgrade em ambiente descartável antes de adotar.
- **Persistência:** SQLAlchemy com sessão síncrona é o ponto de partida aprovado (ADR-001), sujeito a perfil e compatibilidade. `asyncpg` declarado no manifesto e `DATABASE_URL` exemplar ainda não atendem a essa escolha; driver, pacotes, configuração de migração e versões dependem de change e validação. Sessões/transações têm escopo explícito por caso de uso, sem misturar estilos.
- **Validação:** Pydantic/HTTP valida forma/tipo; domínio valida regras, incluindo gols como inteiros não negativos. Constraints do banco protegem invariantes concorrentes.
- **Erros:** contrato estável (código e mensagem segura), sem revelar detalhes internos; exceções técnicas são observadas internamente sem PII/senhas/tokens.
- **Configuração:** variáveis não secretas por ambiente; segredos via gerenciador aprovado. Falha segura se configuração essencial faltar; nunca valores secretos em frontend.
- **Observabilidade:** logs estruturados com correlation/request ID, ator pseudônimo/ID interno quando necessário, evento operacional e resultado; métricas para latência/erros, gravações rejeitadas por prazo, apurações e falhas. Redigir e limitar dados sensíveis.

A escolha de FastAPI não desloca regras para dependências HTTP; serviços de domínio e casos de uso podem ser testados sem levantar servidor.

## 12. Frontend Next.js/TypeScript

Organização conceitual:

```text
frontend/
  app/                       # rotas, layouts, loading/error/not-found
  features/                  # auth, tournament, predictions, ranking, admin, support
  components/                # componentes acessíveis reutilizáveis
  lib/api/                   # cliente tipado, serialização, erros e sessão
  lib/dates/                 # formatação do horário BRT (UTC-03:00)
```

- Preferir App Router e Server Components para renderização/leitura segura quando a topologia permitir. Manter componentes de cliente pequenos, apenas para formulário, contador, interações e APIs do navegador. Nunca serializar em props dados privados alheios ao usuário.
- Não considerar Server Component/RSC mecanismo de autorização. API aplica autorização em toda requisição; cache de respostas autenticadas/grades de palpites deve ser desabilitado ou segregado de forma comprovada para impedir vazamento entre usuários/estados.
- Sessão opaca revogável no servidor é a direção aprovada (ADR-001); definir cookie `HttpOnly`, `Secure`, `SameSite` e CSRF conforme topologia e análise de ameaça, sem transportar segredo no bundle nem persistir bearer tokens sensíveis em `localStorage`. Correspondência de e-mail para primeiro vínculo, reverificação do endereço local alterado e até três tentativas por verificação estão definidas (HU-22); retorno de identidade Google já vinculada ocorre por `sub` (HU-23). Prova do primeiro vínculo, reenvio/reinício de tentativas e compatibilidade do reset com contas Google permanecem pendentes (TEC-01).
- Chamada de API centralizada, tipos de contrato e mapeamento de erro previsível. Estados explícitos de carregamento, erro, vazio e sucesso. Formulário valida no cliente por UX e no backend por segurança.
- Estado local para interações; não adotar store global sem necessidade comprovada. Dados autoritativos sempre carregados da API.
- Datas formatadas com UTC-03:00 conforme requisito, sem confiar no timezone do dispositivo. Contador é informativo; servidor decide corte.
- Acessibilidade: navegação por teclado, rótulos e erros associados, contraste, foco visível, sem usar apenas cor, layouts responsivos e testes com tecnologia assistiva.
- Testes de componentes e fluxos críticos; contrato da API compartilhado/validado sem duplicar regra de negócio.

## 13. Modelo conceitual de dados

Modelo lógico inicial; não equivale a schema aprovado nem migração.

- **Participant/User:** ID estável, nome de exibição, e-mail normalizado, estado de conta; papéis/atribuições administrativas controladas. Separar identidade externa se houver provedor externo. Senhas guardadas apenas como hash adaptativo com salt; política criptográfica validada na implementação.
- **Tournament:** edição/título do torneio e timezone de apresentação fixa; **Team/Selection** associada ao torneio; **Group** e associação de seleções; o calendário oficial é dado administrado e versionável.
- **Round:** uma das sete rodadas aprovadas. **Match:** identificador, rodada, fase, seleções/slots de chaveamento, kickoff UTC, apresentação conforme BRT, estado (incluindo cancelada/anulada) e versão de calendário. A tabela de confrontos e equipes oficiais ainda não existe neste repositório; atualização manual por administrador com auditoria está decidida (OPS-06).
- **Prediction:** participante, partida, gols inteiros não negativos, criado/atualizado em UTC e, se necessário, versão/autor da alteração. Restrição única `(participant_id, match_id)`; constraint para gols >= 0. A janela não se resolve com constraint estática. Validação considera timestamp de recepção confiável gerado pelo servidor; pedidos recebidos antes do corte podem concluir depois (PROD-01).
- **OfficialResult/ResultRevision:** partida, placar de 120 minutos, estado de apuração, autor, momento e revisão. Tratar valores de pênaltis separadamente apenas se houver necessidade de exibição; não entram na função de pontuação. Correções administrativas são sempre permitidas com revisão e auditoria (PROD-04); o estado/mensagem de encerramento da apuração ainda precisa de definição.
- **ScoreCalculation:** palpite, revisão do resultado e versão do algoritmo, pontos e categoria explicativa. Chave única por palpite+revisão+versão torna repetição idempotente; alternativa é substituir projeção vigente mantendo evento histórico. Decidir retenção/volume ao projetar.
- **RoundRankingSnapshot/RankingProjection:** rodada, versão de cálculo, participante, totais e métricas de desempate, opcionalmente fotografia. Deve ser reconstruível a partir de dados fonte e cálculos; não assumir um snapshot imutável antes de definir desempate parcial.
- **PasswordResetToken:** digest do token (não token em claro), participante, emissão/expiração, utilizado/revogado; uso único com consumo atômico conforme HU-21.
- **Verificação de e-mail local e identidade Google:** separar finalidade e estado da verificação por código numérico de seis dígitos do endereço local novo ou alterado (HU-22), com até três tentativas por verificação, da recuperação HU-21; reconhecer identidade Google já vinculada por `sub` e tratar e-mail como atributo de correspondência mutável. Schema, expiração, reenvio/reinício de tentativas, efeitos da troca de endereço e mecanismo seguro do primeiro vínculo continuam abertos (TEC-01).
- **SupportTicket/Reply:** protocolo, solicitante, estado, mensagens e timestamps; política de exposição/retention pendente.
- **AuditEvent:** ator, ação, recurso, timestamp UTC, correlação, motivo e diff mínimo necessário. Não guardar segredos nem duplicar PII sem finalidade.
- **BadgeDefinition/BadgeGrant:** regras aprovadas e concessão por participante; revogação, reativação, recálculo e versionamento de critérios definidos na PROD-06 §7-8; resultado definitivo e partidas canceladas pendentes.

### Integridade e índices candidatos

- FKs com política explícita de exclusão; não inferir deleção em cascata: escopo de exclusão por tipo de dado e preservação de histórico permanecem pendentes (OPS-01).
- Unicidade de palpite por participante-partida, chave única de cálculo, IDs não sequenciais expostos publicamente, checks de placares inteiros >= 0.
- Índices para partida por kickoff/rodada, palpites por partida (consulta pós-corte) e por participante, resultado por partida/revisão, ranking por rodada/participante, suporte por status/solicitante e auditoria por recurso/tempo.
- Instantes armazenados em UTC em tipos timezone-aware; formatar como BRT no limite de apresentação. Horário oficial original/offset e revisões podem ser preservados para auditoria, sem misturar texto local e instante.
- Migrações incrementais, revisadas e testadas em cópia não produtiva. Não editar migrações já aplicadas; preparar migrações de expansão/contração quando houver deployment concorrente. Backup/restore não fazem parte do escopo decidido (OPS-02); compatibilidade de schema continua sendo requisito de mudança.
- Não há prazo de retenção nem exclusão automática. Usuário ou administrador podem excluir, mas escopo e impacto sobre histórico/auditoria permanecem pendentes (OPS-01). Não há backup nem recuperação no escopo (OPS-02).

## 14. Autenticação e autorização

- Cadastro é aberto, mas requer aprovação administrativa; após aprovação há e-mail de confirmação/liberação. Campos mínimos definidos: nome e e-mail (PROD-07). Usar um papel administrador com privilégios mínimos necessários (PROD-08); fluxo e matriz operacional detalhados permanecem pendentes.
- Suportar autenticação por conta Google ou identidade local (usuário/senha), vinculáveis por correspondência de e-mail **após verificação do endereço local novo ou alterado pelo código de seis dígitos enviado a ele, com até três tentativas por verificação** (HU-22). Identidade Google já vinculada pode autenticar novamente a conta validada por `sub` (HU-23). Texto coincidente de identidade ainda não vinculada não autoriza acesso automático a conta preexistente: prova de controle, conflitos, efeitos da mudança de e-mail, validade e reenvio/reinício de tentativas exigem decisão TEC-01/PROD-07. TLS obrigatório em produção; hash adaptativo de senha, recuperação segura, controles de tentativa e reautenticação para ações críticas exigem desenho e validação.
- Recuperação: resposta idêntica e temporalmente semelhante para e-mail existente/inexistente; token aleatório de alta entropia, só digest armazenado, uso único, curta expiração dentro dos 30–60 min definidos, invalidar após uso/alteração, limitar tentativas e não registrar token. Envio assíncrono só após decisão se houver fila; uma chamada simples pode servir ao porte inicial.
- A autorização é aplicada no backend a cada recurso e ação. Participante acessa/edita o próprio palpite enquanto a requisição for recebida antes do corte vigente; a grade de palpites de todos fica disponível somente após o corte. Não há exceção administrativa individual para alteração pós-corte; pedidos de suporte não alteram palpites. Uma alteração oficial do kickoff recalcula o corte e pode reabrir a janela para todos, conforme PROD-02/05. Administrador tem privilégios mínimos para calendário/resultados/suporte.
- Um único papel administrador com privilégios mínimos necessários; proteger ações administrativas, aplicar autorização no backend e auditar alterações. Os participantes comuns não veem palpites alheios antes do corte; não presumir bypass administrativo de visibilidade.
- Administração protegida com autenticação forte apropriada e proteção contra CSRF em sessão baseada em cookie.
- Sessão opaca revogável mantida no servidor é a direção aprovada; expiração, renovação, atributos de cookie, CSRF e efeitos do bloqueio administrativo exigem desenho e testes (TEC-01).

## 15. Segurança, privacidade e auditoria

### Obrigatório pela regra de produto

- Bloquear leitura de palpites alheios antes do corte no backend; rejeitar escritas cuja recepção confiável ocorra no corte ou depois, permitindo concluir após o corte apenas requisições recebidas antes dele; impedir participante comum de obter dados por rotas alternativas.
- Proteger contas e recuperação sem revelar existência de e-mail; segregar administração e registrar correções de resultados.
- Evitar exposição de segredos e dados pessoais desnecessários.

### Controles recomendados

- TLS; IAM e service accounts com privilégio mínimo; Secret Manager (ou equivalente aprovado); banco não exposto diretamente à internet; validação de entrada e queries parametrizadas; proteção CSRF/XSS, CORS allowlist estrita, headers de segurança e política de conteúdo adequadas à UI.
- Rate limit de login/recuperação e ações de escrita; detecção de abuso, CAPTCHA apenas se ameaça justificar; segurança de sessão e rotação de segredos.
- Logs sem senhas, tokens, conteúdo integral de e-mail/chamado, palpite confidencial ou dados pessoais desnecessários. Controle de acesso; o prazo de retenção dos próprios logs não está definido (OPS-01).
- Revisão de dependências, atualizações, análise de vulnerabilidades, SAST/DAST conforme capacidade, revisão de permissões, controles de segurança proporcionais ao ambiente local; sem declarar recuperação/backups.
- Usar OWASP ASVS como checklist e OWASP API Security para ameaças de autorização, autenticação, abuso e consumo de recursos; selecionar nível/controles após avaliação de risco. Nenhuma certificação/conformidade é declarada.
- Auditoria append-only lógica, limitada a dados necessários e protegida contra alteração por rotas comuns. Cada resultado corrigido gera evento contendo ator, momento, partida e valores anterior/novo; a obrigatoriedade de justificativa para correção de resultado continua por confirmar. Alterações administrativas de kickoff registram ator, instante e valores anterior/novo, sem justificativa textual obrigatória.
- Não se configura backup nem recuperação neste escopo (OPS-02). Volumes locais não são backup; qualquer futura alteração de escopo deve primeiro reabrir essa decisão.

### Dependente de decisão

Escopo e efeitos de exclusão/anonimização, visibilidade administrativa pré-corte, MFA, confirmação segura do primeiro vínculo Google/local, casos de colisão, efeitos e instante da alteração de e-mail, proteção/expiração do código local, reenvio/reinício de tentativas, localização/região de dados, prazo de retenção de logs, resposta a incidentes e classificação de dados. Correspondência por e-mail para primeiro vínculo, reverificação local e o limite de três tentativas por verificação (HU-22), além do retorno por `sub` da identidade Google já vinculada (HU-23), estão decididos; isso não define vínculo automático, os controles residuais nem detalhes da sessão (TEC-01). Não alegar requisitos legais específicos sem determinar jurisdição e análise aplicável.

## 16. Palpites, corte e visibilidade

**Regra aprovada:** o cutoff é uma hora antes do kickoff oficial vigente. O backend valida timestamp confiável de recepção: gravações recebidas antes do cutoff podem concluir depois; recebidas no instante do cutoff ou depois são rejeitadas. A publicação após o cutoff aguarda a conclusão das gravações elegíveis recebidas antes dele. Alteração oficial do kickoff recalcula o cutoff e pode reabrir a janela (PROD-01/02).

**Proposta técnica para cutoff:** uma única regra compartilhada no domínio/aplicação calcula `cutoff = scheduled_kickoff_utc - 1 hour`; o banco guarda instantes UTC; a avaliação final usa relógio confiável do servidor, não relógio do navegador. Serializar mudança de palpite e mudanças de kickoff pela mesma linha/controle da partida (por exemplo, lock transacional da partida) é uma opção técnica, não uma decisão aprovada; após qualquer sincronização escolhida, a escrita deve usar kickoff vigente e a condição `received_at < cutoff`. A requisição elegível pode concluir após o cutoff, com timestamp confiável preservado para auditoria. O timestamp de recepção, o ponto de ingresso e a garantia de espera/publicação devem ser definidos e testados na implementação. Não se fixa aqui locking específico.

**Visibilidade:** antes do cutoff vigente, consultas do participante comum não retornam palpites alheios. No cutoff, a publicação aguarda as gravações elegíveis em andamento; depois, disponibiliza os dados permitidos. Respostas privadas não podem ser compartilhadas em cache/CDN. Administrador não tem bypass pré-cutoff por padrão, e não há exceção individual para alteração pós-cutoff (PROD-05). Se alteração oficial do kickoff reabrir a janela (PROD-02), participantes podem escrever até o novo cutoff, enquanto novas consultas alheias permanecem ocultas até lá. A divulgação já observada não pode ser desfeita nem ter confidencialidade restaurada. Alterações de kickoff são auditadas com ator, instante e valores anterior/novo; motivo textual não é obrigatório.

**Concorrência:** duas edições do mesmo palpite necessitam política técnica de conflito. Lock/versionamento otimista é recomendação, não decisão de produto; conflito pode exigir recarga. O cutoff e calendário devem ser verificados de modo sincronizado, mas o mecanismo fica para desenho e teste técnico. Permanece pendente definir como provar/preservar timestamp confiável de entrada sem falsificação ou replay.

## 17. Pontuação, recálculo e ranking

### Pontuação

O requisito v3.2 define categorias excludentes e esclarece que “gols de uma equipe” significa acertar exatamente uma das duas contagens, após avaliar o placar exato. A tabela abaixo usa resultado oficial **2–1** (casa–fora):

| Palpite | Resultado geral correto? | Gols exatos | Pontos | Justificativa |
|---|---:|---|---:|---|
| 2–1 | Sim | ambos | 6 | Placar exato, precedência máxima |
| 2–0 | Sim | casa | 3 | Vitória e gols de exatamente uma equipe |
| 3–1 | Sim | fora | 3 | Vitória e gols de exatamente uma equipe |
| 3–0 | Sim | nenhum | 2 | Vitória, erra ambos os gols |
| 0–1 | Não | fora | 1 | Palpite de vitória visitante; acerta um total de gols |
| 2–2 | Não | casa | 1 | Palpite de empate; acerta exatamente um total |
| 0–0 | Não | nenhum | 0 | Nenhuma categoria anterior |

Com placar oficial **1–1**: 1–1 = 6; 2–1 = 1 (resultado errado, gols visitantes certos); 0–0 = 2 (empate, ambos totais errados); 1–2 = 1 (resultado errado, gols da casa certos); 0–2 = 0. Assim, categorias são mutuamente exclusivas; a interpretação aplicada é exatamente uma equipe nas categorias de 3 e 1 ponto, respeitando a precedência do placar exato. Casos unitários parametrizados devem cobrir todos os resultados W/D/L e acertos de zero gols.

Para eliminatórias, resultado usado é placar ao término dos 120 minutos, incluindo prorrogação; pênaltis são excluídos e empate permanece empate. O administrador cadastra placar final de 120 minutos. Jogo adiado mantém palpites e novo kickoff; jogo cancelado/anulado é excluído da pontuação (PROD-03). Tratamento de partidas suspensas/abandonadas e efeitos em ranking/badges permanece pendente.

### Recálculo

Manter dados oficiais e palpites como fontes; pontuação, ranking e badges são derivados determinísticos e reconstruíveis (ADR-001). Ao publicar/corrigir resultado, persistir revisão e evento de auditoria e recalcular palpites elegíveis para aquela partida de forma idempotente, sem somar pontos incrementalmente. Publicar ranking coerente, nunca parcialmente atualizado; badges consomem fatos de palpites, calendário e pontuação por partida, não a projeção de ranking. Começar com recálculo transacional síncrono é a direção inicial aprovada para grupo único, **sujeita a medição de latência e teste concorrente**; se a transação não couber, novo desenho e política de apresentação demandam decisão. Não adicionar fila/outbox antes de necessidade.

Se transação extensa causar bloqueios, registrar revisão oficial e cálculo pendente com estado explícito, preservar ranking anterior identificado como defasado e publicar nova versão atômica ao completar; isso exige decisão de apresentação e não deve ser simulado como “tempo real”. Resultado corrigido invalida/reconstrói derivados, não apaga trilha de eventos.

### Ranking

Ordem normativa definida pelo requisito v3.2 (reproduzida abaixo como resumo; ver regra completa na fonte canônica):
1. pontos totais DESC;
2. quantidade de palpites de 6 pontos DESC;
3. quantidade de palpites de 3 pontos DESC;
4. pontos acumulados em rodadas anteriores DESC, ignorado em R1;
5. nome de exibição em ordem alfabética após normalização que ignora acentos e caixa; se os nomes normalizados forem iguais, os participantes permanecem empatados.

Armazenar pontuação por participante/partida/versão; agregar por rodada; manter snapshots/projeções reconstruíveis por versão do resultado/cálculo. Não usar ordem de consulta não determinística: calcular chave normalizada com normalização Unicode e regra de locale estável. Se todos os critérios de negócio forem iguais — inclusive nomes iguais após normalização — apresentar empate; um ID estável pode ordenar linhas tecnicamente de forma repetível, mas não pode alterar a classificação oficial. Detalhes da regra de ranking estão no [requisito v3.2](../requirements/requisitos-bolao-copa-mundo-feminina-2027.md#135-criterios-de-desempate-do-ranking).

O requisito v3.2 define o ranking corrente com base apenas em resultados oficialmente apurados, sem atribuir pontos provisórios ou zero a partidas pendentes. Para o terceiro desempate, uma rodada anterior é concluída quando todas as partidas estão apuradas ou oficialmente canceladas/anuladas; na R1 o critério é ignorado. O último critério normaliza nomes ignorando acentos e caixa; se os valores normalizados forem iguais, os participantes permanecem empatados. Correções em resultados anteriores devem recalcular pontuações derivadas e rankings afetados, preservando a ordem aprovada.

**Nota técnica:** ordenação interna de linhas pode usar identificador estável, mas não pode converter empate oficial em classificação diferente. O tratamento de partidas excepcionais além de cancelamento/anulação permanece no registro canônico.

## 18. Transações, concorrência e idempotência

- **Salvar palpite:** autenticar/autorização; obter timestamp confiável de recepção; transação, lock/versão da partida, leitura do horário vigente; validar `received_at < cutoff`; inserir/atualizar com unique `(participant, match)` e conflito de versão; commit. Requisições recebidas antes do corte podem concluir depois dele; requisições recebidas no corte ou após são rejeitadas.
- **Mudar calendário:** somente administrador; persistir revisão, ator e timestamp; serializar com gravações/leituras afetadas; invalidar caches. O cutoff acompanha o kickoff oficial vigente e pode reabrir (PROD-02); versionar a mudança e auditar as operações afetadas.
- **Resultado:** revisão oficial e evento de auditoria atômicos; cálculo depende da revisão identificada; constraint/unique protege reexecução; ranking recalculado como projeção identificada e publicado inteiro.
- **Consulta durante recálculo:** ler versão completa anterior enquanto nova se constrói, ou aguardar commit síncrono; nunca combinar totais velhos e novos. Expor data/versão de atualização se houver defasagem aprovada.
- **Reexecução:** mesmo resultado, palpites e algoritmo → mesma pontuação. Uma nova revisão de resultado ou versão de regra é nova entrada e gera nova projeção/revisão, sem duplicar acumulados.
- **Isolamento:** preferir transações curtas com constraints explícitas; testar integração em PostgreSQL real. Escolher isolamento/locking após prova de concorrência, não assumir que testes SQLite representam semântica PostgreSQL.

## 19. Testes e critérios de qualidade

Pirâmide recomendada:

1. **Unitários:** funções de pontuação e normalização; estados de janela; expiração/uso único de token; tabela parametrizada dos casos e limites; timezone e arredondamento/inteiros.
2. **Casos de uso:** autorização, respostas anti-enumeração, criação/edição, revisão de calendário, auditoria e apuração idempotente com portas fakes/clock controlado.
3. **Integração PostgreSQL:** constraints, transações, locks/conflitos, cutoff concorrente, recuperação, migrações e consulta de ranking atômica.
4. **API/contrato:** esquema OpenAPI, status e erros, autorização por rota, ocultação pré-corte contra acesso direto, abuso/rate limits e não exposição de campos internos.
5. **Frontend:** estados de carregamento/erro/vazio, formulário acessível, formatação BRT e fluxo de login/palpite/consulta pós-corte/admin.
6. **E2E:** cadastro/entrada conforme regra, recuperar senha, aceitar requisição recebida antes do corte mesmo que conclua depois, rejeitar requisição recebida no corte ou após, visibilidade pós-corte, lançamento/correção de resultado, placar 120 min e ranking.
7. **Operacional/manual:** teste com responsáveis de conteúdo/calendário, navegação assistiva em browsers acordados, homologação de regras de negócio e ensaio de resposta a incidente. Teste de restauração não é critério deste escopo, pois backup/recuperação não estão previstos (OPS-02).

Critérios automáticos: nenhum acesso alheio antes do corte; rejeitar requisições cuja recepção confiável ocorra no corte ou depois, e aceitar conclusão posterior apenas para requisições recebidas antes; uma única pontuação por regra; recálculo repetido não duplica nem diverge; ranking respeita cada chave; migrations sobem em DB descartável; testes de autorização negativos. Critérios manuais: entendimento das regras, exatidão do calendário oficial, UX/acessibilidade, revisão de badges, e processos administrativos/recuperação.

Tecnologias de teste não estão escolhidas. Não há testes implementados nem comandos de execução confirmados.

## 20. Execução local e portabilidade

### Desenvolvimento local

A execução de desenvolvimento obrigatória é Docker Compose com serviços separados para frontend Next.js, backend FastAPI e PostgreSQL. Deve haver volume local para os dados PostgreSQL e para outros dados que precisem sobreviver à recriação dos containers. Arquivo de exemplo de ambiente sem segredos e instruções reproduzíveis de inicialização existem como scaffold (`.env.example`, `docker-compose.yml`, Dockerfiles), ainda não validados por execução; a validação é entregável da fundação. Dev Container no VS Code é opcional.

**Windows 11/WSL 2:** a solução deve funcionar com Docker Desktop e integração WSL 2/Ubuntu, além do uso em WSL 2/Linux. Recomenda-se manter o checkout no filesystem da distribuição WSL para uso pelo Docker integrado; isso é orientação a validar na versão selecionada, não compatibilidade já demonstrada. Documentar caminhos e permissões, bind mounts, file watchers/hot reload, portas publicadas e acesso browser→frontend, rede frontend→API e API→PostgreSQL. Não incluir o banco em portas de host sem necessidade de desenvolvimento justificada.

A futura documentação deve explicar variáveis necessárias e defaults não secretos, configuração local, inicialização, prontidão, reinícios, migrações e diagnóstico de falhas comuns (container/dependência não pronta, portas ocupadas, permissões/mounts e hot reload). Health/readiness devem refletir prontidão real do serviço; ordem de inicialização, isoladamente, não é garantia. Definir execução de migrações de modo controlado e não concorrente. Serviços devem manter configuração por ambiente, não depender de caminhos locais codificados, restringir acesso ao banco ao backend e manter segredos fora de imagens/repositório. A estratégia concreta depende das versões escolhidas e deve ser verificada em Windows 11/WSL 2 e Linux antes de declarar suporte.

### GCP fora do escopo operacional

GCP é apenas um possível destino para o qual se deseja facilitar portabilidade. Não faz parte do projeto implantar ou gerenciar serviços GCP; Cloud Run, Cloud SQL, Secret Manager e Cloud Logging são referências possíveis, não arquitetura de produção aprovada. Scripts de geração/deploy para GCP não foram decididos e não serão criados nesta tarefa.

### Backup e recuperação

Não haverá necessidade/compromisso de backup ou recuperação no escopo definido (OPS-02); não declarar RPO/RTO, restore testado ou retenção de cópias. Um volume local do Compose é persistência operacional do ambiente, não backup. Qualquer futura mudança para operação GCP exigiria reavaliar explicitamente essa decisão antes de criar recursos ou afirmar recuperação.

### Custos e operação

Não há orçamento ou compromisso de operação GCP. Serviços locais usam recursos da máquina de desenvolvimento; disponibilidade, capacidade e gestão do ambiente local não têm metas formalizadas. Avaliações futuras de GCP são externas ao escopo atual.

## 21. Configuração, segredos e observabilidade

Configuração por ambiente validada na inicialização; segredos consultados em runtime com identidade do workload, acesso mínimo e rotação; variáveis prefixadas para cliente nunca contêm segredos. Logs estruturados com IDs de correlação e timestamp UTC; métricas técnicas e de processo sem dados pessoais; alertas acionáveis e runbooks. Não foi definido prazo de retenção de logs (OPS-01); não estabelecer retenção ilimitada por inferência. Não registrar palpite antes do corte em logs, traces, eventos ou analytics.

## 22. Decisões pendentes

O registro canônico de decisões de produto, operação e processo é [`../requirements/decisoes-pendentes.md`](../requirements/decisoes-pendentes.md). Esta arquitetura remete a ele e não mantém lista paralela de decisões.

Permanecem, entre outras, o detalhamento técnico do ponto de recepção confiável e da espera por gravações elegíveis (PROD-01), a sequência operacional de alterações sucessivas de kickoff (PROD-02), os efeitos de cancelamentos e demais partidas excepcionais (PROD-03), o estado e a autorização da apuração (PROD-04), o fluxo de admissão/exclusão (PROD-07/OPS-01), as lacunas residuais da PROD-06 (06.5 resultado definitivo, 06.6 partidas canceladas, reabertura de prazo, visibilidade de badges de terceiros e retenção do histórico), e-mail (OPS-03), ambiente local/driver (TEC-02), fluxo seguro do primeiro vínculo e sessão (TEC-01) e baseline/governança/rastreabilidade OpenSpec (TEC-03). HU-22 v3.4 fixa correspondência por e-mail, reverificação do endereço local alterado por código de seis dígitos e até três tentativas por verificação; HU-23 permite retorno da identidade Google já vinculada por `sub`. Nenhuma dessas regras fixa vínculo automático, reenvio/reinício de tentativas ou detalhes da sessão. Pontuação, ranking corrente, desempates e política de leitura/escrita durante reabertura permanecem definidos como na v3.2. ADR-001 delimita direções arquiteturais aprovadas sem criar regras de produto.

Não há exceção administrativa individual pós-corte. Requests recebidos no corte/depois são rejeitados; requests recebidos antes podem concluir após o corte conforme timestamp confiável (PROD-01). Se o kickoff oficial mudar, o corte recalcula e a janela pode reabrir (PROD-02/05). Pontuação, placar válido no mata-mata, visibilidade pós-corte e critérios/ordem de desempate estão definidos no requisito e não são pendências.

## 23. Riscos técnicos e mitigação

| Risco | Consequência | Mitigação proposta |
|---|---|---|
| Apuração incompleta sem indicação na interface | Participante pode interpretar totais atuais como definitivos | Exibir estado/progresso de apuração; manter a regra de desempate aprovada |
| Corrida no corte ou alteração de kickoff | Palpite aceito tarde, recusado injustamente ou revelado | PROD-01/02; relógio único, lock/versionamento, testes reais PostgreSQL |
| Vazamento pré-corte por cache/consulta alternativa | Perda de confiança e vantagem competitiva | autorização backend em todas as rotas; cache privado/no-store; testes negativos e revisão de logs |
| Correção de resultado gera ranking inconsistente | pontuação divergente ou duplicada | revisão versionada, cálculo idempotente, transação/projeção atômica |
| Calendário/chaveamento oficial muda | prazos/confrontos errados | OPS-06; atualizações auditadas e confirmação humana |
| Dados de 2027 ainda não cadastrados | produto não inicia corretamente | bloquear publicação de calendário até carga validada |
| Stack/versões sem compatibilidade confirmada | dependências sem suporte ou incompatíveis | matriz de versões e prova de integração antes de fundação; não fixar versões agora |
| Ausência de backup/recuperação | perda de dados sem restauração assegurada | OPS-02: risco aceito no escopo; não alegar restore |
| E-mail não entregue ou link abusado | usuário perde acesso/conta atacada | OPS-03, selecionar fornecedor externo; token digest/uso único e rate-limit |
| Configuração OpenSpec ou artefatos confundidos com governança automática | mudanças podem ignorar especificação ou aprovação humana | manter fluxo SDD obrigatório, rastreabilidade e registro de aprovação; governança permanece manual |
| Lacunas residuais da PROD-06 (resultado definitivo, partidas canceladas, reabertura de prazo) e detalhes do fluxo de admissão ainda abertos | concessões injustas ou acesso indevido | bloquear apenas as badges que dependem dessas lacunas e exigir aprovação administrativa |

## 24. Estratégia SDD/OpenSpec

OpenSpec é obrigatório para especificação, planejamento e evolução orientada a mudanças. O processo é leve e a governança permanece humana/manual: especificações e tarefas concluídas não são aprovação para implementar. A obrigatoriedade está registrada em `docs/requirements/decisoes-pendentes.md` (TEC-03), conforme o escopo desta revisão.

Fluxo recomendado, sujeito à formalização do checklist e responsáveis:

1. Ler `CLAUDE.md`, o requisito canônico relevante, esta arquitetura e o [registro de decisões pendentes](../requirements/decisoes-pendentes.md).
2. Criar mudança OpenSpec com problema, origem (IDs/versão dos requisitos e decisões), escopo, fora de escopo e critério de aceite; declarar explicitamente quando não altera regra de produto.
3. Descrever deltas de especificação sem copiar integralmente o requisito canônico; contradição ou mudança de regra exige decisão/aprovação de produto antes de implementar.
4. Incluir design quando houver impacto em módulos, dados, segurança, operação ou migrações, e tarefas revisáveis.
5. Registrar aprovação humana aplicável com aprovador, data, escopo e artefatos/versões; não inferir aprovação a partir do estado dos artefatos.
6. Relacionar requisito/decisão → cenário/delta → tarefa → teste ou evidência de validação. Atualizar arquitetura/documentação quando decisões aprovadas mudarem.
7. Após validação, sincronizar/arquivar conforme o fluxo da versão adotada e preservar rastreabilidade.

Ainda é necessário decidir se haverá specs-base curadas a partir dos requisitos aprovados ou se cada mudança citará diretamente as fontes canônicas. O repositório contém `schema: spec-driven` e a change proposta `2026-10-18-technical-foundation`, mas ainda não há specs-base. Os comentários de `openspec/config.yaml` devem descrever a obrigatoriedade do processo sem sugerir governança automática. Não presumir versão, comandos ou convenções específicas da CLI: verificar a documentação da release efetivamente selecionada antes de documentá-los.

## 25. Documentação e contexto de agentes

- `CLAUDE.md` na raiz é índice conciso para estas fontes e limites operacionais; não duplicar arquitetura. Orientações OpenSpec devem ser consistentes com o uso obrigatório e com a governança manual.
- Requisitos aprovados mantidos como documento canônico. Mudanças propostas registram origem, aprovador, versão e impacto.
- Arquitetura atualizada quando decisões aprovadas alterarem fronteiras, dados, segurança ou operação; usar ADRs quando uma decisão técnica duradoura exigir histórico. Não criar ADR vazio.
- Pendências centralizadas em [`../requirements/decisoes-pendentes.md`](../requirements/decisoes-pendentes.md); registrar status, aprovador e data quando resolvidas, sem reescrever o requisito original silenciosamente.
- Não criar `AGENTS.md` automaticamente; considerar apenas se integração de outras ferramentas exigir instruções próprias e sem duplicação conflitante.

## 26. Plano incremental de implementação (não executado)

A sequência evita dependências de negócio não aprovadas. Critérios abaixo são metas a validar em especificações, não entregáveis já existentes.

| Etapa | Objetivo e entregáveis | Dependências | Critérios de conclusão |
|---|---|---|---|
| 0. Decisões e fundação local | Fechar lacunas residuais PROD-02/03/04/06/07, OPS-01/03/05 e TEC-01/02/03; selecionar versões compatíveis e documentar fluxo local; manter deploy/gestão GCP fora do projeto | Aprovação de produto e responsáveis técnicos | Decisões bloqueadoras registradas/aprovadas; versões compatíveis documentadas; sem custo/produção não autorizados |
| 1. Fundação do repositório | Estruturas web/API, lint/type-check, configuração segura, logging básico, contratos, CI não produtiva | Etapa 0; equipe/ambientes escolhidos | builds repetíveis; segredos não entram em artefatos; testes básicos em CI |
| 2. Persistência e calendário | Modelo de torneio, grupos/seleções/rodadas/partidas; migrations; processo de carga manual auditável | PROD-02/03, OPS-06 e fonte oficial | constraints testadas; fixtures conferidos por responsável; mudanças de calendário versionadas |
| 3. Identidade e acesso | Admissão, login, sessão, autorização admin/participante, troca/recuperação de senha e e-mail | PROD-07/08, OPS-03 e TEC-01; etapa 1 | anti-enumeração, uso único/expiração, controles de sessão e permissões testados |
| 4. Palpites | Interface/API de leitura/escrita, corte e grade pós-corte | Etapas 2–3; PROD-01/02/05 | requisições recebidas no corte/depois rejeitadas; requisições recebidas antes podem concluir depois; concorrência coberta em PostgreSQL; zero exposição pré-corte em testes |
| 5. Resultados e apuração | Entrada/revisão oficial, auditoria e cálculo 6/3/2/1/0/120 minutos | Etapa 4; PROD-03/04 | tabela de pontuação homologada; recálculo idempotente; correção rastreável |
| 6. Ranking e histórico | Agregados por rodada, aplicação dos desempates aprovados e detalhes explicativos | Etapa 5 | resultados determinísticos e auditáveis; progresso da apuração claramente apresentado |
| 7. Administração e suporte | Painel de partidas/resultados, gestão de tickets, trilha de auditoria e controles | Etapa 3; PROD-08/OPS-01 | RBAC e acesso auditado; fluxo de suporte homologado |
| 8. Estatísticas, badges e experiência | Gráficos, badges, grupos/chaveamento, acessibilidade e UX final | Etapa 6; PROD-06 (pendências 06.5/06.6); dados oficiais | métricas reproduzíveis; critérios de badges aprovados e pendências 06.5/06.6 resolvidas; verificação acessível/manual |
| 9. Endurecimento e homologação | Testes integrados/E2E, segurança, acessibilidade, desempenho, revisão de privacidade | Etapas anteriores | defeitos críticos resolvidos; critérios de aceite e calendário conferidos por responsável |
| 10. Execução local e portabilidade documental | Compose local, configuração segura e documentação das fronteiras para portabilidade | TEC-02; OPS-03 para e-mails | execução local validada por execução real (o scaffold existe, mas não foi validado); sem deployment GCP nem promessa de backup/restore |

Não estabelecer datas artificiais sem capacidade, responsáveis e prazo aprovados.

## 27. Bloqueios e próxima ação

- **Estado do repositório:** o estado de rastreamento é volátil e não constitui decisão arquitetural; consulte Git para o estado atual. A ausência de implementação, configuração local e dados de partidas deve ser reavaliada antes da fundação, não tratada como afirmação permanente.

- **Dados ausentes:** na análise de 18/10/2026 não havia código, Compose/Dockerfiles, manifests nem `.env.example`; em 19/10/2026 existem como scaffold. Continuam ausentes CI, testes e dados oficiais de partidas/seleções. ADR-001 registra direções aprovadas pelo solicitante, sem aprovador organizacional identificado nem aprovação da implementação.
- **Próxima ação recomendada:** resolver pendências de produto/operação antes dos fluxos dependentes e selecionar versões/configuração local antes da fundação. Seguir a revisão em `revisao-arquitetura-multiagentes.md` e o registro canônico de decisões pendentes. Adoção de OpenSpec é obrigatória; convenções de baseline, aprovação e rastreabilidade permanecem pendentes.

## 28. Escopo desta atualização documental

Em 19/10/2026, esta atualização registra no ADR-001 as direções arquiteturais aprovadas, harmoniza inicialmente a HU-22 do requisito v3.3 e depois a atualização v3.4 (reverificação do novo endereço, três tentativas e HU-23), além de atualizar o contexto de `openspec/config.yaml` sem mudar seu `schema: spec-driven`. Não implementa funcionalidades, endpoints, telas, migrações, testes ou Compose; não instala dependências, inicializa OpenSpec, cria recursos de nuvem ou realiza operações destrutivas/em produção. Compatibilidade de runtime não foi testada.
