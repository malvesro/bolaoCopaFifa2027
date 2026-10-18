PROD-06 — Especificação de Badges e Gamificação
===============================================

| Campo               | Valor                                                                            |
| ------------------- | -------------------------------------------------------------------------------- |
| Projeto             | Bolão da Copa do Mundo Feminina da FIFA Brasil 2027                              |
| Identificador       | PROD-06                                                                          |
| Versão do documento | 1.0                                                                              |
| Status              | Proposta revisada — aguardando aprovação do responsável pelo produto             |
| Tipo                | Decisão de produto e especificação funcional                                     |
| Prioridade          | Média; não bloqueia pontuação ou ranking                                         |
| Dependências        | Requisitos do bolão v3.2 (18/10/2026), palpites, partidas, resultados oficiais, apuração de pontos |
| Arquivo sugerido    | `docs/requirements/PROD-06-criterios-badges-gamificacao.md`                      |

> **Importante:** este documento apresenta uma proposta completa e revisada. Os critérios e os valores numéricos somente se tornam regras aprovadas após confirmação do responsável pelo produto. A implementação automática deve permanecer bloqueada até essa aprovação.

* * *

1. Objetivo

-----------

Definir um sistema de conquistas virtuais — badges — que torne o bolão mais envolvente, divertido e memorável, incentivando a participação durante todo o torneio.

As conquistas devem reconhecer diferentes formas de participação e desempenho:

* Participação consistente.

* Precisão nos palpites.

* Capacidade de prever resultados.

* Sequências de bons resultados.

* Recuperação de desempenho.

* Desempenho em partidas eliminatórias.

* Acertos em momentos especiais do torneio.

O sistema não deve depender exclusivamente da posição no ranking. Participantes que não disputem as primeiras posições também devem encontrar objetivos interessantes.

2. Princípios de produto

------------------------

### 2.1. Diversidade de conquistas

O catálogo deve contemplar participação, precisão, consistência e momentos especiais. Nenhuma única métrica deve determinar todas as conquistas.

### 2.2. Regras transparentes

Cada badge deve ter:

* Nome e descrição.

* Condição objetiva e calculável.

* Escopo temporal.

* Regra de repetição.

* Momento de avaliação.

* Política de correção e revogação.

* Critérios de aceite testáveis.

### 2.3. Independência do ranking

Badges não concedem pontos adicionais ao ranking principal e não alteram seus critérios de desempate.

### 2.4. Imparcialidade

Não serão criadas badges negativas que exponham participantes por erros, baixa pontuação ou posição inferior.

### 2.5. Determinismo

Dado o mesmo conjunto de palpites válidos, resultados oficiais e versão das regras, o sistema deve produzir o mesmo conjunto de badges ativas.

### 2.6. Auditabilidade

Toda concessão, revogação ou reativação deve ser explicável e rastreável.

### 2.7. Recálculo seguro

Correções de resultados oficiais devem atualizar as badges afetadas sem duplicações ou inconsistências.

### 2.8. Sem recompensas financeiras

Badges são elementos virtuais de reconhecimento. Não representam dinheiro, apostas, prêmios financeiros ou vantagens no sistema de pontuação.

* * *

3. Escopo

---------

### 3.1. Incluído

* Catálogo de badges.

* Critérios de concessão.

* Avaliação automática.

* Histórico de concessões, revogações e reativações.

* Recálculo após correções de resultados.

* Exibição de badges e descrições.

* Exibição de progresso, quando aplicável.

* Testes automatizados das regras.

* Registro de versão das definições.

### 3.2. Fora do escopo inicial

* Loja de itens virtuais.

* Compra ou troca de badges.

* Pontos de experiência independentes.

* Níveis de jogador.

* Missões diárias ou notificações recorrentes complexas.

* Badges sociais concedidas por votos.

* Badges negativas.

* Integração com serviços externos de estatísticas.

* Prêmios financeiros ou recompensas materiais.

* Alteração do ranking em função das badges.

Essas funcionalidades poderão ser avaliadas futuramente, mediante decisão específica de produto.

* * *

4. Contexto do torneio e regras de referência

---------------------------------------------

O sistema deve respeitar o documento de requisitos aprovado do bolão, incluindo:

