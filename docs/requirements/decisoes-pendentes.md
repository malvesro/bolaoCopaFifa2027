# Registro de decisões pendentes — Bolão Copa FIFA 2027

**Versão:** 1.5
**Data:** 19/10/2026
**Status:** Registro atualizado com decisões de 19/10/2026 sobre verificação inicial e após mudança de e-mail local, três tentativas por verificação e login de identidade Google já vinculada; lacunas residuais permanecem abertas.
**Fonte de requisitos:** [`requisitos-bolao-copa-mundo-feminina-2027.md`](requisitos-bolao-copa-mundo-feminina-2027.md), versão 3.4, 19/10/2026.

## 1. Objetivo e uso

Este documento registra decisões de produto, operação e arquitetura fornecidas em 18/10/2026 e 19/10/2026, além das lacunas que permanecem para preparar a implementação. Não substitui o requisito canônico. O requisito v3.2 consolidou interpretações da revisão de 18/10/2026 e preservou PROD-02/05; a v3.3 acrescentou HU-22 e a v3.4 complementou a verificação e acrescentou HU-23, sem modificar aquelas regras.

**Hierarquia:** requisitos formalmente aprovados → decisões de produto confirmadas → decisões arquiteturais aprovadas → especificações OpenSpec aprovadas dentro desses limites → recomendações deste registro → documentação técnica e boas práticas. Se uma decisão pretendida contrariar requisito aprovado, primeiro deve-se aprovar e publicar uma nova versão do requisito. A versão vigente v3.4, de 19/10/2026, preserva as decisões de domínio e visibilidade consolidadas na v3.2, complementa a HU-22 e acrescenta a HU-23; PROD-02/05 permanecem preservadas. Recomendações são propostas, não regras vigentes.

Itens decididos registram a decisão informada, a data e as lacunas residuais. Itens abertos preservam pergunta, opções, recomendação não aprovada, aprovador e impacto. A identidade do aprovador não foi informada e não é presumida; decisões fornecidas foram registradas com origem nesta solicitação. Não remover silenciosamente o histórico.

## 2. O que já está definido — não é pendência

- **Pontuação:** categorias excludentes em ordem decrescente 6/3/2/1/0, conforme seção 1.3.1 e HU-07 do requisito v3.2. “Gols de uma equipe” significa acertar exatamente uma das duas contagens, depois de avaliar placar exato; exemplos estão no requisito. Não é pendência.
- **Mata-mata:** placar ao fim dos 120 minutos, incluindo prorrogação; empate permanece empate e gols de pênaltis são ignorados (seções 1.3.2 e HU-07).
- **Corte e visibilidade:** o backend aceita requisições recebidas antes do corte vigente T−1h; gravações elegíveis podem concluir depois dele. Requisições recebidas no corte ou depois são rejeitadas. Uma mudança oficial de kickoff pode reabrir a janela; durante a reabertura, novas consultas alheias são ocultadas até o novo corte, sem reverter divulgações anteriormente observadas (requisito v3.2, seções 1.3.3, HU-02/HU-03 e HU-20).
- **Rodadas:** sete rodadas enumeradas (seção 1.3.4).
- **Pontuação e desempate:** “gols de exatamente uma equipe” significa exatamente uma contagem correta, após verificar placar exato. O ranking corrente inclui apenas resultados oficiais apurados; o terceiro desempate considera todas as rodadas anteriores concluídas, onde cada partida está apurada ou oficialmente cancelada/anulada. Nome no último critério é normalizado sem acentos/caixa; nomes normalizados iguais permanecem empatados (seções 1.3.1/1.3.5 e HU-07/HU-10, v3.2).
- **Correção de resultado:** administradores podem corrigir resultados, com recálculo automático idempotente e auditoria (seções 1.3.3 e HU-08).
- **Recuperação de senha:** e-mail com token único, expiração entre 30 e 60 minutos e resposta que não revela existência da conta (HU-21 e seção 1.5).
- **Verificação do e-mail local e vínculo Google/local:** correspondência por e-mail; endereço local novo ou alterado exige código numérico de seis dígitos enviado a ele, com até três tentativas por verificação (HU-22, v3.4). Contas anteriormente criadas e validadas com identidade Google **já vinculada** podem autenticar-se novamente via Google (HU-23), sem substituir aprovação administrativa ou recuperação de senha. Primeiro vínculo com conta preexistente não decorre só da coincidência de e-mail.
- **Escopo:** grupo único; sem dinheiro, vídeo, ligas públicas ou API paga de resultados (seção 1.5).

