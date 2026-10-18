# Registro de decisões pendentes — Bolão Copa FIFA 2027

**Versão:** 1.1  
**Data:** 18/10/2026  
**Status:** Registro atualizado com decisões fornecidas em 18/10/2026; itens explicitamente marcados como residuais continuam abertos.  
**Fonte de requisitos:** [`requisitos-bolao-copa-mundo-feminina-2027.md`](requisitos-bolao-copa-mundo-feminina-2027.md), versão 3.1, 18/10/2026.

## 1. Objetivo e uso

Este documento registra decisões de produto, operação e arquitetura fornecidas em 18/10/2026, além das lacunas que permanecem para preparar a implementação. Não substitui o requisito canônico. A revisão v3.1 do requisito incorporou a semântica de concorrência do corte (PROD-01); as demais decisões aqui registradas complementam o requisito sem alterá-lo, salvo futura revisão formal.

**Hierarquia:** requisitos formalmente aprovados → decisões de produto confirmadas → decisões arquiteturais aprovadas → recomendações deste registro → documentação técnica e boas práticas. Se uma decisão pretendida contrariar requisito aprovado, primeiro deve-se aprovar e publicar uma nova versão do requisito. A revisão v3.1 publicada em 18/10/2026 formalizou a alteração associada a PROD-01. Recomendações são propostas, não regras vigentes.

Itens decididos registram a decisão informada, a data e as lacunas residuais. Itens abertos preservam pergunta, opções, recomendação não aprovada, aprovador e impacto. A identidade do aprovador não foi informada e não é presumida; decisões fornecidas foram registradas com origem nesta solicitação. Não remover silenciosamente o histórico.

## 2. O que já está definido — não é pendência

- **Pontuação:** categorias excludentes em ordem decrescente 6/3/2/1/0, conforme seção 1.3.1 e HU-07 do requisito. O exemplo de mata-mata na seção 4 confirma alguns casos. A arquitetura aplica “gols de uma equipe” como acerto de exatamente um dos dois placares quando a categoria de 6 pontos já foi excluída; isso mantém a tabela excludente. Não se solicita decisão sobre a regra.
- **Mata-mata:** placar ao fim dos 120 minutos, incluindo prorrogação; empate permanece empate e gols de pênaltis são ignorados (seções 1.3.2 e HU-07).
- **Corte e visibilidade:** o backend aceita somente requisições recebidas antes de T−1h, conforme timestamp confiável de recepção; uma requisição elegível pode concluir depois do corte. Requisições recebidas no corte ou depois são rejeitadas. Palpites tornam-se visíveis após o corte e não são acessíveis a participantes comuns antes (seções 1.3.3, HU-02/HU-03 e HU-20 do requisito v3.1).
- **Rodadas:** sete rodadas enumeradas (seção 1.3.4).
- **Desempate:** ordem rigorosa definida na seção 1.3.5 e detalhada na HU-10: pontos totais; quantidade de placares exatos; quantidade de acertos de 3 pontos; pontos de rodadas anteriores a partir da Rodada 2 (ignorado na R1); nome de exibição em ordem alfabética sem distinção de caixa. A fórmula recalcula a cada partida apurada (HU-10). Não é pendência de produto.
- **Correção de resultado:** administradores podem corrigir resultados, com recálculo automático idempotente e auditoria (seções 1.3.3 e HU-08).
- **Recuperação de senha:** e-mail com token único, expiração entre 30 e 60 minutos e resposta que não revela existência da conta (HU-21 e seção 1.5).
- **Escopo:** grupo único; sem dinheiro, vídeo, ligas públicas ou API paga de resultados (seção 1.5).

## 3. Decisões de produto

### PROD-01 — Concorrência na fronteira do corte

- **Decisão registrada (B):** usar timestamp de recepção confiável gerado pelo servidor. Se a requisição foi recebida antes do corte vigente, a gravação pode concluir após T−1h; requisições recebidas no instante do corte ou depois são rejeitadas. O horário do cliente nunca é evidência. Preservar o timestamp autoritativo para auditoria.
- **Requisito canônico:** v3.1, seção 1.3.3 e HU-02/HU-03 agora expressam essa semântica; a duração e o corte de uma hora permanecem inalterados.
- **Lacuna técnica residual:** definir ponto de ingresso confiável, proxy/load balancer confiável, precisão/monotonicidade do relógio, associação do timestamp ao pedido e sua persistência auditável sem permitir falsificação ou replay.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** implementação e testes concorrentes até o desenho técnico preservar a prova de recepção.
- **Status:** Regra de produto decidida; detalhamento técnico aberto.

### PROD-02 — Alteração do horário de partida após divulgação