* 32 seleções.

* 8 grupos.

* 64 partidas.

* 48 partidas na fase de grupos.

* 16 partidas eliminatórias.

* Sete rodadas de referência: três rodadas de grupos, oitavas, quartas, semifinais e rodada final, composta pela disputa do terceiro lugar e pela final.

Os dados oficiais do calendário devem ser a fonte de verdade para a identificação das partidas e das rodadas.

A arquitetura não deve depender de datas ou horários fixos codificados nas regras das badges.

### 4.1. Pontuação oficial do bolão

As badges que utilizam pontos devem respeitar a regra de pontuação já definida no projeto:

| Condição do palpite                                     | Pontos |
| ------------------------------------------------------- | ------ |
| Placar exato                                            | 6      |
| Resultado geral correto e gols exatos de uma equipe     | 3      |
| Resultado geral correto e gols errados das duas equipes | 2      |
| Resultado geral incorreto e gols exatos de uma equipe   | 1      |
| Demais situações                                        | 0      |

As categorias são excludentes conforme a regra oficial.

Para esta especificação:

* **Placar exato:** pontuação de 6 pontos.

* **Resultado geral correto:** vitória da equipe vencedora ou empate corretamente previsto.

* **Palpite bem pontuado:** pontuação igual ou superior a 3 pontos.

* **Partida apurada:** partida com resultado oficial marcado como definitivo pelo fluxo administrativo aprovado.

Nos jogos eliminatórios, o placar utilizado para avaliação é o resultado ao fim dos 120 minutos, incluindo prorrogação, sem incorporar os gols da disputa de pênaltis.

* * *

5. Catálogo de badges proposto

------------------------------

O catálogo inicial contém 15 badges, organizadas em quatro famílias.

### 5.1. Família A — Participação

#### BADGE-01 — Apitou, tô dentro!

**Objetivo:** reconhecer a primeira participação válida.

**Critério de concessão:** o participante registra pelo menos um palpite válido para uma partida, antes do encerramento dessa partida.

**Escopo:** torneio.

**Repetição:** não. Uma única concessão por participante e torneio.

**Momento de avaliação:** imediatamente após a confirmação de um palpite válido.

**Dependências:** registro de palpites e validação do prazo de encerramento.

**Correção de resultado:** não afeta esta badge, pois sua condição não depende do resultado da partida.

**Exemplo:** um participante registra seu primeiro palpite válido para uma partida da primeira rodada de grupos e recebe a badge.

#### BADGE-02 — Escalação completa

**Objetivo:** incentivar a participação em todas as partidas de uma rodada.

**Critério de concessão:** o participante possui um palpite válido para cada partida pertencente à mesma rodada, registrado antes do encerramento individual de cada partida.

**Escopo:** uma ocorrência por rodada.

**Repetição:** sim, até uma ocorrência por rodada elegível.

**Momento de avaliação:** depois que todas as partidas da rodada tiverem encerrado seus respectivos prazos de palpite e o sistema puder verificar a cobertura completa.

A concessão não depende de todas as partidas terem terminado ou terem resultados definitivos. O que importa é a existência de palpites válidos para todas as partidas da rodada.

**Correção de resultado:** não afeta a concessão, desde que os palpites continuem válidos.

**Exemplo:** um participante registra palpites válidos para todas as partidas da quarta rodada antes dos respectivos encerramentos e recebe a ocorrência da badge correspondente àquela rodada.

#### BADGE-03 — Álbum completo

**Objetivo:** reconhecer a participação em todo o torneio.

**Critério de concessão:** o participante possui palpites válidos para as 64 partidas do torneio, todos registrados antes dos respectivos encerramentos.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** após o encerramento do prazo de palpite da última partida, quando a cobertura integral puder ser verificada.

**Correção de resultado:** não afeta a concessão.

**Restrição:** participantes que ingressarem após o encerramento do prazo de qualquer partida não poderão obter esta badge nesta edição, salvo se uma política aprovada permitir excepcionalmente a correção de dados de entrada. Não se deve reabrir palpites retroativamente apenas para conceder a badge.

**Exemplo:** um participante que registrou palpites válidos para todas as partidas, inclusive a final e a disputa do terceiro lugar, satisfaz o critério.

