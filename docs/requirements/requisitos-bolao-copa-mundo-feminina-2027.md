# Documento de Requisitos — Bolão Copa do Mundo Feminina da FIFA Brasil 2027™

**Versão:** 3.2
**Data:** 18/10/2026  
**Analista Responsável:** Analista de Requisitos Sênior / Wayfinder

**Histórico de revisão:** v3.2 (18/10/2026) esclarece a interpretação da pontuação, aplicação do ranking corrente, normalização do nome e visibilidade em reabertura conforme decisões registradas nesta revisão e em `decisoes-pendentes.md`; preserva PROD-02/05. v3.1 (18/10/2026) esclarece a semântica de recepção de requisições na fronteira do corte conforme PROD-01.
**Fonte de Referência:** Tabela oficial FIFA.com (Brasil 2027™) + Regras de negócio alinhadas com o cliente  

---

## 1. Visão Geral do Produto

### 1.1 Objetivo do Sistema

O sistema é uma **plataforma web/mobile moderna, visual e responsiva de bolão de palpites** para a Copa do Mundo Feminina da FIFA Brasil 2027™, concebida para operação em **Grupo Único** (empresa, comunidade, grupo de amigos ou organização privada). 

Permite que os participantes cadastrem palpites de placar para cada uma das 64 partidas do torneio, acompanhem pontuação em tempo real, disputem um ranking unificado com critérios matemáticos claros de desempate, visualizem os palpites dos concorrentes após o fechamento de cada jogo e interajam em uma experiência gamificada e transparente.

### 1.2 Dados Oficiais do Torneio (Base de Calendário)

| Item | Detalhe |
|---|---|
| Período | 24 de junho a 25 de julho de 2027 |
| Seleções | 32 times, 8 grupos (A–H) |
| Partidas | 64 jogos (48 na fase de grupos + 16 no mata-mata) |
| Fuso oficial do bolão | Horário de Brasília (BRT / UTC-3) |
| Sedes principais | Maracanã (abertura e final), além das demais cidades-sede oficiais no Brasil |

---

### 1.3 Regras de Negócio do Bolão

#### 1.3.1 Sistema de Pontuação

A pontuação é calculada de forma decrescente e excludente (apenas a maior pontuação atingida no jogo é atribuída):

| Pontos | Condição | Descrição |
|---|---|---|
| **6** | Acerto do placar exato | Gols de ambas as equipes exatamente iguais ao resultado oficial |
| **3** | Acerto do vencedor/empate + gols de exatamente uma equipe | Acertou quem venceu (ou empate) e exatamente uma das duas contagens de gols |
| **2** | Acerto apenas do resultado | Acertou vitória, derrota ou empate, mas errou o número exato de gols de ambas as equipes |
| **1** | Acerto apenas dos gols de exatamente uma equipe | Errou o resultado geral, mas acertou exatamente uma das duas contagens de gols |
| **0** | Demais combinações | Nenhum acerto de resultado nem de gols |

As categorias são avaliadas na ordem decrescente da tabela. Primeiro verifica-se o placar exato (6 pontos); assim, não se atribuem 3 ou 1 ponto quando ambas as contagens estão corretas. “Exatamente uma equipe” significa acertar a quantidade de gols de uma equipe e errar a da outra.

Exemplos com resultado oficial **2 x 1** (casa x visitante):

| Palpite | Resultado (vitória/empate/derrota) correto? | Contagens de gols corretas | Pontos |
|---|---:|---|---:|
| 2 x 1 | Sim | ambas | 6 |
| 2 x 0 | Sim | apenas casa | 3 |
| 3 x 1 | Sim | apenas visitante | 3 |
| 3 x 0 | Sim | nenhuma | 2 |
| 0 x 1 | Não | apenas visitante | 1 |
| 2 x 2 | Não | apenas casa | 1 |
| 0 x 0 | Não | nenhuma | 0 |

#### 1.3.2 Regra Oficial para Partidas de Mata-Mata (Eliminatórias)

- **Tempo considerado:** O resultado considerado oficial para efeito do bolão é o **placar ao final dos 120 minutos de bola rolando (90 minutos regulamentares + prorrogação)**.
- **Empate e Disputa de Pênaltis:** Caso a partida eliminatória termine empatada aos 120 minutos e a decisão vá para a disputa de pênaltis:
  - O resultado oficial apurado no bolão é **EMPATE** (pelo placar registrado aos 120 minutos, ex.: 1x1 ou 2x2).
  - Os gols convertidos na disputa de pênaltis **não são somados** ao placar da partida.
  - Participantes que palpitaram empate pontuam normalmente conforme a tabela de pontuação (placar exato 6 pts se cravaram os gols aos 120 min, ou 2 pts por acertar o empate).