## 3. Decisões de produto

### PROD-01 — Concorrência na fronteira do corte

- **Decisão registrada (B):** usar timestamp de recepção confiável gerado pelo servidor. Se a requisição foi recebida antes do corte vigente, a gravação pode concluir após T−1h; requisições recebidas no instante do corte ou depois são rejeitadas. O horário do cliente nunca é evidência. Preservar o timestamp autoritativo para auditoria.
- **Requisito canônico:** v3.2, seção 1.3.3 e HU-02/HU-03 expressam essa semântica; a duração e o corte de uma hora permanecem inalterados.
- **Lacuna técnica residual:** definir ponto de ingresso confiável, proxy/load balancer confiável, precisão/monotonicidade do relógio, associação do timestamp ao pedido e sua persistência auditável sem permitir falsificação ou replay.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** implementação e testes concorrentes até o desenho técnico preservar a prova de recepção.
- **Status:** Regra de produto decidida; detalhamento técnico aberto.

### PROD-02 — Alteração do horário de partida após divulgação

- **Decisão registrada (A), preservada:** o cutoff vigente é calculado como uma hora antes do kickoff oficial vigente. Alteração oficial do kickoff pode reabrir o prazo para todos, ainda que o corte anterior tenha passado. O horário da partida e o cutoff são conceitos/dados distintos, mas a regra de produto continua vinculando o cálculo ao kickoff vigente.
- **Decisão complementar registrada nesta revisão:** na reabertura, participantes podem criar/editar palpites até o novo cutoff; novas consultas de palpites alheios ficam ocultas até esse corte. A divulgação previamente observada não pode ser revertida nem ter sua confidencialidade restaurada. Alterações administrativas registram ator, instante e valores anterior/novo; justificativa não é obrigatória.
- **Lacuna residual:** sequência de múltiplas alterações e comunicação aos participantes. Mudanças de horário para instante anterior ao atual devem respeitar o cutoff recalculado; não há exceção individual.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** tratamento técnico de alterações de calendário e testes de sincronização com gravações.
- **Status:** Regra principal e política de leitura/escrita durante reabertura decididas; comunicação e sequência operacional residual.

### PROD-03 — Partidas adiadas, canceladas, suspensas ou abandonadas

- **Decisões registradas:** (1) jogo adiado mantém palpites existentes e usa o novo kickoff, sujeito a PROD-02; (2) jogo oficialmente cancelado/anulado é excluído da pontuação; (3) uma rodada é considerada concluída para o desempate quando todas as suas partidas têm resultado oficial apurado ou cancelamento/anulação oficial.
- **Lacunas residuais:** efeitos de partidas canceladas/anuladas sobre contagens específicas do ranking (acertos exatos/3 pontos), denominadores, retenção/visibilidade e histórico; tratamento de jogo suspenso, abandonado, retomado ou com resultado parcial; efeitos sobre badges (PROD-06.6). Não atribuir pontos automaticamente a casos sem procedimento aprovado.
- **Nota:** “excluído da pontuação” não significa atribuir zero pontos. Não estender automaticamente a decisão de cancelamento a adiamento, suspensão ou abandono.
- **Aprovação registrada:** decisões fornecidas pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** apuração e ranking desses cenários excepcionais; o ciclo normal de partida permanece definível.
- **Status:** Cancelamento/anulação e adiamento decididos em escopo limitado; demais cenários abertos.

### PROD-04 — “Definitividade” e correção de resultados

- **Decisão registrada (A):** correção administrativa de resultado é sempre permitida, com nova revisão e auditoria; o ranking pode mudar após correção.
- **Já definido no requisito:** correção aciona recálculo automático idempotente e auditoria.
- **Lacuna residual:** definir quando a apuração é apresentada como encerrada/definitiva, quais administradores podem corrigir e como informar participantes. “Sempre permitida” não torna o histórico imutável nem dispensa autorização e rastreabilidade.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** estado/mensagem de encerramento e matriz de autorização; não bloqueia a capacidade de corrigir conforme autorização.
- **Status:** Correção sempre permitida decidida; apresentação e autorização residual abertas.