### 5.2. Família B — Precisão

#### BADGE-04 — Na mosca!

**Objetivo:** celebrar o primeiro placar exato.

**Critério de concessão:** o participante obtém pelo menos um palpite com pontuação de 6 pontos.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** após a apuração definitiva da primeira partida elegível com placar exato.

**Correção de resultado:** a badge pode ser revogada se nenhuma partida restante sustentar a condição de ter pelo menos um placar exato.

**Exemplo:** o participante acerta o placar exato de uma partida e recebe a badge após a apuração definitiva.

#### BADGE-05 — Mira calibrada

**Objetivo:** reconhecer precisão recorrente.

**Critério de concessão:** o participante obtém pelo menos três placares exatos em partidas distintas do torneio.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** quando o terceiro placar exato se tornar definitivo.

**Correção de resultado:** a badge pode ser revogada se o total de placares exatos válidos cair abaixo de três.

**Exemplo:** o participante acerta três placares exatos em diferentes rodadas e recebe a badge após a apuração do terceiro acerto.

#### BADGE-06 — Bola de cristal

**Objetivo:** reconhecer precisão excepcional.

**Critério de concessão:** o participante obtém pelo menos oito placares exatos em partidas distintas do torneio.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** quando o oitavo placar exato se tornar definitivo.

**Correção de resultado:** a badge pode ser revogada se o total de placares exatos válidos cair abaixo de oito.

**Exemplo:** um participante que alcança oito placares exatos recebe a badge, independentemente de sua posição no ranking.

**Observação:** o limite de oito é uma proposta inicial e deve ser aprovado pelo responsável pelo produto antes da implementação.

### 5.3. Família C — Consistência e desempenho

#### BADGE-07 — Leitura de jogo

**Objetivo:** reconhecer uma sequência prolongada de previsões corretas do resultado geral.

**Critério de concessão:** acertar o resultado geral de dez partidas consecutivas.

**Escopo:** torneio.

**Repetição:** não; a primeira sequência elegível concede a badge.

**Momento de avaliação:** quando a décima partida consecutiva da sequência tiver resultado definitivo.

**Correção de resultado:** recalcular a sequência. A badge pode ser revogada se a correção invalidar a única sequência que sustentava a concessão.

**Exemplo:** um participante acerta o resultado geral de dez partidas consecutivas, mesmo sem acertar todos os placares.

#### BADGE-08 — Chute certeiro

**Objetivo:** reconhecer uma rodada de alto desempenho sem favorecer apenas rodadas longas.

**Critério de concessão:** em uma rodada, obter pelo menos 3 pontos em um número de partidas igual ou superior a 60% das partidas da rodada, arredondando o limite para cima.

A fórmula é:

`limite = teto(0,60 × quantidade de partidas da rodada)`

A concessão só ocorre quando todas as partidas da rodada tiverem resultado definitivo.

**Escopo:** uma ocorrência por rodada.

**Repetição:** sim, uma vez por rodada elegível.

**Exemplos de limites:**

| Rodada                 | Partidas | Mínimo de partidas com 3 ou mais pontos |
| ---------------------- | -------- | --------------------------------------- |
| Grupos R1              | 16       | 10                                      |
| Grupos R2              | 16       | 10                                      |
| Grupos R3              | 16       | 10                                      |
| Oitavas de final       | 8        | 5                                       |
| Quartas de final       | 4        | 3                                       |
| Semifinais             | 2        | 2                                       |
| Terceiro lugar e final | 2        | 2                                       |

**Correção de resultado:** recalcular a ocorrência da rodada. A badge pode ser revogada se a condição deixar de ser verdadeira.

**Justificativa:** a regra percentual permite que a conquista seja possível em todas as rodadas, inclusive nas fases finais.

#### BADGE-09 — Pé quente

**Objetivo:** premiar uma sequência de palpites de alto desempenho.

**Critério de concessão:** obter pelo menos 3 pontos em cinco partidas consecutivas, seguindo a ordem cronológica definida nesta especificação.

**Escopo:** torneio.

**Repetição:** não; a primeira sequência elegível concede a badge.