#### 1.3.3 Horário da partida, prazo dos palpites e transparência

- **Horário da partida e corte:** o horário oficial de início (kickoff) e o instante de fechamento dos palpites são conceitos/dados distintos. O corte vigente é calculado como uma hora antes do kickoff oficial vigente da partida (referência BRT). Uma alteração administrativa de kickoff atualiza o horário oficial e recalcula o corte; conforme PROD-02/05, essa alteração pode reabrir a janela de palpites para todos. Não há alteração individual de palpite após o corte vigente.
- **Bloqueio concorrente:** o backend registra, no ponto confiável de entrada da requisição, um timestamp de recepção gerado pelo servidor. Criação/alteração é elegível somente quando esse timestamp for anterior ao corte vigente; no instante do corte ou depois, a API rejeita. Uma requisição recebida antes do corte pode concluir a gravação depois dele, com timestamp preservado para auditoria. O horário do cliente não é evidência. A primeira divulgação pública deve aguardar a conclusão das gravações elegíveis recebidas antes do corte.
- **Visibilidade:** antes do corte vigente, nenhum participante comum pode consultar palpites alheios; autorização e prazo são impostos pelo backend em todas as rotas e consultas. Após o corte, os palpites são divulgados. Se uma alteração oficial do kickoff reabrir a janela, novas consultas de palpites alheios ficam ocultas até o novo corte, quando a grade é divulgada novamente. Uma divulgação anteriormente observada não pode ser desfeita nem se tornar confidencial novamente; essa ocultação controla apenas novas consultas. Participantes podem criar ou editar seus próprios palpites até o novo corte vigente.
- **Auditoria do calendário:** alterações administrativas de kickoff registram ator, instante e valores anterior/novo. Justificativa textual não é obrigatória.
- **Correção de resultado:** resultados oficiais lançados pelo administrador podem ser corrigidos em caso de erro, com nova revisão, auditoria e recálculo idempotente.
- **Fuso Horário:** todas as datas e horários são exibidos de forma padronizada no horário de Brasília (BRT).

#### 1.3.4 Estrutura de Rodadas

Para efeito de histórico e desempate, o torneio é dividido em 7 rodadas oficiais:
1. **Rodada 1 (Grupos - Jogo 1):** 16 partidas
2. **Rodada 2 (Grupos - Jogo 2):** 16 partidas
3. **Rodada 3 (Grupos - Jogo 3):** 16 partidas
4. **Rodada 4 (Oitavas de Final):** 8 partidas
5. **Rodada 5 (Quartas de Final):** 4 partidas
6. **Rodada 6 (Semifinais):** 2 partidas
7. **Rodada 7 (Disputa de 3º Lugar e Final):** 2 partidas

#### 1.3.5 Critérios de Desempate do Ranking

Aplicados rigorosamente nesta ordem quando dois ou mais participantes empatam na pontuação total acumulada:
1. **Maior quantidade de acertos de placar exato (acertos de 6 pontos)**.
2. **Maior quantidade de acertos de 3 pontos** (resultado correto e contagem de gols de exatamente uma equipe correta).
3. **Maior pontuação acumulada em rodadas anteriores concluídas**. Para o ranking corrente, considera-se a soma dos pontos oficialmente apurados em todas as rodadas anteriores concluídas à rodada corrente mais recente que tenha pelo menos uma partida apurada. Uma rodada é concluída quando todas as suas partidas têm resultado oficial apurado ou estão oficialmente canceladas/anuladas. Na Rodada 1, este critério é ignorado. Partidas ainda sem resultado oficial não contribuem pontos nem acertos; não se estimam nem se atribuem zero pontos para fins deste cálculo.
4. **Ordem alfabética** pelo nome de exibição normalizado, ignorando acentos e diferenças entre maiúsculas/minúsculas. Nomes iguais após a normalização permanecem empatados; nenhum critério adicional altera a classificação.

O ranking corrente inclui somente pontos e acertos decorrentes de resultados oficiais já apurados. Uma partida pendente não recebe pontuação provisória. A cada apuração ou correção oficial, totais e ordem são recalculados; correções seguem a revisão e auditoria definidas na regra de resultados.

---

### 1.4 Público-Alvo e Modelo Operacional