### PROD-05 — Solicitações para alterar palpite após o corte

- **Decisão registrada (A):** não há exceção geral para alterar palpite após o corte; pedidos de suporte são respondidos sem modificar o palpite. A única reabertura admitida decorre de alteração oficial do kickoff, conforme PROD-02 e com o novo corte calculado sobre o horário vigente.
- **Compatibilidade:** requisito v3.2 mantém o bloqueio para requisições recebidas no cutoff vigente ou depois; nova janela resultante de alteração oficial pode permitir novas submissões/edições até o novo cutoff, sem edição administrativa retroativa individual.
- **Lacuna residual:** comunicação e auditoria das alterações oficiais de calendário estão em PROD-02/OPS-06.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Status:** Regra decidida; não implementar bypass administrativo.

### PROD-06 — Critérios de badges

- **Decisão registrada:** usar [`PROD-06-criterios-badges-gamificacao.md`](PROD-06-criterios-badges-gamificacao.md) como documento de referência para a proposta de critérios.
- **Status da fonte:** em 18/10/2026 o documento estava marcado “Proposta revisada — aguardando aprovação do responsável pelo produto”; o cabeçalho foi atualizado em 19/10/2026 para refletir a aprovação registrada abaixo. A aprovação dos critérios não autoriza implementação automática.
- **Lacuna residual:** permanecem abertos o estado de resultado definitivo (PROD-06.5, ligado à PROD-04), o tratamento de partidas canceladas/anuladas (PROD-06.6, ligado à PROD-03), o efeito da reabertura de prazo (PROD-02) sobre BADGE-01/02/03, a visibilidade das badges de outros participantes e a retenção do histórico.
- **Aprovação registrada:** decisão de usar o documento como referência fornecida pelo usuário em 18/10/2026; em 19/10/2026 o solicitante declarou que a PROD-06 deve ser considerada aprovada (registro informal, sem ata). Aprovador formal não identificado.
- **Bloqueia:** apenas as partes que dependem das lacunas residuais acima (sequências e denominadores com partidas canceladas, concessão dependente de resultado definitivo e badges de cobertura sob reabertura de prazo). Aprovação do catálogo não autoriza implementação: segue OpenSpec com aprovação humana das tarefas.
- **Status:** Critérios aprovados em 19/10/2026 (ver aprovação registrada); lacunas residuais pendentes.

### PROD-07 — Admissão e ciclo de vida de participantes

- **Decisão registrada:** cadastro aberto para solicitação, sujeito à aprovação de administrador. Após aprovação, o usuário cadastrado recebe e-mail de confirmação de cadastro e de liberação para uso do sistema. Dados mínimos informados: nome e e-mail.
- **Complemento decidido em 19/10/2026:** o e-mail da conta local, inclusive quando alterado, requer verificação do novo endereço por código numérico de seis dígitos enviado a ele, com até três tentativas por verificação (HU-22). Conta validada com identidade Google já vinculada pode autenticar-se por Google (HU-23); isso não substitui aprovação administrativa nem o e-mail de liberação.
- **Lacuna residual:** se “cadastro aberto” cria conta pendente ou apenas solicitação; autenticação antes da aprovação; fluxos de rejeição, reativação, saída e tratamento do histórico; sequência entre verificação local e aprovação administrativa; conteúdo e segurança do e-mail de aprovação. Validade, reenvio e reinício de tentativas permanecem em TEC-01; o limite de três tentativas por verificação está decidido.
- **Nota de privacidade:** nome/e-mail são os únicos campos mínimos definidos aqui; não inferir outros campos obrigatórios.
- **Aprovação registrada:** gate e dados mínimos informados pelo usuário em 18/10/2026; verificação local informada pelo solicitante em 19/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** detalhes de fluxo de admissão e ciclo de conta; o gate de aprovação é definido.
- **Status:** Gate de aprovação e dados mínimos decididos; fluxo residual aberto.

### PROD-08 — Papéis e privilégios administrativos