**Momento de avaliação:** após a apuração definitiva da quinta partida consecutiva que satisfaça a condição.

**Correção de resultado:** recalcular a sequência. A badge pode ser revogada se a sequência deixar de existir.

**Exemplo:** um participante obtém 3 ou 6 pontos em cinco partidas consecutivas e recebe a badge.

#### BADGE-10 — Muralha de palpites

**Objetivo:** reconhecer consistência na previsão do resultado geral.

**Critério de concessão:** acertar o resultado geral de oito partidas consecutivas.

**Escopo:** torneio.

**Repetição:** não; a primeira sequência elegível concede a badge.

**Momento de avaliação:** após a apuração definitiva da oitava partida consecutiva.

**Correção de resultado:** recalcular a sequência. A badge pode ser revogada se nenhuma sequência válida de oito partidas permanecer.

**Relação com Leitura de jogo:** esta é uma conquista intermediária. Quem obtiver dez resultados gerais corretos consecutivos satisfaz também o critério desta badge.

#### BADGE-11 — Sangue-frio

**Objetivo:** reconhecer precisão em confrontos eliminatórios.

**Critério de concessão:** acertar o resultado geral de três partidas eliminatórias consecutivas.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** após a apuração definitiva da terceira partida consecutiva elegível.

**Regra de resultado:** utilizar o placar após 120 minutos, incluindo prorrogação, sem incorporar os gols da disputa de pênaltis.

**Correção de resultado:** recalcular a sequência. A badge pode ser revogada se a sequência deixar de ser válida.

**Exemplo:** um participante acerta o resultado geral de três partidas eliminatórias consecutivas, incluindo uma partida que terminou empatada após a prorrogação.

#### BADGE-12 — Virada de chave

**Objetivo:** reconhecer uma recuperação de desempenho.

**Critério de concessão:** em duas rodadas consecutivas elegíveis, a média de pontos por partida da rodada atual deve superar a da rodada anterior em pelo menos 1 ponto.

A fórmula é:

`média = soma dos pontos das partidas da rodada / quantidade de partidas da rodada`

As duas rodadas devem ter pelo menos quatro partidas com resultados definitivos, e todas as partidas de ambas as rodadas devem estar apuradas antes da avaliação.

A condição é:

`média_atual - média_anterior >= 1,0`

**Escopo:** torneio.

**Repetição:** não; a primeira ocorrência elegível concede a badge.

**Rodadas elegíveis:** a condição só pode ser avaliada quando houver uma rodada anterior e ambas atenderem aos requisitos de apuração. Rodadas com menos de quatro partidas não podem servir de base para esta badge.

**Correção de resultado:** recalcular ambas as médias e a condição. A badge pode ser revogada se a diferença deixar de atingir o limite.

**Exemplo:** a média de uma rodada passa de 1,5 para 2,5 pontos por partida. A condição é satisfeita se as duas rodadas atenderem aos requisitos de apuração.

**Observação:** esta regra mede a evolução relativa entre rodadas, não a posição no ranking.

### 5.4. Família D — Momentos especiais

#### BADGE-13 — Estreia certeira

**Objetivo:** celebrar um acerto na partida de abertura.

**Critério de concessão:** acertar o resultado geral da partida oficialmente designada como abertura do torneio.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** após o resultado oficial da partida de abertura se tornar definitivo.

**Correção de resultado:** a badge pode ser revogada se a correção invalidar o acerto.

**Distinção em relação a Apitou, tô dentro!:** a primeira reconhece participação; esta reconhece acerto. Elas podem ser concedidas ao mesmo participante, mas por condições diferentes.

#### BADGE-14 — Especialista no mata-mata

**Objetivo:** reconhecer bom desempenho na fase eliminatória.

**Critério de concessão:** acertar o resultado geral de pelo menos cinco partidas eliminatórias distintas.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** quando o quinto acerto elegível se tornar definitivo.

**Correção de resultado:** recalcular a quantidade de acertos. A badge pode ser revogada se o total cair abaixo de cinco.

**Regra de resultado:** utilizar o placar após 120 minutos, incluindo prorrogação, sem incorporar os gols da disputa de pênaltis.

#### BADGE-15 — Cravou a final!

