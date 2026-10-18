PROMPT MESTRE — ARQUITETURA DE SOFTWARE
=======================================

Bolão da Copa do Mundo Feminina da FIFA Brasil 2027
---------------------------------------------------

1. Papel e missão

-----------------

Atue como **Arquiteto(a) de Software Sênior**, com experiência prática em Domain-Driven Design (DDD), Arquitetura Limpa, sistemas web, segurança de aplicações, modelagem relacional, cloud computing, testes automatizados e desenvolvimento assistido por agentes de IA.

Sua missão nesta execução é analisar os requisitos do projeto e produzir:

1. **Obrigatório:** `CLAUDE.md`, na raiz do repositório.

2. **Obrigatório:** `docs/architecture/arquitetura-software.md`, contendo a arquitetura de software proposta, decisões justificadas, riscos, pendências e plano incremental de implementação.

Você deve preparar uma base arquitetural clara e sustentável para que o projeto possa ser desenvolvido posteriormente com Claude Code e, se aprovado, com uma abordagem de Specification-Driven Development (SDD), usando OpenSpec ou ferramenta equivalente.

**Não implemente funcionalidades do produto nesta execução.** Não crie o sistema completo, não gere telas funcionais, não implemente endpoints de negócio e não faça migrações de banco. O escopo é analisar, decidir, documentar e preparar o contexto persistente do agente.

2. Contexto e fonte de verdade

------------------------------

O projeto é um sistema de bolão para a Copa do Mundo Feminina da FIFA Brasil 2027. O sistema será utilizado por um grupo único de participantes, sem necessidade de suportar múltiplas organizações ou ligas independentes nesta primeira versão.

Leia integralmente o documento de requisitos disponível em:

`docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`

O documento de requisitos aprovado é a principal fonte de verdade do produto. A versão de referência inicial para esta análise era 3.0, de 13/09/2026; após a decisão de produto PROD-01 registrada em 18/10/2026, o requisito canônico foi revisado para a versão 3.1, de 18/10/2026. Consulte sempre a versão vigente no caminho indicado acima.

Se o arquivo não existir nesse caminho, procure documentos de requisitos já existentes no repositório. Não invente nem reconstrua silenciosamente um documento ausente. Registre a ausência e solicite que o responsável disponibilize o arquivo correto.

### Hierarquia de precedência

Ao encontrar divergências, aplique esta ordem:

1. Requisitos de produto formalmente aprovados.

2. Decisões de produto confirmadas pelo responsável.

3. Decisões arquiteturais formalmente registradas e aprovadas.

4. Este prompt.

5. Documentação técnica oficial e boas práticas, utilizadas para orientar a solução sem modificar regras de negócio.

Documentação técnica pode justificar escolhas de implementação, mas não pode substituir ou alterar requisitos do produto.

Não resolva ambiguidades de negócio por conta própria. Proponha alternativas, recomende uma opção, explique as consequências e registre a decisão como pendente de aprovação.

3. Tecnologias e contexto inicial

---------------------------------

Considere como direção tecnológica inicial:

* Frontend: Next.js com TypeScript.

* Backend: Python com FastAPI.

* Banco de dados: PostgreSQL.

* Plataforma de produção: Google Cloud Platform (GCP).

* Agente de desenvolvimento: Claude Code.

* Gestão de especificações: avaliar OpenSpec e uma abordagem SDD.

* Versionamento: Git.

Essas escolhas são a direção inicial, não uma justificativa para ignorar incompatibilidades, limitações ou custos. Valide versões suportadas, integração entre componentes, manutenção, segurança e operação. Registre alternativas quando houver uma decisão relevante.

Não introduza microserviços, Kubernetes, mensageria, cache distribuído ou outros componentes operacionais complexos sem demonstrar uma necessidade concreta. Prefira a solução mais simples que satisfaça os requisitos e permita evolução segura.

4. Regras de negócio que precisam ser preservadas

-------------------------------------------------

Use o documento de requisitos como referência integral. Os pontos abaixo são lembretes de aspectos críticos e não substituem a leitura do documento original.

### 4.1 Torneio e calendário

* Copa do Mundo Feminina da FIFA Brasil 2027.

* 32 seleções e 8 grupos.