- **Decisão registrada (A):** um papel de administrador, com privilégios mínimos necessários; não criar papéis administrativos adicionais sem decisão posterior.
- **Já definido:** participantes comuns não podem consultar palpites alheios antes do corte; a arquitetura aplica essa restrição também a administradores por padrão, sem acesso privilegiado implícito.
- **Decisão complementar solicitada em 27/10/2026:** para desenvolvimento local, disponibilizar a identidade administrativa `admin`, autenticável pela senha definida em variável de ambiente local não versionada, sem validação de e-mail. A exceção é exclusiva de `ENVIRONMENT=development`, não verifica o endereço para HU-22, não deve ser aceita em outros ambientes e não implica acesso administrativo especial a palpites alheios antes do corte. Sessão local opaca em memória via cookie `HttpOnly`; sessões expiram com logout ou reinício do backend. Esta decisão foi explicitamente confirmada pelo solicitante nesta conversa; aprovador organizacional formal não identificado.
- **Lacuna residual:** identidade/provisionamento da conta administrativa fora do ambiente local, gestão e recuperação do acesso administrativo, e matriz precisa de operações autorizadas; manter auditoria de ações administrativas.
- **Aprovação registrada:** decisão de papel único informada em 18/10/2026; exceção local confirmada pelo solicitante em 27/10/2026; aprovador organizacional não identificado.
- **Status:** Papel único e login administrativo local de desenvolvimento decididos; conta não local e privilégios operacionais detalhados permanecem abertos.

## 4. Decisões de privacidade e operação

### OPS-01 — Retenção, exclusão e anonimização

- **Decisão registrada:** não estabelecer prazo de retenção nem exclusão automática neste momento. Administrador ou próprio usuário podem excluir; o escopo declarado não especifica quais dados nem o efeito sobre histórico.
- **Lacuna residual importante:** definir se a exclusão alcança apenas a conta ou também palpites, chamados, auditoria e logs; exclusão física versus anonimização/desativação; efeitos sobre ranking e integridade histórica; autorização, confirmação e tratamento de cópias. A ausência de prazo não deve ser interpretada como autorização para retenção ilimitada nem exclusão indiscriminada.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** implementar exclusão de dados e fechar a política de retenção; não inferir deleção em cascata.
- **Status:** Ausência de prazo e possibilidade de solicitação de exclusão registradas; política e escopo abertos.

### OPS-02 — Backup, restauração e metas de recuperação

- **Decisão registrada:** o projeto não terá necessidade/compromisso de backup e recuperação. Não definir RPO/RTO nem prometer restauração.
- **Consequência:** aceitar explicitamente risco de perda dos dados; esta decisão não significa que recuperação foi testada ou garantida. Volumes persistentes locais, quando usados, preservam estado entre reinicializações normais, mas não são backup.
- **Lacuna residual:** limites exatos da decisão (incluindo backups automáticos eventualmente inerentes à plataforma, se houver destino futuro) devem ser reavaliados antes de qualquer operação fora do escopo local.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Status:** Sem backup/recuperação para o escopo decidido; risco registrado.

### OPS-03 — Provedor e operação do e-mail

- **Já definido:** recuperação por e-mail é requisito; token único, validade de 30–60 minutos e resposta que não revela existência da conta. A HU-22 (v3.4) exige também envio de código numérico de seis dígitos para verificar o e-mail local novo ou alterado, com até três tentativas por verificação; os dois fluxos têm finalidades distintas.
- **Decisão registrada (B):** usar provedor externo, sujeito a avaliação de custo, privacidade e segurança. Nenhum fornecedor específico foi nomeado.
- **Lacunas residuais:** selecionar fornecedor e região; avaliar entregabilidade e privacidade; definir credenciais, logs, monitoramento, tratamento de falhas/bounces/retries e responsável operacional.
- **Bloqueia:** fechar a operação de envio; não bloqueia a modelagem segura do token.
- **Status:** Direção decidida; fornecedor e operação ainda abertos.

### OPS-04 — Notificações além da recuperação

- **Decisão registrada (A):** notificações de produto somente na interface (UI); não adicionar canais externos de notificações. Isso não elimina e-mails exigidos para recuperação de senha, aprovação de cadastro ou verificação do e-mail local da HU-22.
- **Lacuna residual:** conteúdo e apresentação dos alertas na UI, incluindo prazo, alteração de calendário, apuração ou chamados.
- **Status:** Canais decididos; apresentação da UI pode ser detalhada na especificação.

### OPS-05 — Responsáveis, disponibilidade e custo operacional