**Objetivo:** reconhecer o acerto exato do placar da final.

**Critério de concessão:** obter seis pontos na partida oficialmente designada como final do torneio.

**Escopo:** torneio.

**Repetição:** não.

**Momento de avaliação:** após o resultado oficial da final se tornar definitivo.

**Correção de resultado:** a badge pode ser revogada se a correção invalidar o placar exato.

**Regra de resultado:** utilizar o placar após 120 minutos, incluindo prorrogação, sem incorporar os gols da disputa de pênaltis.

* * *

6. Regras gerais de concessão

-----------------------------

### 6.1. Fonte dos dados

As condições devem ser calculadas a partir de:

* Palpites válidos registrados no sistema.

* Resultados oficiais.

* Calendário oficial de partidas.

* Associação oficial entre partidas e rodadas.

* Pontuação calculada segundo as regras aprovadas.

* Estado de apuração de cada partida.

Nenhum cálculo deve depender de valores fornecidos pelo navegador ou de dados externos não previstos no projeto.

### 6.2. Horário de concessão

Uma badge dependente de resultado só poderá ser concedida quando os dados necessários estiverem disponíveis e a partida relevante tiver resultado oficial definitivo.

Badges de participação podem ser concedidas sem aguardar o resultado da partida.

A avaliação deve ocorrer automaticamente depois dos eventos relevantes e também ser recuperável por meio de um recálculo controlado.

### 6.3. Partidas sem resultado definitivo

Partidas adiadas, suspensas, canceladas ou ainda não apuradas não devem ser tratadas automaticamente como vitórias, derrotas ou empates.

Para cálculos que dependem de resultados, partidas sem resultado definitivo não devem ser consideradas acertos nem erros.

A regra específica para partidas anuladas ou definitivamente canceladas deve ser aprovada antes da implementação.

### 6.4. Ordenação cronológica

Para calcular sequências, utilizar a data e hora oficial de início da partida, normalizada para um instante comparável.

Se duas ou mais partidas tiverem o mesmo horário de início, utilizar um identificador estável e único da partida como desempate.

A ordenação deve ser determinística e permanecer estável durante os recálculos, salvo alteração oficial dos dados do calendário.

Uma alteração oficial de horário pode modificar sequências; nesse caso, as badges dependentes da sequência devem ser recalculadas.

### 6.5. Rodadas

As rodadas devem ser identificadas por IDs estáveis e pela associação oficial das partidas.

Não inferir a rodada a partir de nomes de partidas ou datas.

Se uma partida for transferida de rodada, recalcular as badges dependentes da cobertura ou do desempenho da rodada afetada.

### 6.6. Repetição

As badges únicas têm uma ocorrência lógica por participante e torneio.

As badges repetíveis, neste catálogo, são:

* Escalação completa.

* Chute certeiro.

Cada uma pode ter uma ocorrência por rodada elegível.

A identidade de uma concessão repetível deve incluir o participante, a definição da badge, o torneio e a rodada.

### 6.7. Progressão de conquistas

As seguintes badges formam uma progressão por quantidade de placares exatos:

1. Na mosca! — pelo menos um.

2. Mira calibrada — pelo menos três.

3. Bola de cristal — pelo menos oito.

Ao atingir um limiar superior, o participante satisfaz também os limiares inferiores.

Da mesma forma, Leitura de jogo representa um nível superior de Muralha de palpites, pois dez resultados gerais corretos consecutivos incluem uma sequência de oito.

Cada badge deve ser concedida de forma independente, de acordo com sua própria definição.

* * *

7. Correção de resultados, revogação e reativação

-------------------------------------------------

### 7.1. Regra geral

Uma correção de resultado oficial deve invalidar os cálculos derivados que dependam da partida corrigida.

A avaliação deve alcançar, conforme aplicável:

* Pontuação da partida.

* Total de placares exatos.

* Sequências de acertos.

* Desempenho da rodada.

* Médias entre rodadas.

* Acertos em partidas eliminatórias.

* Acerto da partida de abertura.

* Acerto da final.

* Badges ativas ou anteriormente concedidas que dependam desses resultados.

### 7.2. Revogação