- **Modelo de Operação:** Grupo Único / Instância dedicada para uma organização, grupo de colegas ou amigos.
- **Participantes:** Jogadores cadastrados que concorrem no ranking unificado da plataforma.
- **Administrador:** Responsável por cadastrar resultados oficiais, confirmar seleções classificadas nas fases de mata-mata e mediar ocorrências.

---

### 1.5 Escopo

**Incluso no escopo:**
- Cadastro de participantes, autenticação segura, troca de senha e **recuperação de senha esquecida via e-mail**.
- Tela de palpites por partida com contagem regressiva e bloqueio automático 1h antes do início (BRT).
- **Visualização pública dos palpites dos adversários** após o fechamento da janela de 1h de cada jogo.
- Motor de cálculo de pontuação automático contemplando regra de 120 minutos (com prorrogação) e empate oficial nos pênaltis.
- Ranking geral unificado com aplicação automática dos 4 critérios de desempate consolidados.
- Painel administrativo para lançamento, revisão de resultados oficiais e avanço de confrontos no mata-mata.
- Painel visual gamificado (gráficos de desempenho, badges/medalhas e indicadores de acerto).
- Canal integrado de suporte/reporte de dúvidas ao administrador com protocolo.

**Fora do escopo:**
- Movimentação financeira, apostas em dinheiro real ou custódia de valores monetários.
- Transmissão de vídeo ao vivo dos jogos.
- Multi-tenancy com criação autônoma de ligas públicas independentes (o sistema opera como grupo único).
- Integração por API paga de resultados em tempo real (alimentação oficial via painel do administrador).

---

## 2. Personas

### Persona 1 — Participante Casual
- **Nome fictício:** Marina, 34 anos
- **Perfil:** Acessa pelo smartphone, quer registrar palpites de forma ágil e ver sua colocação no ranking geral.
- **Necessidades:** Interface limpa, contagem regressiva clara e entender rapidamente por que ganhou determinada pontuação.

### Persona 2 — Participante Competitivo
- **Nome fictício:** Carlos, 41 anos
- **Perfil:** Quer conferir os palpites dos concorrentes assim que o jogo trava para torcer contra/a favor e auditar o desempate.
- **Necessidades:** Ver a grade de palpites dos adversários pós-bloqueio, detalhamento dos critérios de desempate e histórico rodada a rodada.

### Persona 3 — Administrador do Bolão
- **Nome fictício:** Rafael, 45 anos
- **Perfil:** Organiza o bolão, cadastra os resultados oficiais das partidas assim que divulgados pela FIFA e confirma confrontos do mata-mata.
- **Necessidades:** Lançamento simples e seguro, recálculo automático sem duplicidade e painel de auditoria.

### Persona 4 — Novo Participante
- **Nome fictício:** Beatriz, 29 anos
- **Perfil:** Primeira participação em bolões, necessita de onboarding simples.
- **Necessidades:** Entender a regra de 120 min, os 6/3/2/1/0 pontos e como recuperar o acesso caso esqueça a senha.

### Persona 5 — Participante Atento à Segurança
- **Nome fictício:** João, 38 anos
- **Perfil:** Preocupado com a integridade do jogo e com o sigilo do seu palpite antes da trava.
- **Necessidades:** Certeza de que ninguém vê seu palpite antes de 1h do jogo e garantia de que ninguém altera palpites pós-corte.

---

## 3. Histórias de Usuário (HU)

### Épico 1 — Cadastro e Visualização de Palpites

- **HU-01:** Como participante, quero registrar e alterar meu palpite de placar (gols time A x gols time B) para qualquer jogo aberto, para pontuar no ranking.
- **HU-02:** Como participante, quero ver o tempo restante (contagem regressiva) até o bloqueio do palpite de cada jogo em horário de Brasília (BRT), para não perder o prazo.
- **HU-03:** Como participante, quero ser impedido de editar ou cadastrar palpites após o fechamento da janela (1 hora antes do início do jogo), para garantir a integridade da competição.
- **HU-04:** Como participante, quero visualizar todos os horários de jogos convertidos fixamente para o horário de Brasília (BRT), independente do meu dispositivo.
- **HU-05:** Como novo participante, quero visualizar uma explicação visual e resumida das regras de pontuação (incluindo regra de 120 min do mata-mata) no primeiro acesso.
- **HU-20 (Nova):** Como participante, quero visualizar todos os palpites dos demais concorrentes para uma partida assim que a janela de palpites for encerrada (1h antes do jogo), para acompanhar a partida com transparência e engajamento.