- **Decisão registrada:** execução local em containers Docker na máquina de desenvolvimento, podendo usar ou não Dev Container no VS Code. Facilitar portabilidade ao GCP; implantar e gerenciar GCP está fora do escopo.
- **Lacunas residuais:** responsáveis, disponibilidade e custo do ambiente local; quais aspectos de portabilidade serão documentados, sem assumir operação GCP.
- **Diretriz:** manter documentação de portabilidade apenas na medida necessária; não planejar nem executar operação GCP neste projeto.
- **Status:** Ambiente-alvo local decidido; detalhes de portabilidade/responsabilidade local residuais.

### OPS-06 — Fonte e processo de atualização do calendário oficial

- **Já definido:** a tabela oficial FIFA.com é referência; a API paga de resultados está fora do escopo. Atualizações de calendário serão manuais, realizadas por administrador e auditadas; não há integração automática.
- **Lacunas residuais:** não há fixture de 2027 carregado no repositório; definir evidência/versionamento a preservar e quem verifica confrontos e horários antes da publicação.
- **Bloqueia:** publicação do calendário e chaveamento definitivos; não bloqueia a fundação técnica.
- **Status:** Processo manual e auditoria decididos; formato de evidência/validação residual aberto.

## 5. Decisões técnicas e de arquitetura

As direções abaixo foram decididas; os itens identificam somente os detalhes ainda não fixados. Recomendações arquiteturais detalhadas estão em [`../architecture/arquitetura-software.md`](../architecture/arquitetura-software.md).

### TEC-01 — Autenticação, sessão e segurança administrativa

- **Decisões registradas:** autenticação por conta Google ou identidade local (usuário/senha); vínculo entre as duas identidades **por e-mail**, exigindo que o endereço local novo ou alterado seja verificado por código numérico de seis dígitos enviado a ele, com no máximo três tentativas por verificação (HU-22, requisito v3.4). Conta anteriormente criada e validada com identidade Google já vinculada pode voltar a autenticar-se por Google (HU-23); primeiro vínculo por simples coincidência de e-mail não foi aprovado. Sessão opaca revogável mantida no servidor é direção arquitetural, não definição de cookie/expiração (ADR-001).
- **Requisitos que permanecem:** recuperação por e-mail com token único, validade de 30–60 minutos e resposta anti-enumeração aplica-se às contas locais conforme HU-21; não presumir como ela se aplica a contas exclusivamente Google. Verificação local não equivale à aprovação administrativa (PROD-07).
- **Lacunas residuais:** primeiro vínculo automático ou mediado e prova de controle de uma identidade preexistente; colisões/duplicidades, efeitos do e-mail alterado sobre contato, login e vínculos existentes, e contas pendentes/rejeitadas/bloqueadas; validação do e-mail da identidade Google; ciclo de sessão, MFA/admin e recuperação em contas Google. Definir expiração, reenvio, consumo, armazenamento seguro e proteção contra adivinhação/enumeração do código, inclusive se novo envio pode reiniciar as três tentativas (não permitir contorno silencioso do limite). Conservar `sub` do Google como identificador do provedor, sem tratar e-mail mutável como identificador permanente. Detalhes de sessão e CSRF requerem análise de ameaça.
- **Aprovação registrada:** modos exigidos informados em 18/10/2026; vínculo por e-mail, código local de seis dígitos e direção de sessão informados em 19/10/2026; na mesma data, o solicitante confirmou reverificação após mudança de endereço, três tentativas e login Google de conta validada preexistente. Aprovador organizacional não identificado.
- **Bloqueia:** implementação do primeiro vínculo, verificação e desenho final de identidade/sessão até especificar e aprovar as políticas residuais; não impede especificar o retorno por Google de identidade já vinculada, condicionado ao gate administrativo.
- **Status:** critério de vínculo, reverificação do novo e-mail, três tentativas e login Google de identidade já vinculada decididos; primeiro vínculo e controles técnicos residuais abertos.

### TEC-02 — Versões, hospedagem e topologia