Se a condição deixar de ser verdadeira após um recálculo válido, a badge deve deixar de estar ativa.

A revogação não apaga o histórico anterior de concessão.

### 7.3. Reativação

Se uma correção posterior tornar a condição verdadeira novamente, a badge poderá ser reativada.

A reativação deve ser registrada como novo evento de estado, sem duplicar a identidade lógica da concessão.

### 7.4. Idempotência

Executar o recálculo repetidamente sobre os mesmos dados e a mesma versão das regras não deve:

* Criar concessões duplicadas.

* Gerar revogações repetidas sem mudança real.

* Gerar reativações repetidas sem mudança real.

* Alterar o resultado final da avaliação.

* Duplicar notificações.

### 7.5. Histórico auditável

O histórico deve permitir identificar:

* Participante.

* Badge.

* Torneio.

* Rodada, quando aplicável.

* Estado anterior e novo estado.

* Data e hora do evento.

* Motivo da mudança.

* Referência ao resultado oficial ou cálculo que originou a mudança.

* Versão da definição da badge.

* Execução de recálculo que produziu a mudança.

Não é necessário armazenar uma cópia integral de todos os dados em cada evento, desde que as referências e o histórico permitam reconstruir e auditar o motivo da mudança.

* * *

8. Versionamento das regras

---------------------------

Cada definição de badge deve possuir uma versão identificável.

A versão deve ser registrada junto às avaliações ou eventos de concessão.

Alterações de critério devem ser explícitas, revisadas e aprovadas. Não se deve alterar silenciosamente a semântica de uma badge já utilizada.

Antes do início do torneio, alterações aprovadas devem ser aplicadas de forma consistente ao conjunto de participantes.

Durante o torneio, mudanças de critério devem exigir decisão formal de produto, avaliação de impacto e registro de versão.

Uma mudança de nome ou descrição que não altere a condição pode ser tratada separadamente de uma mudança de regra.

Uma alteração de condição que afete concessões já realizadas deve definir se:

* O histórico anterior será preservado sem recálculo retroativo.

* As badges serão recalculadas segundo a nova versão.

* Será criada uma nova badge, mantendo a anterior.

**Recomendação:** não alterar retroativamente critérios durante o torneio. Se uma mudança for imprescindível, exigir aprovação explícita e documentar o impacto sobre todos os participantes.

* * *

9. Progresso e apresentação na interface

----------------------------------------

Quando aplicável, a interface pode exibir o progresso em direção a uma badge.

Exemplos:

* Mira calibrada: 2 de 3 placares exatos.

* Bola de cristal: 6 de 8 placares exatos.

* Especialista no mata-mata: 4 de 5 acertos.

* Chute certeiro: 8 de 10 partidas elegíveis com pelo menos 3 pontos.

* Álbum completo: 52 de 64 palpites válidos.

O progresso deve ser calculado a partir dos dados do servidor e não deve expor palpites de outros participantes antes do encerramento permitido.

O sistema pode oferecer uma descrição curta da condição e uma explicação de como obter a badge.

Não é necessário revelar detalhes de progresso que dependam de palpites privados ou resultados ainda não divulgáveis.

As badges devem ser acessíveis, ter texto alternativo e não depender exclusivamente de cores para transmitir significado.

* * *

10. Notificações

----------------

A concessão, revogação ou reativação pode gerar uma notificação visual na interface.

A notificação deve ser idempotente e vinculada a uma mudança real de estado.

Um recálculo sem mudança no estado da badge não deve gerar uma nova notificação.

Notificações por e-mail ou outros canais ficam fora do escopo inicial, salvo decisão adicional.

A ausência de uma notificação não deve comprometer o histórico da concessão.

* * *

11. Requisitos técnicos para implementação

------------------------------------------

### 11.1. Separação de responsabilidades

A lógica de avaliação de badges deve ser separada da lógica de pontuação e do ranking.

O módulo de badges pode consumir resultados calculados e dados oficiais, mas não deve alterar a pontuação do bolão.

### 11.2. Definições e concessões

A implementação deve distinguir:

* Definição da badge.

* Versão da definição.

* Condição de elegibilidade.

* Estado atual da concessão.

* Histórico de transições de estado.