### Épico 2 — Pontuação e Motor de Cálculo

- **HU-06:** Como participante, quero visualizar quantos pontos obtive em cada partida encerrada, acompanhado do motivo explícito (ex.: "Placar exato", "Resultado + gols time A", etc.).
- **HU-07:** Como sistema, quero calcular automaticamente a pontuação de todos os palpites assim que o resultado oficial for lançado pelo administrador, aplicando a regra de 120 minutos no mata-mata e a tabela 6/3/2/1/0.
- **HU-08:** Como administrador, quero lançar ou corrigir o resultado oficial de uma partida com recálculo automático e log de auditoria.

### Épico 3 — Ranking e Desempate

- **HU-09:** Como participante, quero visualizar o ranking geral unificado com a pontuação total de todos os membros do bolão atualizada em tempo real.
- **HU-10:** Como participante, quero que o sistema aplique automaticamente os 4 critérios de desempate (1º: 6 pts, 2º: 3 pts, 3º: rodadas anteriores, 4º: alfabética) em caso de igualdade de pontos.
- **HU-11:** Como participante competitivo, quero visualizar o detalhamento interativo de qual critério desfez o empate entre dois ou mais competidores.

### Épico 4 — Acesso, Segurança e Recuperação de Conta

- **HU-12:** Como participante, quero alterar minha senha voluntariamente a qualquer momento na tela "Trocar Senha".
- **HU-13:** Como participante, quero ser orientado sobre boas práticas de senha segura sem bloqueios desnecessários durante os 30 dias do campeonato.
- **HU-21 (Nova):** Como participante, quero solicitar a recuperação de senha via link seguro enviado ao meu e-mail caso esqueça minhas credenciais de acesso.

### Épico 5 — Conduta, Suporte e Transparência

- **HU-14:** Como participante, quero acessar um canal integrado para reportar dúvidas ou inconsistências com protocolo de acompanhamento.
- **HU-15:** Como participante, quero visualizar aviso claro de que resultados lançados pela administração são definitivos após encerramento da apuração.
- **HU-16:** Como administrador, quero visualizar, filtrar e responder aos chamados abertos pelos participantes.

### Épico 6 — Gamificação e Experiência Visual

- **HU-17:** Como participante, quero visualizar um gráfico de evolução da minha posição e pontuação rodada a rodada.
- **HU-18:** Como participante, quero conquistar selos/badges gamificados por desempenhos notáveis (ex.: "Mestre do Placar Exato", "Sequência Imbatível").
- **HU-19:** Como participante, quero visualizar a tabela completa de grupos e o chaveamento oficial das fases finais atualizado conforme as seleções avançam.

---

## 4. Critérios de Aceitação Detalhados

### HU-01 — Registro de Palpite
- Campos numéricos inteiros $\ge 0$ para cada seleção.
- Rejeição de valores negativos, decimais ou caracteres especiais.
- Confirmação visual imediata de salvamento com feedback em tela.
- Permitida edição enquanto a requisição for recebida antes do corte vigente, inclusive durante uma reabertura decorrente de alteração oficial do kickoff, conforme HU-02/HU-03.

### HU-02 & HU-03 — Contagem Regressiva e Bloqueio Estrito
- Contador regressivo em tempo real até o corte vigente (kickoff oficial vigente - 1 hora).
- Alerta visual diferenciado nos últimos 15 minutos antes do bloqueio.
- A API deve avaliar um timestamp de recepção confiável gerado pelo servidor: aceita gravação/edição somente quando esse timestamp for anterior ao corte vigente; no instante do corte ou depois, rejeita com código de erro amigável (`403 Forbidden` / `"Prazo encerrado"`). Uma requisição recebida antes do corte pode concluir a transação após esse instante, e o timestamp de recepção deve ser preservado para auditoria. O relógio informado pelo cliente não é evidência válida.
- A primeira divulgação após o corte aguarda a conclusão das gravações elegíveis recebidas antes do corte.
- Alterações administrativas de kickoff são registradas com ator, instante e valores anterior/novo; justificativa não é obrigatória. O novo kickoff recalcula o corte e pode reabrir a janela para todos, conforme PROD-02/05.
- Interface transmuta os campos de edição em visualização estática quando a janela vigente estiver fechada.

