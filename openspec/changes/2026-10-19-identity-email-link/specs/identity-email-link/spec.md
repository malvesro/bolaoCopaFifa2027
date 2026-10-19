## ADDED Requirements

### Requirement: Verificação de e-mail da identidade local
O sistema MUST exigir que o endereço de e-mail local novo ou alterado seja verificado mediante código numérico de seis dígitos enviado a esse endereço antes de considerá-lo elegível para vínculo por e-mail com identidade Google; MUST permitir no máximo três apresentações do código por verificação (requisito v3.4, HU-22; TEC-01).

#### Scenario: E-mail local ainda não verificado
- **GIVEN** uma identidade local cujo e-mail não foi verificado
- **WHEN** se solicita o vínculo com uma identidade Google pelo e-mail correspondente
- **THEN** o sistema MUST impedir que esse e-mail local seja considerado verificado para fins do vínculo

#### Scenario: Código enviado ao endereço local
- **GIVEN** uma solicitação de verificação de e-mail da identidade local
- **WHEN** o sistema emite o código de verificação
- **THEN** o código MUST ser numérico, conter seis dígitos e ser enviado ao endereço local a verificar

#### Scenario: Novo endereço após mudança de e-mail local
- **GIVEN** uma conta local cujo endereço anterior foi verificado
- **WHEN** o endereço de e-mail local for alterado
- **THEN** o novo endereço MUST exigir um novo código numérico de seis dígitos enviado a ele; a verificação do endereço anterior MUST NOT validar o novo para vínculo por e-mail

#### Scenario: Limite por verificação
- **GIVEN** uma verificação de e-mail local ainda não concluída
- **WHEN** o código tiver sido apresentado três vezes nessa verificação
- **THEN** uma quarta apresentação MUST NOT validar aquela verificação; reenvio, eventual novo código e reinício das tentativas dependem de política TEC-01 ainda não aprovada

### Requirement: Separação das finalidades de identidade e admissão
O sistema MUST manter a verificação do e-mail local para vínculo distinta da aprovação administrativa de participante (PROD-07) e da recuperação de senha com token único e validade de 30 a 60 minutos (requisito v3.4, HU-21/22).

#### Scenario: E-mail verificado sem aprovação administrativa
- **GIVEN** uma identidade local com e-mail verificado
- **WHEN** a solicitação de participação ainda não tiver aprovação administrativa
- **THEN** a verificação do endereço MUST NOT ser tratada como autorização de participação

#### Scenario: Recuperação de senha independente
- **GIVEN** uma identidade local com e-mail verificado
- **WHEN** uma pessoa solicitar redefinição de senha esquecida
- **THEN** o sistema MUST aplicar o fluxo próprio da HU-21 e MUST NOT tratar o código de verificação do e-mail como token de recuperação

### Requirement: Correspondência para vínculo Google/local
O sistema MUST usar a correspondência de e-mail como referência para o primeiro vínculo Google/local, preservando a identificação de uma identidade Google já vinculada por seu `sub` (requisito v3.4, HU-22/23; TEC-01). A forma de confirmar o primeiro vínculo com uma conta preexistente e tratar conflito de identidades depende de decisão registrada antes da implementação.

#### Scenario: Identidade Google já conhecida
- **GIVEN** uma identidade Google previamente reconhecida por seu `sub`
- **WHEN** seu e-mail apresentado diferir daquele usado em um acesso anterior
- **THEN** o sistema MUST NOT criar outra identidade Google apenas por causa da mudança de e-mail

#### Scenario: Correspondência sem prova de vínculo preexistente
- **GIVEN** uma identidade Google não vinculada e uma conta local preexistente com o mesmo e-mail
- **WHEN** houver correspondência de endereço
- **THEN** o sistema MUST NOT conceder acesso à conta preexistente somente com base na coincidência de texto do e-mail; a prova de controle e o fluxo para concluir o vínculo permanecem pendentes de decisão TEC-01

### Requirement: Retorno com identidade Google já vinculada
O sistema MUST permitir autenticação via Google de uma conta anteriormente criada e validada quando a identidade Google apresentada já estiver vinculada à conta e for reconhecida por seu `sub` (requisito v3.4, HU-23). A autenticação MUST NOT dispensar aprovação administrativa para participação (PROD-07).

#### Scenario: Novo login com identidade Google já vinculada
- **GIVEN** uma conta anteriormente criada e validada e uma identidade Google já vinculada a ela
- **WHEN** a pessoa autenticar-se novamente com a identidade Google reconhecida por seu `sub`
- **THEN** o sistema MUST permitir autenticação nessa conta sem exigir nova verificação do e-mail local inalterado a cada acesso, mantendo o gate de aprovação administrativa para participação

#### Scenario: Mesmo e-mail, identidade Google não vinculada
- **GIVEN** uma conta local preexistente e uma identidade Google ainda não vinculada à conta
- **WHEN** o e-mail apresentado pela identidade Google coincidir com o e-mail da conta local
- **THEN** o sistema MUST NOT tratar essa coincidência como retorno de identidade já vinculada; o primeiro vínculo exige fluxo seguro ainda pendente de decisão TEC-01