* 64 partidas no total.

* Fase de grupos com 48 partidas e fase eliminatória com 16.

* Período previsto: 24 de junho a 25 de julho de 2027.

* Apresentação dos horários em horário de Brasília (UTC-3), com atenção a mudanças oficiais de calendário e fuso.

Não presuma que datas, horários, confrontos ou regras de classificação permanecerão imutáveis. O modelo deve permitir registrar os dados oficiais confirmados.

### 4.2 Palpites e privacidade

* Os palpites devem ser encerrados uma hora antes do início previsto de cada partida.

* A validação do prazo deve ocorrer no backend, e não apenas na interface.

* Depois do encerramento, os palpites dos participantes tornam-se visíveis aos demais participantes, conforme as regras de acesso.

* Antes do encerramento, um participante comum não pode consultar os palpites de outros participantes.

* Considere requisições concorrentes próximas ao horário-limite, alteração do horário de uma partida e diferenças entre o relógio do navegador e o relógio do servidor.

Proponha uma regra técnica consistente para o instante de corte, baseada em horário confiável no backend, e registre como pendência qualquer comportamento de negócio que não esteja definido no documento aprovado.

### 4.3 Pontuação

A pontuação deve seguir as regras excludentes definidas no documento:

* 6 pontos: placar exato.

* 3 pontos: acerta o resultado geral — vitória de uma equipe ou empate — e os gols de exatamente uma das equipes.

* 2 pontos: acerta o resultado geral, mas erra os gols das duas equipes.

* 1 ponto: erra o resultado geral, mas acerta os gols de uma equipe.

* 0 ponto: demais casos.

Antes de formalizar a regra, confira a redação original e identifique qualquer possível sobreposição entre categorias. Documente uma tabela de decisão com exemplos de placares para validar que cada combinação resulte em uma única pontuação.

Nos jogos eliminatórios, o resultado usado no bolão considera o placar ao fim dos 120 minutos, incluindo prorrogação. Os gols da disputa de pênaltis não devem ser incorporados ao placar usado na pontuação. Um empate após 120 minutos continua sendo empate para essa finalidade.

Não altere essa regra por conveniência técnica.

### 4.4 Rodadas e ranking

Considere as sete rodadas de referência:

1. Grupos — R1.

2. Grupos — R2.

3. Grupos — R3.

4. Oitavas de final.

5. Quartas de final.

6. Semifinais.

7. Disputa do terceiro lugar e final.

O ranking deve respeitar a ordem de desempate especificada nos requisitos:

1. Pontuação total decrescente.

2. Quantidade de placares exatos, correspondentes a 6 pontos, decrescente.

3. Quantidade de acertos de 3 pontos decrescente.

4. Pontuação acumulada em rodadas anteriores, decrescente, ignorando esse critério em R1.

5. Nome de exibição normalizado, sem acentos e sem distinção entre maiúsculas e minúsculas, em ordem crescente.

Defina como a arquitetura representará os resultados por rodada, o histórico necessário para calcular o ranking e a estratégia para garantir resultados determinísticos. Não invente como tratar rodadas ainda incompletas: registre o problema, apresente alternativas e peça validação.

### 4.5 Resultados oficiais e recálculo

* Resultados oficiais são informados ou corrigidos por administradores.

* Alterações de resultado podem exigir recálculo de pontuação, estatísticas e ranking.

* O recálculo precisa ser idempotente: executar novamente com os mesmos dados não pode produzir pontuações duplicadas ou resultados divergentes.

* A solução deve permitir rastrear quem realizou uma alteração administrativa, quando ela ocorreu e o que foi alterado, respeitando os requisitos de auditoria e privacidade.

Proponha uma estratégia consistente para transações, recálculo, concorrência e auditoria. Diferencie dados oficiais, palpites, cálculos derivados e dados históricos.

### 4.6 Contas e autenticação

Considere:

* Cadastro e autenticação.

* Alteração de senha.

* Recuperação de senha por e-mail com token único, válido por 30 a 60 minutos, conforme a regra aprovada.

* Resposta que não revele se determinado e-mail possui cadastro.

* Proteção de credenciais, sessões, tokens e endpoints sensíveis.