### HU-20 — Transparência e Grade Pública de Palpites Pós-Corte
- Após o corte vigente, uma aba ou botão "Ver Palpites da Galera" fica acessível na partida.
- Exibe lista com nome de cada participante e o placar palpitado.
- Antes do corte vigente, **nenhum participante comum** pode consultar palpites alheios; a regra é aplicada no backend em todas as rotas e consultas.
- Se mudança oficial de kickoff reabrir a janela, novas consultas de palpites alheios ficam ocultas até o novo corte, quando a grade volta a ser exibida. Isso não desfaz divulgação anteriormente observada nem restaura confidencialidade; participantes podem editar seus palpites até o novo corte.

### HU-07 — Cálculo Automático de Pontuação e Mata-Mata
- Hierarquia estrita: 6 pts $\rightarrow$ 3 pts $\rightarrow$ 2 pts $\rightarrow$ 1 pt $\rightarrow$ 0 pts. Para 3 e 1 ponto, “gols de exatamente uma equipe” significa acertar uma contagem e errar a outra, após verificar primeiro o placar exato.
- Exemplos de classificação para resultado oficial 2 x 1: palpites 2 x 0 e 3 x 1 recebem 3; 3 x 0 recebe 2; 0 x 1 e 2 x 2 recebem 1; 0 x 0 recebe 0. Placar 2 x 1 recebe 6.
- **Mata-Mata:**
  - O placar inserido pelo administrador reflete o resultado ao término dos 120 minutos.
  - Caso haja pênaltis, o resultado oficial no sistema é EMPATE (gols de pênaltis não entram no placar).
  - Exemplo: Partida 1x1 nos 90 min, 2x2 na prorrogação, decisão por pênaltis 5x4.
    - Placar oficial do bolão: **2 x 2**.
    - Quem apostou 2x2: ganha **6 pontos** (placar exato).
    - Quem apostou 1x1 ou 0x0: ganha **2 pontos** (acertou empate).
    - Quem apostou 2x1 para qualquer time: ganha **1 ponto** (acertou gols de um time).
    - Quem apostou vitória de quem venceu nos pênaltis (ex.: 3x2): ganha **0 pontos** (o jogo terminou empatado com bola rolando).

### HU-10 — Aplicação Automática de Desempate
- O ranking corrente considera somente pontuações e acertos de partidas com resultado oficial apurado. Partidas sem resultado oficial não recebem pontos provisórios nem zero pontos.
- Ordenação aplicada nesta ordem:
  1. `pontos_totais` DESC
  2. `qtd_placar_exato_6pts` DESC
  3. `qtd_acertos_3pts` DESC
  4. `pontos_acumulados_rodadas_anteriores_concluidas` DESC (ignorado na Rodada 1)
  5. `nome_normalizado` ASC (normalização Unicode sem acentos e sem diferença entre maiúsculas/minúsculas)
- Para o quarto critério, consideram-se todas as rodadas anteriores concluídas à rodada corrente mais recente que contenha ao menos uma partida apurada. Uma rodada é concluída quando todas as partidas têm resultado oficial apurado ou estão oficialmente canceladas/anuladas. Pontos de rodadas não concluídas não entram nesse critério.
- Participantes com nomes iguais após normalização permanecem empatados; não se aplica critério adicional para alterar a classificação.
- A fórmula é recalculada a cada partida apurada ou corrigida. Resultados e correções são oficiais e versionados conforme HU-08.

### HU-21 — Recuperação de Senha por E-mail
- Formulário simples solicitando o e-mail cadastrado.
- Envio de token único com expiração de 30 a 60 minutos.
- Tela segura de redefinição de senha com confirmação.
- Não expor se o e-mail existe ou não no banco por segurança contra enumeração de usuários.

---

## 5. Matriz de Regras Consolidadas

| Parâmetro | Definição Oficial Travada |
|---|---|
| **Arquitetura Social** | **Grupo Único** (plataforma fechada para uma comunidade) |
| **Pontuação Máxima por Partida** | 6 pontos |
| **Placar Válido no Mata-Mata** | **120 minutos de bola rolando (90 min + prorrogação)** |
| **Pênaltis no Mata-Mata** | Partida registrada como **Empate** (gols de pênaltis ignorados) |
| **Janela de Palpites** | Encerra **1 hora antes** de cada partida (BRT) |
| **Visibilidade de Concorrentes** | Pública na partida **após o corte de 1h** |
| **Ordem de Desempate** | 1º 6 pts $\rightarrow$ 2º 3 pts $\rightarrow$ 3º Rodadas anteriores $\rightarrow$ 4º Nome |
| **Fuso Horário** | Horário de Brasília (BRT / UTC-3) permanente |
| **Recuperação de Acesso** | E-mail com token seguro de redefinição |