- **Decisão registrada:** desenvolvimento local via Docker Compose com serviços separados para frontend, backend e banco de dados, usando volumes locais para persistência/dados de teste. Deve ser possível usar Dev Container no VS Code, sem torná-lo obrigatório. Facilitar portabilidade ao GCP; deploy e gestão GCP não fazem parte do escopo.
- **Direção arquitetural aprovada em 19/10/2026:** manter `backend/` e `frontend/` na raiz do mesmo repositório, com VSA pragmática por caso de uso dentro de módulos por capacidade e domínio proprietário sem duplicação de invariantes; SQLAlchemy síncrono como ponto de partida proporcional, sujeito a validação (ADR-001). Não se aprovou pacote/driver, URL, esquema nem migração.
- **Lacuna residual:** versões suportadas, driver compatível com sessões síncronas, desenho/nomes dos serviços e volumes, configuração local; fluxo para Windows 11/Docker Desktop/WSL 2, localização dos arquivos, permissões, hot reload, rede, inicialização, health/readiness, migrações e diagnóstico; quais mecanismos/documentação de portabilidade serão necessários. Não criar scripts de deployment sem escopo aprovado.
- **Nota:** volumes Compose não são backup; ver OPS-02.
- **Aprovação registrada:** diretriz fornecida pelo usuário em 18/10/2026; detalhes técnicos não fixados.
- **Bloqueia:** fixar versões e contratos de execução/portabilidade; a topologia local de alto nível está decidida.
- **Status:** Topologia local decidida; detalhes técnicos e de portabilidade abertos.

### TEC-03 — Processo SDD/OpenSpec

- **Decisão registrada:** adotar processo SDD leve com governança e aprovações humanas; OpenSpec é obrigatório para especificação, planejamento e evolução orientada a mudanças.
- **Contexto:** esta obrigatoriedade foi fixada no escopo da revisão arquitetural de 18/10/2026. A governança permanece manual: conclusão de artefatos não equivale à aprovação para implementar.
- **Lacuna residual:** checklist mínimo de aprovação, responsáveis autorizados, registro de aprovação e rastreabilidade entre requisitos/decisões, especificação, tarefas e validação. Também falta decidir se haverá baseline de specs curadas ou referência direta às fontes canônicas por mudança. A aprovação da direção VSA não aprova uma change de implementação nem altera o escopo da change de scaffold.
- **Configuração:** `openspec/config.yaml` mantém `schema: spec-driven`. Os comentários explicativos devem refletir a adoção obrigatória, sem alterar schema nem presumir comandos/recursos da CLI.
- **Aprovação registrada:** obrigatoriedade definida no escopo fornecido pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Status:** Adoção obrigatória decidida; governança detalhada ainda pendente. Comentários explicativos da configuração foram alinhados nesta atualização documental.

## 6. Registro de pendências consolidadas pela revisão arquitetural

Esta revisão documental de 18/10/2026 consolida no requisito v3.2 as interpretações de domínio e visibilidade confirmadas; não altera PROD-02/05. Os itens abaixo destacam somente lacunas residuais; recomendações técnicas detalhadas estão em [`../architecture/revisao-arquitetura-multiagentes.md`](../architecture/revisao-arquitetura-multiagentes.md).

- **PROD-01 / recepção confiável:** definir ponto de ingresso confiável, proxy/load balancer, precisão/monotonicidade do relógio, associação do timestamp ao pedido e persistência auditável que impeça falsificação/replay. Está decidido que publicação aguarda a conclusão de gravações elegíveis recebidas antes do corte; não está decidido como implementar essa garantia.
- **PROD-02 / alterações sucessivas:** permanece aberta a sequência operacional de múltiplas alterações de kickoff e a comunicação aos participantes. Está decidida a política de escrita/leitura durante reabertura, conforme item PROD-02; uma divulgação já observada não pode ser desfeita.
- **PROD-03 / resultados derivados:** permanecem em aberto os efeitos de partidas canceladas/anuladas sobre contagens específicas e histórico, e o tratamento de suspensas, abandonadas, retomadas ou com resultado parcial, incluindo badges. “Excluída da pontuação” não equivale a atribuir zero.
- **TEC-03 / OpenSpec:** falta decidir baseline de specs e checklist mínimo de aprovação/rastreabilidade: fonte/ID e versão → delta/cenário → tarefa → teste/evidência; registrar aprovador, data, escopo e artefatos. Planejamento completo não significa autorização de implementação.

- **TEC-01 / HU-22/23:** formato do código, reverificação do novo e-mail, limite de três tentativas por verificação e login por Google de identidade já vinculada estão decididos. Primeiro vínculo/prova de controle, contas conflitantes, efeitos da alteração de endereço, validade, reenvio/reinício do limite e segurança permanecem abertos. Não usar a HU-21 como política implícita de expiração do código.