- **Decisão registrada (A):** o corte é sempre recalculado como uma hora antes do kickoff oficial vigente. Uma alteração pode, portanto, reabrir o prazo de palpites conforme o novo horário, ainda que o prazo anterior tenha encerrado.
- **Lacuna residual:** definir o tratamento de alteração para horário anterior, atualização recebida depois do novo corte, sequência de múltiplas alterações, invalidação/revisão da visibilidade já publicada e comunicação aos participantes. A decisão de reabrir decorre do horário oficial vigente; não é exceção administrativa individual.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** tratamento técnico de alterações de calendário e testes de sincronização com gravações.
- **Status:** Regra principal decidida; casos operacionais residuais abertos.

### PROD-03 — Partidas adiadas, canceladas, suspensas ou abandonadas

- **Decisões registradas:** (1) jogo adiado mantém palpites existentes e usa o novo kickoff, sujeito a PROD-02; (2) jogo oficialmente cancelado/anulado é excluído da pontuação.
- **Lacunas residuais:** como representar jogo excluído em ranking e desempates (omitir do denominador/contagens, não atribuir pontos); retenção/visibilidade dos palpites e histórico; tratamento de jogo suspenso, abandonado, retomado ou com resultado parcial; como cancelamento afeta badges da proposta PROD-06.
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
- **Compatibilidade:** requisito v3.1 mantém o bloqueio para requisições recebidas no corte/depois; apenas nova janela resultante de horário oficial alterado pode voltar a permitir submissões, sem edição administrativa retroativa individual.
- **Lacuna residual:** comunicação e auditoria das alterações oficiais de calendário estão em PROD-02/OPS-06.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Status:** Regra decidida; não implementar bypass administrativo.

### PROD-06 — Critérios de badges

- **Decisão registrada:** usar [`PROD-06-criterios-badges-gamificacao.md`](PROD-06-criterios-badges-gamificacao.md) como documento de referência para a proposta de critérios.
- **Status da fonte:** o documento está marcado “Proposta revisada — aguardando aprovação do responsável pelo produto” e diz que critérios/valores só se tornam regras após confirmação. A escolha de fonte não equivale à aprovação do catálogo nem autoriza implementação automática.
- **Lacuna residual:** aprovação explícita do catálogo, limites, critérios, partidas canceladas, estado de resultado definitivo e demais decisões enumeradas na seção 13 daquele documento.
- **Aprovação registrada:** decisão de usar o documento como referência fornecida pelo usuário em 18/10/2026; aprovação dos critérios ainda não registrada.
- **Bloqueia:** concessão automática de badges até aprovação formal.
- **Status:** Fonte definida; critérios funcionais aguardam aprovação do responsável pelo produto.

### PROD-07 — Admissão e ciclo de vida de participantes

- **Decisão registrada:** cadastro aberto para solicitação, sujeito à aprovação de administrador. Após aprovação, o usuário cadastrado recebe e-mail de confirmação de cadastro e de liberação para uso do sistema. Dados mínimos informados: nome e e-mail.
- **Lacuna residual:** se “cadastro aberto” cria conta pendente ou apenas solicitação; autenticação antes da aprovação; fluxos de rejeição, reativação, saída e tratamento do histórico; confirmação/verificação do endereço; conteúdo e segurança do e-mail de aprovação.
- **Nota de privacidade:** nome/e-mail são os únicos campos mínimos definidos aqui; não inferir outros campos obrigatórios.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Bloqueia:** detalhes de fluxo de admissão e ciclo de conta; o gate de aprovação é definido.
- **Status:** Gate de aprovação e dados mínimos decididos; fluxo residual aberto.

### PROD-08 — Papéis e privilégios administrativos

- **Decisão registrada (A):** um papel de administrador, com privilégios mínimos necessários; não criar papéis administrativos adicionais sem decisão posterior.
- **Já definido:** participantes comuns não podem consultar palpites alheios antes do corte; a arquitetura aplica essa restrição também a administradores por padrão, sem acesso privilegiado implícito.
- **Lacuna residual:** conta(s) que receberão o papel, gestão e recuperação do acesso administrativo, e matriz precisa de operações autorizadas; manter auditoria de ações administrativas.
- **Aprovação registrada:** decisão fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Status:** Modelo de papel único decidido; detalhes de autorização residual abertos.

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

- **Já definido:** recuperação por e-mail é requisito; token único, validade de 30–60 minutos e resposta que não revela existência da conta.
- **Decisão registrada (B):** usar provedor externo, sujeito a avaliação de custo, privacidade e segurança. Nenhum fornecedor específico foi nomeado.
- **Lacunas residuais:** selecionar fornecedor e região; avaliar entregabilidade e privacidade; definir credenciais, logs, monitoramento, tratamento de falhas/bounces/retries e responsável operacional.
- **Bloqueia:** fechar a operação de envio; não bloqueia a modelagem segura do token.
- **Status:** Direção decidida; fornecedor e operação ainda abertos.

### OPS-04 — Notificações além da recuperação

- **Decisão registrada (A):** notificações de produto somente na interface (UI); não adicionar canais externos de notificações. Isso não elimina e-mails exigidos para recuperação de senha ou aprovação de cadastro.
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