Badges repetíveis devem possuir uma chave lógica que inclua a rodada.

### 11.3. Processamento

O mecanismo de avaliação deve suportar:

* Avaliação após a apuração de partidas.

* Recálculo após correções.

* Reexecução idempotente.

* Identificação das badges afetadas.

* Recuperação após falhas.

* Concorrência entre recálculos, quando aplicável.

A estratégia de persistência e transações deve ser definida na arquitetura técnica, sem alterar as regras deste documento.

### 11.4. Autorização

A concessão e o recálculo automáticos devem ser executados exclusivamente por componentes autorizados do backend.

Usuários comuns não podem atribuir, revogar ou alterar badges por requisições diretas.

### 11.5. Observabilidade

Registrar falhas de avaliação e recálculo com informações suficientes para diagnóstico, sem expor credenciais, tokens ou dados pessoais desnecessários.

* * *

12. Critérios de aceite

-----------------------

A implementação futura deverá satisfazer, no mínimo, os critérios abaixo.

### 12.1. Participação

* O primeiro palpite válido concede Apitou, tô dentro!.

* Palpites inválidos ou registrados após o prazo não contam.

* Escalação completa exige palpites válidos para todas as partidas da rodada.

* Álbum completo exige palpites válidos para todas as 64 partidas.

### 12.2. Precisão

* Um placar exato concede Na mosca!.

* Três placares exatos concedem Mira calibrada.

* Oito placares exatos concedem Bola de cristal.

* A correção de resultados recalcula os totais e pode revogar as badges quando necessário.

### 12.3. Sequências

* Leitura de jogo exige dez resultados gerais corretos consecutivos.

* Muralha de palpites exige oito resultados gerais corretos consecutivos.

* Pé quente exige cinco partidas consecutivas com pelo menos três pontos.

* Sangue-frio exige três partidas eliminatórias consecutivas com resultado geral correto.

* A ordenação das partidas é determinística.

* Correções de resultados e mudanças oficiais de calendário recalculam sequências afetadas.

### 12.4. Desempenho por rodada

* Chute certeiro utiliza o limite percentual especificado para cada rodada.

* A rodada deve estar completamente apurada antes da concessão.

* Virada de chave compara médias de duas rodadas elegíveis.

* Rodadas com menos de quatro partidas não são usadas na comparação de Virada de chave.

### 12.5. Momentos especiais

* Estreia certeira exige acerto do resultado geral da partida de abertura.

* Especialista no mata-mata exige cinco resultados gerais corretos em partidas eliminatórias.

* Cravou a final! exige placar exato na final.

* Partidas eliminatórias usam o placar após 120 minutos, sem gols de pênaltis.

### 12.6. Auditoria e integridade

* Recálculos idempotentes não duplicam concessões.

* Revogações mantêm o histórico.

* Reativações mantêm o histórico.

* A versão da regra utilizada pode ser identificada.

* O módulo de badges não modifica pontos ou critérios do ranking.

* A avaliação é executada no backend.

* O sistema não revela palpites privados para calcular ou exibir progresso.

* * *

13. Decisões ainda necessárias

------------------------------

As perguntas abaixo devem ser respondidas pelo responsável pelo produto antes da implementação automática.

| ID         | Decisão                                          | Recomendação proposta                                                                             | Bloqueia                          |
| ---------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------- | --------------------------------- |
| PROD-06.1  | Aprovar o catálogo de 15 badges                  | Aprovar como catálogo inicial                                                                     | Módulo de badges                  |
| PROD-06.2  | Aprovar os limiares de 3 e 8 placares exatos     | Manter os valores propostos                                                                       | Badges de precisão                |
| PROD-06.3  | Aprovar os limites percentuais de Chute certeiro | 60% com arredondamento para cima                                                                  | Badge por rodada                  |
| PROD-06.4  | Aprovar a regra de Virada de chave               | Diferença mínima de 1 ponto na média, com pelo menos 4 partidas em cada rodada                    | Badge de recuperação              |
| PROD-06.5  | Definir o estado de resultado definitivo         | Usar estado oficial explícito no fluxo administrativo                                             | Concessão dependente de resultado |
| PROD-06.6  | Definir partidas canceladas ou anuladas          | Não contar automaticamente como acerto ou erro; decidir o tratamento final antes da implementação | Sequências e apuração             |
| PROD-06.7  | Definir a política de entrada tardia             | Manter Álbum completo restrita a quem pôde palpitar nas 64 partidas                               | Badge de participação integral    |
| PROD-06.8  | Aprovar revogação e reativação                   | Recalcular e preservar histórico de todas as transições                                           | Recálculo automático              |
| PROD-06.9  | Definir mudanças de critério durante o torneio   | Exigir aprovação formal e versionamento; evitar alterações retroativas                            | Gestão de regras                  |
| PROD-06.10 | Aprovar notificações                             | Notificações apenas na interface na primeira versão                                               | Notificações                      |
| PROD-06.11 | Aprovar exposição de progresso                   | Exibir progresso calculado no backend, sem revelar palpites privados                              | Interface de gamificação          |