A arquitetura deve recomendar controles de segurança concretos sem presumir que uma biblioteca ou provedor específico já foi escolhido.

### 4.7 Administração, suporte e gamificação

Considere as necessidades descritas nos requisitos para:

* Painel administrativo.

* Gestão de partidas e resultados.

* Suporte com protocolo e painel de acompanhamento.

* Grupos, classificação e chaveamento.

* Estatísticas e gráficos.

* Badges e gamificação.

Os critérios exatos de algumas badges e regras operacionais podem estar incompletos. Não os invente como regras definitivas. Registre-os em uma lista de decisões pendentes.

### 4.8 Limites de escopo

A primeira versão não contempla:

* Apostas financeiras ou movimentação de dinheiro.

* Transmissão de vídeo.

* Ligas públicas.

* Integração paga com API de resultados.

Os resultados serão informados por administradores. Não adicione funcionalidades fora do escopo sem registrar justificativa, impacto e aprovação.

5. Pesquisa técnica obrigatória

-------------------------------

Consulte documentação oficial atualizada para as tecnologias e ferramentas que realmente influenciem a arquitetura.

Priorize fontes oficiais, por exemplo:

* Next.js: [Next.js Docs](https://nextjs.org/docs)

* TypeScript: https://www.typescriptlang.org/docs/

* FastAPI: [https://fastapi.tiangolo.com/](https://fastapi.tiangolo.com/)

* Python: [3.15.0 Documentation](https://docs.python.org/3/)

* PostgreSQL: [PostgreSQL: Documentation](https://www.postgresql.org/docs/)

* SQLAlchemy: [https://docs.sqlalchemy.org/](https://docs.sqlalchemy.org/)

* Alembic: [https://alembic.sqlalchemy.org/](https://alembic.sqlalchemy.org/)

* Google Cloud Architecture Framework: https://cloud.google.com/architecture/framework

* Cloud Run: https://cloud.google.com/run/docs

* Cloud SQL: https://cloud.google.com/sql/docs

* Secret Manager: https://cloud.google.com/secret-manager/docs

* OWASP Application Security Verification Standard: [OWASP Application Security Verification Standard (ASVS) | OWASP Foundation</title><meta name="description" content="The OWASP Application Security Verification Standard (ASVS) Project provides a basis for testing web application technical security controls and also provides developers with a list of requirements…"/><meta name="application-name" content="OWASP Foundation"/><meta name="author" content="OWASP Foundation"/><meta name="keywords" content="OWASP Application Security Verification Standard (ASVS),OWASP project,open source security,OWASP,OWASP Foundation,application security,software security"/><meta name="publisher" content="OWASP Foundation"/><meta name="google" content="notranslate"/><link rel="canonical" href="https://owasp.org/projects/asvs"/><meta property="og:title" content="OWASP Application Security Verification Standard (ASVS) | OWASP Foundation"/><meta property="og:description" content="The OWASP Application Security Verification Standard (ASVS) Project provides a basis for testing web application technical security controls and also provides developers with a list of requirements…"/><meta property="og:url" content="https://owasp.org/projects/asvs"/><meta property="og:site_name" content="OWASP Foundation"/><meta property="og:locale" content="en_US"/><meta property="og:image" content="https://owasp.org/images/og/owasp-default.png"/><meta property="og:image:width" content="1200"/><meta property="og:image:height" content="630"/><meta property="og:image:alt" content="OWASP Foundation — the open source foundation for application security"/><meta property="og:type" content="website"/><meta name="twitter:card" content="summary_large_image"/><meta name="twitter:site" content="@owasp"/><meta name="twitter:creator" content="@owasp"/><meta name="twitter:title" content="OWASP Application Security Verification Standard (ASVS) | OWASP Foundation"/><meta name="twitter:description" content="The OWASP Application Security Verification Standard (ASVS) Project provides a basis for testing web application technical security controls and also provides developers with a list of requirements…"/><meta name="twitter:image" content="https://owasp.org/images/og/owasp-default.png"/><meta name="twitter:image:alt" content="OWASP Foundation — the open source foundation for application security"/><meta name="twitter:image:width" content="1200"/><meta name="twitter:image:height" content="630"/><link rel="icon" href="/images/logos/favicon-owasp.svg"/><link rel="apple-touch-icon" href="/images/logos/favicon-owasp.svg"/><script>(function(){try{var m=document.cookie.match(/(?:^|;\s*)owasp-theme=([^;]*)/);var p=m?decodeURIComponent(m[1]):'light';var d=p==='dark'||(p==='system'&&window.matchMedia('(prefers-color-scheme: dark)').matches);if(d)document.documentElement.classList.add('dark');}catch(e){}})();</script><script src="/_next/static/immutable/chunks/0c0hxoamwjsbw.js" noModule=""></script></head><body translate="no" class="iqw2EW_className"><div hidden=""><!--$--><!--/$--></div><div class="min-h-screen bg-surface-sunken"><header class="backdrop-blur-[5px] backdrop-filter bg-surface-inverse/95 sticky top-0 w-full z-50 border-b border-white/10 shadow-sm transition-transform duration-300 ease-out translate-y-0"><div class="flex flex-row items-center h-20"><div class="box-border flex flex-row h-20 items-center justify-between px-4 sm:px-6 md:px-8 lg:px-12 xl:px-16 2xl:px-[120px] py-0 relative w-full max-w-[1440px] mx-auto"><a class="h-10 relative shrink-0 w-[132.894px] hover:opacity-90 transition-opacity" aria-label="OWASP home" href="/"><svg class="owasp-logo block h-full w-full text-white" viewBox="0 0 133 40" preserveAspectRatio="none" role="img" aria-labelledby="owasp-logo-header" xmlns="http://www.w3.org/2000/svg"><title id="owasp-logo-header">OWASP Foundation](https://owasp.org/www-project-application-security-verification-standard/)

* OWASP API Security: https://owasp.org/www-project-api-security/

* Claude Code: [Overview - Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code/overview)

* OpenSpec: [GitHub - Fission-AI/OpenSpec: Spec-driven development (SDD) for AI coding assistants. · GitHub](https://github.com/Fission-AI/OpenSpec)

Os endereços são pontos de partida. Verifique se continuam válidos e se são pertinentes. Consulte a documentação oficial específica das versões recomendadas.

Não afirme que consultou uma fonte que não conseguiu acessar. Diferencie claramente fatos confirmados pela documentação, inferências técnicas e recomendações suas. Registre links e a data de consulta no documento de arquitetura.

Não é necessário pesquisar extensivamente tecnologias que não tenham relação direta com as decisões em análise.

6. Análise arquitetural

-----------------------

Avalie e justifique uma arquitetura inicialmente baseada em monólito modular, separação de responsabilidades e fronteiras de domínio claras.

Considere, conforme fizer sentido:

* Domain-Driven Design (DDD).

* Arquitetura Limpa.

* Separação entre domínio, aplicação, infraestrutura e apresentação.

* Inversão de dependências.

* Módulos com responsabilidades explícitas.

* Interfaces entre módulos.

* Transações e consistência de dados.

* Testabilidade.

* Segurança por padrão.

* Observabilidade.

* Evolução incremental.

Não use DDD ou Arquitetura Limpa apenas como rótulos. Explique como se traduzem em diretórios, dependências, casos de uso, entidades, serviços de domínio, repositórios e adaptadores. Evite abstrações sem benefício demonstrável.

Avalie possíveis contextos de domínio, sem tratá-los como decisão definitiva antes da análise:

* Identidade e acesso.

* Torneio e calendário.

* Palpites.

* Apuração e pontuação.

* Ranking e estatísticas.

* Administração e auditoria.

* Suporte.

* Gamificação.

Para cada módulo proposto, defina sua responsabilidade, os dados sob sua autoridade, os casos de uso principais, as dependências permitidas e as dependências proibidas.

7. Backend

----------

Recomende uma organização coerente para FastAPI e Python.

Avalie:

* Estrutura de pacotes e módulos.

* Camada de domínio.

* Camada de aplicação e casos de uso.

* Adaptadores de entrada, incluindo API HTTP.

* Adaptadores de saída, incluindo persistência e e-mail.

* Modelagem e limites transacionais.

* Validação de entrada.

* Tratamento uniforme de erros.

* Autorização e autenticação.

* Migrações de banco.

* Configuração por ambiente.

* Logs, métricas e rastreabilidade.

* Testes unitários, integração e contrato.

Explique como evitar que regras de negócio fiquem acopladas a rotas HTTP, ORM, framework ou serviços externos.

Avalie SQLAlchemy e Alembic ou alternativas justificadas. Não crie código de implementação nesta execução.

8. Frontend

-----------

Recomende a organização do Next.js com TypeScript.

Explique:

* Separação entre componentes, páginas ou rotas, funcionalidades e acesso à API.

* Limites entre componentes de servidor e de cliente, conforme a versão recomendada.

* Estratégia para autenticação e proteção de rotas.

* Validação de formulários e apresentação de erros.

* Tratamento de carregamento, falha e ausência de dados.

* Gestão de estado, sem adicionar bibliotecas desnecessárias.

* Acessibilidade e responsividade.

* Formatação de datas e horários em Brasília.

* Testes de componentes e fluxos críticos.

* Segurança de dados e prevenção de exposição de palpites antes do corte.

Não exponha segredos ou credenciais no frontend. Não confie na interface para impor regras de autorização ou prazos.

9. Persistência e modelo de dados

---------------------------------

Proponha um modelo conceitual de dados e suas principais relações.

Avalie entidades ou agregados para:

* Usuário.

* Credencial ou identidade de autenticação, se aplicável.

* Seleção.

* Grupo do torneio.

* Partida.

* Palpite.

* Resultado oficial.

* Apuração ou registro de pontuação.

* Ranking e histórico por rodada.

* Token de recuperação de senha.

* Protocolo de suporte.

* Evento de auditoria.

* Badge e concessão de badge, se necessário.

Os nomes são sugestões conceituais e podem ser ajustados. Não assuma que cada conceito precisa virar uma tabela independente.

Descreva:

* Identificadores e relacionamentos.

* Restrições de integridade.

* Unicidade de palpites por participante e partida.

* Estratégia para timestamps e UTC.

* Armazenamento e apresentação de horários.

* Índices prováveis.

* Política de migrações.

* Integridade entre resultados, pontuações e ranking.

* Retenção de dados e auditoria como decisões a validar.

Diferencie dados de origem, dados calculados e possíveis projeções ou snapshots. Justifique quando recalcular dados e quando persistir resultados derivados.

Não produza uma migração SQL executável nesta fase.

10. Segurança e privacidade

---------------------------

Use OWASP e documentação oficial como referências. Inclua, no mínimo:

* Autenticação e autorização.

* Privilégios mínimos.

* Proteção de rotas administrativas.

* Controle de acesso a palpites por estado e horário da partida.

* Validação no backend.

* Proteção contra enumeração de contas.

* Tokens de recuperação de senha seguros, de uso único e com expiração.

* Gestão de segredos.

* TLS e configuração segura de ambientes.

* Limitação de tentativas e proteção contra abuso, quando pertinente.

* CORS e proteção contra ataques web, de acordo com a arquitetura escolhida.

* Validação de dados e consultas parametrizadas.

* Proteção contra exposição de informações pessoais em logs.

* Auditoria de operações administrativas.

* Backups, recuperação e controle de acesso ao banco.

* Dependências, atualizações e análise de vulnerabilidades.

Diferencie requisitos obrigatórios, controles recomendados e controles cuja necessidade depende de uma decisão futura. Não declare conformidade formal com uma norma sem evidência.

11. Infraestrutura GCP

----------------------

Proponha uma arquitetura inicial de produção adequada ao porte e aos requisitos do sistema. Avalie, sem presumir que todos serão necessários:

* Cloud Run para serviços de aplicação.

* Cloud SQL para PostgreSQL.

* Secret Manager para segredos.

* Cloud Logging e Cloud Monitoring.

* Serviço de envio de e-mail.

* Armazenamento de arquivos, se houver necessidade concreta.

* CI/CD.

* Rede, IAM, contas de serviço e acesso privado ao banco.

* Backups, recuperação e atualização de banco.

* Ambientes de desenvolvimento, homologação e produção.

Explique a comunicação entre frontend e backend, a exposição pública, a proteção dos serviços e o acesso ao banco.

Avalie se frontend e backend devem ser implantados separadamente ou juntos, considerando Next.js, escalabilidade, custo, segurança e operação. Não assuma que a hospedagem do frontend precisa ser na GCP se outra opção for mais adequada; registre a comparação e a recomendação.

Inclua uma visão de custo relativo e dos principais fatores que influenciam o custo, sem inventar valores atuais. Se apresentar estimativas monetárias, cite preços oficiais, data e premissas.

Não crie recursos de nuvem, contas, credenciais, infraestrutura ou configurações de produção nesta execução.

12. Datas, concorrência e integridade

-------------------------------------

Analise os seguintes casos críticos:

* Palpite recebido exatamente no instante do encerramento.

* Duas requisições concorrentes para alterar o mesmo palpite.

* Alteração oficial do horário de uma partida.

* Partida adiada, cancelada ou suspensa.

* Resultado oficial corrigido após a apuração.

* Reexecução do cálculo de pontos.

* Acesso simultâneo ao ranking durante recálculo.

* Partida que termina empatada após 120 minutos e é decidida nos pênaltis.

* Rodada com partidas ainda não concluídas.

Para cada caso, descreva o comportamento tecnicamente recomendado, identifique o que os requisitos já determinam e registre o que exige decisão do responsável pelo produto.

13. Estratégia de testes

------------------------

Defina uma pirâmide de testes proporcional ao projeto, incluindo:

* Testes unitários de regras de domínio.

* Testes parametrizados para a tabela de pontuação.

* Testes de casos de uso.

* Testes de integração com PostgreSQL.

* Testes de API.

* Testes de autorização e privacidade.

* Testes de concorrência e corte de palpites.

* Testes de recálculo idempotente.

* Testes de ranking e critérios de desempate.

* Testes de integração do frontend com a API.

* Testes end-to-end dos fluxos críticos.

* Testes de migrações e recuperação, quando aplicável.

Diferencie o que deve ser validado automaticamente do que depende de testes manuais ou homologação. Não crie os testes nesta execução; documente a estratégia e os critérios de qualidade.

14. OpenSpec e desenvolvimento orientado a especificações

---------------------------------------------------------

Avalie OpenSpec como possível ferramenta para organizar mudanças orientadas por especificações.

Explique:

* Como uma funcionalidade futura será descrita antes da implementação.

* Como requisitos, especificações, design e tarefas serão relacionados.

* Como o agente deverá consultar a arquitetura e os requisitos antes de trabalhar.

* Como mudanças de negócio serão propostas, revisadas e aprovadas.

* Como evitar que o agente altere silenciosamente regras aprovadas.

* Como manter documentação e implementação consistentes.

* Quais comandos e versões são necessários, apenas se confirmados na documentação oficial.

Não instale OpenSpec nem altere a configuração do repositório nesta primeira execução, a menos que o responsável tenha solicitado expressamente. Registre uma recomendação de adoção e pré-requisitos. Não invente comandos de instalação ou de uso.

15. Instruções persistentes para Claude Code

--------------------------------------------

Crie ou atualize `CLAUDE.md` na raiz do repositório.

Antes de alterá-lo, verifique se já existe. Se existir, leia-o integralmente, preserve instruções válidas e avalie cuidadosamente eventuais conflitos. Não apague instruções existentes de forma indiscriminada.

O `CLAUDE.md` deve ser conciso, operacional e servir como índice das instruções do projeto, sem duplicar a arquitetura inteira.

Ele deve incluir:

* Objetivo e contexto resumido do projeto.

* Referência ao documento de requisitos.

* Referência ao documento de arquitetura.

* Hierarquia de precedência entre requisitos, decisões aprovadas e pedidos pontuais.

* Stack e padrões arquiteturais aprovados.

* Regras de segurança e proteção de dados.

* Expectativas para testes, qualidade e revisão.

* Orientação para consultar documentação oficial das versões em uso.

* Proibição de inventar regras de negócio ou alterar requisitos aprovados silenciosamente.

* Obrigação de registrar dúvidas e solicitar decisões humanas quando necessário.

* Restrições para operações destrutivas, segredos, infraestrutura e produção.

* Orientação para mudanças incrementais e especificações antes da implementação, quando o fluxo SDD estiver aprovado.

* Comandos do projeto somente quando confirmados no repositório; não invente comandos.

Não inclua segredos, tokens, senhas, chaves ou dados pessoais. Não declare como já aprovadas decisões que ainda estejam pendentes.

Não crie `AGENTS.md` automaticamente nesta execução. Só recomende sua criação se houver uma necessidade concreta de compatibilidade com outras ferramentas ou agentes.

16. Estrutura documental

------------------------

Inspecione a estrutura atual do repositório antes de criar diretórios ou arquivos. Preserve os arquivos existentes.

Se não houver estrutura equivalente, use como referência:

* `CLAUDE.md`

* `docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`

* `docs/architecture/arquitetura-software.md`

* `docs/architecture/PROMPT-ARQUITETURA-CLAUDE-CODE.md`

* `docs/architecture/decisoes-pendentes.md`

* `docs/architecture/adr/`, para decisões arquiteturais formalizadas ao longo do projeto

* `docs/architecture/referencias-tecnicas.md`, se for útil separar as fontes consultadas

Não crie arquivos vazios sem utilidade. Não duplique o documento original de requisitos sem necessidade. Se o documento de requisitos não estiver disponível, registre o bloqueio e não o substitua por um resumo gerado.

17. Conteúdo obrigatório do documento de arquitetura

----------------------------------------------------

O arquivo `docs/architecture/arquitetura-software.md` deve incluir, no mínimo:

1. Título, versão do documento, data de elaboração e status.

2. Resumo executivo.

3. Objetivo e escopo.

4. Fontes consultadas e hierarquia de requisitos.

5. Requisitos funcionais e não funcionais relevantes à arquitetura.

6. Restrições e premissas.

7. Decisões já definidas versus decisões pendentes.

8. Atributos de qualidade e prioridades.

9. Visão arquitetural geral.

10. Diagrama de contexto do sistema.

11. Diagrama de contêineres ou componentes principais.

12. Justificativa para a arquitetura escolhida e alternativas avaliadas.

13. Módulos de domínio e suas responsabilidades.

14. Regras de dependência entre módulos.

15. Organização proposta do frontend.

16. Organização proposta do backend.

17. Modelo conceitual de dados.

18. Estratégia de autenticação e autorização.

19. Segurança, privacidade e auditoria.

20. Estratégia de palpites, corte e visibilidade.

21. Estratégia de pontuação, recálculo e ranking.

22. Transações, concorrência e idempotência.

23. Estratégia de testes e qualidade.

24. Infraestrutura e implantação GCP.

25. Configuração, segredos e observabilidade.

26. CI/CD e gestão de ambientes.

27. Estratégia SDD/OpenSpec.

28. Estratégia de documentação e contexto para agentes.

29. Riscos técnicos e mitigação.

30. Decisões pendentes com impacto, opções e recomendação.

31. Plano incremental de implementação, com dependências e critérios de conclusão.

32. Fontes técnicas, links e data de consulta.

Use diagramas em Mermaid quando agregarem clareza. Garanta que os diagramas reflitam o texto. Não invente resultados de benchmark, preços, capacidades ou decisões que não foram verificadas.

18. Decisões pendentes a investigar

-----------------------------------

Verifique no documento original se estes assuntos já foram resolvidos. Se não, registre-os, sem presumir respostas:

* Critério de desempate durante uma rodada incompleta e significado de “rodadas anteriores”.

* Semântica exata do instante de corte e requisições concorrentes.

* Procedimento quando o horário de uma partida muda após a publicação.

* Tratamento de jogos adiados, cancelados, suspensos ou abandonados.

* Quando um resultado é considerado definitivo e se existe reabertura de apuração.

* Política para corrigir palpites ou resultados depois do encerramento.

* Critérios, concessão e eventual revogação de badges.

* Entrada, convite, remoção ou desativação de participantes.

* Regras de administração e separação de privilégios.

* Retenção, exclusão, anonimização e auditoria de dados.

* Regras para rodadas incompletas e ranking provisório.

* Política de backup, recuperação e objetivos de recuperação.

* Provedor de e-mail e estratégia de envio.

* Necessidade e limites de notificações.

* Custos, disponibilidade e responsabilidades operacionais.

Para cada pendência, informe:

* Identificador.

* Pergunta objetiva.

* O que os requisitos atuais dizem.

* Por que a decisão é necessária.

* Opções consideradas.

* Recomendação técnica ou de produto, claramente identificada como proposta.

* Impacto de cada alternativa.

* Quem deve aprovar, quando isso puder ser identificado.

* Se a decisão bloqueia o início de alguma parte da implementação.
19. Plano de implementação

--------------------------

Proponha uma sequência incremental, sem executar as etapas.

A sequência deve contemplar, conforme apropriado:

* Validação dos requisitos e resolução das decisões bloqueadoras.

* Fundação do repositório e ferramentas.

* Estrutura inicial do frontend e backend.

* Configuração de ambientes e banco.

* Identidade e acesso.

* Cadastro do torneio e partidas.

* Registro e encerramento de palpites.

* Resultados oficiais.

* Cálculo de pontos e ranking.

* Administração e auditoria.

* Suporte, estatísticas e gamificação.

* Testes integrados, segurança e acessibilidade.

* Implantação, monitoramento, backup e ensaio de recuperação.

Para cada etapa, descreva objetivo, dependências, entregáveis e critérios de aceite. Não estabeleça datas artificiais sem dados de capacidade, equipe ou prazo aprovados.

20. Regras de execução nesta primeira sessão

--------------------------------------------

Antes de editar arquivos:

1. Inspecione a raiz e a estrutura existente.

2. Verifique o estado do Git e arquivos já modificados, se o repositório usar Git.

3. Localize e leia o documento de requisitos.

4. Leia os arquivos de instruções existentes, inclusive `CLAUDE.md`.

5. Identifique documentação, decisões e convenções existentes.

6. Confirme quais fontes oficiais consegue consultar.

7. Identifique lacunas ou conflitos relevantes.

Em seguida, produza os dois entregáveis obrigatórios.

Não sobrescreva arquivos de maneira indiscriminada. Preserve conteúdo válido e faça alterações localizadas. Não execute comandos destrutivos, não exponha segredos e não realize operações em produção.

Não instale dependências, não altere arquivos de configuração executáveis e não crie recursos de nuvem sem necessidade e autorização explícita.

Se não houver informação suficiente para uma decisão, documente a pendência em vez de inventar uma resposta.

21. Critérios de aceite

-----------------------

A execução só estará concluída quando:

* `CLAUDE.md` existir na raiz e contiver instruções persistentes, concisas e coerentes.

* `docs/architecture/arquitetura-software.md` existir e conter todas as seções obrigatórias ou explicar claramente qualquer seção bloqueada por falta de informação.

* O documento de requisitos tiver sido lido, se estiver disponível.

* As regras de negócio não tiverem sido alteradas silenciosamente.

* As decisões arquiteturais estiverem justificadas e separadas das decisões pendentes.

* As principais fronteiras de domínio, dependências e responsabilidades estiverem descritas.

* A segurança, a privacidade dos palpites, o corte de uma hora, a pontuação, o recálculo e o ranking tiverem tratamento explícito.

* As recomendações de GCP e operação forem proporcionais ao escopo e acompanhadas das premissas.

* As referências técnicas consultadas estiverem identificadas, sem alegar pesquisas não realizadas.

* Os riscos e bloqueios estiverem visíveis.

* Nenhuma funcionalidade de negócio tiver sido implementada nesta execução.

* Nenhuma operação destrutiva ou de produção tiver sido realizada.
22. Resposta final do agente

----------------------------

Ao terminar, apresente um resumo objetivo com:

1. Arquivos criados ou atualizados.

2. Principais decisões arquiteturais recomendadas e justificativas.

3. Alternativas relevantes consideradas.

4. Decisões pendentes que exigem o responsável pelo produto.

5. Riscos ou bloqueios encontrados.

6. Fontes oficiais efetivamente consultadas.

7. Próxima ação recomendada antes de iniciar a implementação.

8. Confirmação explícita de que a execução ficou restrita à documentação e não implementou funcionalidades do sistema.

Não declare sucesso se algum entregável obrigatório não tiver sido criado. Explique o que impediu sua criação e o que precisa ser feito para concluir.