- **Decisão registrada:** o sistema deve permitir autenticação por conta Google ou por identidade local (usuário/senha). A solicitação apresenta os dois modos como necessários, sem escolher provedor, prioridade ou se uma conta pode usar ambos.
- **Requisitos que permanecem:** recuperação por e-mail com token único, validade de 30–60 minutos e resposta anti-enumeração aplica-se às contas locais conforme o requisito v3.1; não presumir como ela se aplica a contas Google.
- **Lacuna residual:** coexistência/associação de contas, login padrão, ciclo de sessão, MFA/admin e compatibilidade da recuperação exigida com contas Google.
- **Aprovação registrada:** diretriz fornecida pelo usuário em 18/10/2026; escolha detalhada não registrada.
- **Bloqueia:** desenho final de identidade/sessão e recuperação para cada tipo de conta.
- **Status:** Modos exigidos indicados; desenho e políticas residuais abertos.

### TEC-02 — Versões, hospedagem e topologia

- **Decisão registrada:** desenvolvimento local via Docker Compose com serviços separados para frontend, backend e banco de dados, usando volumes locais para persistência/dados de teste. Deve ser possível usar Dev Container no VS Code, sem torná-lo obrigatório. Facilitar portabilidade ao GCP; deploy e gestão GCP não fazem parte do escopo.
- **Lacuna residual:** versões suportadas, desenho/nomes dos serviços e volumes, configuração local; quais mecanismos/scripts de portabilidade serão necessários. Não criar scripts de deployment sem escopo aprovado.
- **Nota:** volumes Compose não são backup; ver OPS-02.
- **Aprovação registrada:** diretriz fornecida pelo usuário em 18/10/2026; detalhes técnicos não fixados.
- **Bloqueia:** fixar versões e contratos de execução/portabilidade; a topologia local de alto nível está decidida.
- **Status:** Topologia local decidida; detalhes técnicos e de portabilidade abertos.

### TEC-03 — Processo SDD/OpenSpec

- **Decisão registrada (B):** adotar processo SDD leve, com governança manual; OpenSpec é a ferramenta sugerida para organizar os artefatos, mas não é obrigatório.
- **Contexto:** o repositório mantém a configuração `spec-driven` do OpenSpec como ponto de partida; isso não torna a ferramenta obrigatória nem substitui a governança manual.
- **Lacuna residual:** checklist mínimo, responsáveis por aprovação e forma de manter histórico manual.
- **Aprovação registrada:** diretriz fornecida pelo usuário em 18/10/2026; aprovador organizacional não identificado.
- **Status:** Direção decidida; procedimento leve a documentar.

## 6. Itens que não devem ser tratados como decisão pendente

1. Não reabrir os critérios de desempate da seção 1.3.5/HU-10: estão definidos e devem ser implementados literalmente.
2. Não converter ranking de rodada incompleta em novo critério. Pontuações e critérios usam resultados apurados; interface pode informar progresso sem alterar ordenação.
3. A janela continua sendo de uma hora e a visibilidade segue o requisito v3.1; PROD-01 admite conclusão após o corte somente para requisição recebida antes, conforme timestamp confiável. PROD-02 recalcula T−1h a partir do kickoff oficial vigente.
4. Não introduzir exceção administrativa individual pós-corte. A única reabertura admitida é a janela recalculada por alteração oficial do kickoff, conforme PROD-02; requests recebidos no corte/depois continuam proibidos.
5. Não tratar seleção de provedor, versão, custo, rede ou método de sessão como regra de produto: são decisões técnicas/operacionais.

## 7. Registro das decisões tomadas

| ID | Status | Decisão registrada | Origem | Aprovador | Data | Referência/observações |
|---|---|---|---|---|---|
| PROD-01 a PROD-05, PROD-07/08 | Direções decididas conforme itens; resíduos ainda indicados como abertos. | Usuário, nesta conversa. | Não identificado | 18/10/2026 | PROD-01 incorporado no requisito v3.1; demais detalhes e resíduos permanecem descritos nos itens. |
| PROD-06 | Documento de critérios indicado como referência, sem aprovação dos critérios. | Usuário, nesta conversa. | Não identificado | 18/10/2026 | A fonte continua “Proposta revisada — aguardando aprovação”. |
| OPS-01 a OPS-06, TEC-01 a TEC-03 | Direções registradas conforme itens; lacunas residuais mantidas. | Usuário, nesta conversa. | Não identificado | 18/10/2026 | Não presumir aprovador organizacional nem especificações não informadas. |

## 8. Referências

- [`requisitos-bolao-copa-mundo-feminina-2027.md`](requisitos-bolao-copa-mundo-feminina-2027.md) — documento de requisitos aprovado, v3.1, 18/10/2026.
- [`../architecture/arquitetura-software.md`](../architecture/arquitetura-software.md) — proposta arquitetural e detalhamento das recomendações técnicas.
- [`../architecture/PROMPT-ARQUITETURA-CLAUDE-CODE.md`](../architecture/PROMPT-ARQUITETURA-CLAUDE-CODE.md) — escopo da análise arquitetural inicial.