* * *

14. Riscos e mitigação

----------------------

### 14.1. Excesso de badges

**Risco:** o catálogo pode parecer complexo ou repetitivo.

**Mitigação:** manter o catálogo inicial em 15 badges, organizar por família e apresentar descrições claras. Avaliar a distribuição de concessões após o torneio.

### 14.2. Badges muito fáceis ou muito difíceis

**Risco:** algumas conquistas podem ser obtidas por quase todos ou por ninguém.

**Mitigação:** analisar a frequência de concessões após a competição. Mudanças futuras devem ser aprovadas e aplicadas em edições posteriores, evitando ajustes silenciosos durante o torneio.

### 14.3. Inconsistência após correções

**Risco:** a pontuação pode mudar sem que a badge correspondente seja atualizada.

**Mitigação:** integrar a apuração e o recálculo com um mecanismo confiável de atualização de dados derivados, com testes de regressão e idempotência.

### 14.4. Concorrência

**Risco:** duas avaliações simultâneas podem produzir eventos duplicados.

**Mitigação:** definir uma identidade única para cada concessão lógica e garantir integridade transacional no backend.

### 14.5. Exposição de dados

**Risco:** a exibição de progresso pode revelar informações antes do encerramento dos palpites.

**Mitigação:** aplicar as mesmas regras de autorização e visibilidade utilizadas para os palpites.

### 14.6. Desmotivação

**Risco:** participantes com menos experiência podem não conquistar badges de precisão.

**Mitigação:** manter conquistas de participação e consistência, não vincular todas as badges ao ranking e evitar mensagens negativas.

* * *

15. Estratégia de testes

------------------------

A implementação deverá incluir testes automatizados para:

1. Cada critério de badge, isoladamente.

2. Os limites imediatamente abaixo, no limite e acima do limite.

3. Concessão de badges progressivas.

4. Repetição por rodada.

5. Partidas com início simultâneo.

6. Partidas sem resultado definitivo.

7. Correção de placar exato.

8. Correção que interrompa uma sequência.

9. Correção que altere uma média entre rodadas.

10. Revogação e reativação.

11. Recálculo repetido sem duplicação.

12. Alteração de calendário que mude a ordenação.

13. Jogos eliminatórios decididos nos pênaltis após empate em 120 minutos.

14. Participantes sem palpites em todas as partidas.

15. Restrições de acesso e privacidade.

Os testes devem utilizar dados sintéticos e resultados controlados, sem depender do calendário real para validar a lógica de domínio.

* * *

16. Referências de design e fundamentação

-----------------------------------------

As fontes abaixo apoiam princípios de design de gamificação, mas não determinam os critérios específicos deste catálogo. Os limiares e as regras são decisões propostas para o produto.

1. **Impact of Gamification on Motivation and Academic Performance: A Systematic Review (2024).** Revisão sistemática sobre efeitos da gamificação e importância de adaptação e criatividade no desenho das experiências.  
   [Artigo na revista Education Sciences](https://www.mdpi.com/2227-7102/14/6/639)

2. **The role of gamified learning strategies in student's motivation in high school and higher education: A systematic review (2023).** Revisão de estratégias de gamificação e efeitos sobre motivação.  
   [Artigo no PubMed Central](https://pmc.ncbi.nlm.nih.gov/articles/PMC10448467)