Estas questões são complementares às lacunas detalhadas nos itens PROD-01/02/03/04/06, TEC-01/02/03 e OPS-01/03/06. Não criar decisões paralelas de produto na arquitetura.

## 7. Itens que não devem ser tratados como decisão pendente

1. Não reabrir os critérios de desempate da seção 1.3.5/HU-10: estão definidos e devem ser implementados literalmente, inclusive a regra de ranking corrente e normalização de nomes da v3.2.
2. Não converter ranking de rodada incompleta em novo critério. O ranking corrente considera apenas resultados oficialmente apurados; interface pode informar progresso sem alterar a ordenação.
3. A janela continua sendo de uma hora antes do kickoff oficial vigente. PROD-01 permite concluir após o corte somente gravações recebidas antes dele; a publicação pública aguarda essas gravações elegíveis. PROD-02 recalcula T−1h e pode reabrir a janela; durante a reabertura, leituras alheias permanecem ocultas até o novo corte, sem restaurar sigilo já perdido.
4. Não introduzir exceção administrativa individual pós-corte. A única reabertura admitida decorre de alteração oficial do kickoff, conforme PROD-02/05; requisições recebidas no cutoff vigente ou depois continuam proibidas.
5. Não tratar seleção de provedor, versão, custo, rede ou método de sessão como regra de produto: são decisões técnicas/operacionais.

## 8. Registro das decisões tomadas

| ID | Status | Decisão registrada | Origem | Aprovador | Data | Referência/observações |
|---|---|---|---|---|---|
| PROD-01 a PROD-05, PROD-07/08 | Direções decididas conforme itens; resíduos ainda indicados como abertos. | Usuário, nesta conversa. | Não identificado | 18/10/2026 | Interpretações consolidadas no requisito v3.2; PROD-02/05 preservadas. Detalhes residuais constam nos itens. |
| PROD-06 | Documento de critérios indicado como referência (18/10/2026) e considerado aprovado (19/10/2026). | Solicitante do projeto (registro informal, sem ata). | Não identificado | 19/10/2026 | Permanecem abertos PROD-06.5, PROD-06.6, a reabertura de prazo (PROD-02), a visibilidade de badges de terceiros e a retenção do histórico. |
| OPS-01 a OPS-06, TEC-01 a TEC-03 | Direções registradas conforme itens; lacunas residuais mantidas. | Usuário, nesta conversa. | Não identificado | 18/10/2026 | Não presumir aprovador organizacional nem especificações não informadas. |
| HU-22/23 / TEC-01 / PROD-07 | Vínculo Google/local por e-mail com verificação do endereço local novo ou alterado por código numérico de seis dígitos, no máximo três tentativas por verificação; login Google de identidade já vinculada à conta validada. Primeiro vínculo seguro residual aberto. | Solicitante do projeto nesta conversa. | Organizacional não identificado | 19/10/2026 | Requisito v3.4, HU-22/23; não substitui HU-21 nem aprovação administrativa; reenvio e reinício de tentativas permanecem abertos. |
| ADR-001 / TEC-02 | Direções de VSA pragmática no mesmo repositório, sessão opaca no servidor, SQLAlchemy síncrono como ponto de partida e derivados reconstruíveis; detalhes sujeitos a desenho e prova. | Solicitante do projeto aprovou recomendações apresentadas nesta conversa. | Organizacional não identificado | 19/10/2026 | [`ADR-001`](../architecture/decisoes-tecnicas/ADR-001-vsa-monorepo-e-persistencia.md); não aprova driver, migração nem implementação. |

## 9. Referências

- [`requisitos-bolao-copa-mundo-feminina-2027.md`](requisitos-bolao-copa-mundo-feminina-2027.md) — fonte canônica de requisitos, v3.4, 19/10/2026 (regras v3.2 preservadas).
- [`../architecture/arquitetura-software.md`](../architecture/arquitetura-software.md) — proposta arquitetural e detalhamento das recomendações técnicas.
- [`../architecture/revisao-arquitetura-multiagentes.md`](../architecture/revisao-arquitetura-multiagentes.md) — síntese da revisão documental e arquitetural, sem substituir decisões ou requisitos aprovados.
