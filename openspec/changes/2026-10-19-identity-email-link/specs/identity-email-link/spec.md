## ADDED Requirements

### Requirement: Cadastro de conta local
O sistema MUST permitir que uma pessoa solicite cadastro local informando nome, e-mail e credencial de usuário/senha, e MUST exigir confirmação do endereço antes de permitir login local (PROD-07; HU-12/13).

#### Scenario: Solicitação de cadastro
- **GIVEN** uma pessoa informa os dados mínimos de cadastro e uma credencial local válida
- **WHEN** envia a solicitação de cadastro
- **THEN** o sistema MUST registrar a solicitação e iniciar a confirmação do endereço de e-mail sem conceder participação no bolão

#### Scenario: E-mail ainda não confirmado
- **GIVEN** uma solicitação local cujo endereço ainda não foi confirmado
- **WHEN** a pessoa tenta autenticar-se com usuário e senha
- **THEN** o sistema MUST recusar o login e informar que a confirmação do e-mail é necessária sem revelar dados de outras contas

#### Scenario: Login após confirmação
- **GIVEN** uma conta local com credencial válida e endereço de e-mail confirmado
- **WHEN** a pessoa autenticar-se com usuário e senha
- **THEN** o sistema MUST autenticar a conta, mantendo separada a autorização para participar até aprovação administrativa

### Requirement: Confirmação de e-mail para cadastro local
O sistema MUST enviar ao endereço informado um mecanismo de confirmação de uso único, vinculado à solicitação correspondente, e MUST aceitar a confirmação somente conforme política de validade, consumo e limite de tentativas aprovada antes da implementação; essa confirmação é distinta da verificação HU-22 para vínculo Google e da recuperação HU-21.

#### Scenario: Confirmação do endereço solicitado
- **GIVEN** uma solicitação de cadastro local ainda não confirmada
- **WHEN** a pessoa apresenta um mecanismo válido emitido para essa solicitação
- **THEN** o sistema MUST confirmar somente o endereço associado à solicitação e MUST impedir a reutilização do mecanismo consumido

#### Scenario: Mecanismo expirado ou inválido
- **GIVEN** uma solicitação de cadastro local não confirmada
- **WHEN** a pessoa apresenta um mecanismo expirado, inválido ou associado a outra solicitação
- **THEN** o sistema MUST manter o endereço não confirmado e MUST NOT autenticar a conta

### Requirement: Aprovação administrativa da participação
O sistema MUST exigir aprovação de uma conta administrativa para liberar a participação dos demais usuários; confirmação de e-mail ou autenticação local não substituem essa aprovação (PROD-07/08).

#### Scenario: Conta confirmada aguardando aprovação
- **GIVEN** uma conta local com e-mail confirmado e ainda não aprovada
- **WHEN** a pessoa autentica-se
- **THEN** o sistema MAY permitir acesso restrito à própria conta, mas MUST NOT permitir palpites, ranking ou demais funções de participante

#### Scenario: Aprovação por administrador
- **GIVEN** uma solicitação de participação pendente
- **WHEN** a conta administrativa autorizada aprova a solicitação
- **THEN** o sistema MUST liberar as funções de participante e registrar a ação administrativa para auditoria

#### Scenario: Rejeição por administrador
- **GIVEN** uma solicitação de participação pendente
- **WHEN** a conta administrativa autorizada rejeita a solicitação
- **THEN** o sistema MUST manter bloqueadas as funções de participante e registrar a ação administrativa para auditoria

### Requirement: Conta administrativa inicial provisionada com controle
O sistema MUST disponibilizar uma conta administrativa inicial por setup controlado, com nome/identificador e e-mail fornecidos na configuração, sem credencial fixa de produção. No desenvolvimento local, a conta administrativa MUST permitir autenticação sem validação de e-mail usando uma senha configurada localmente fora do controle de versão; essa exceção MUST ser restrita ao ambiente local. Credenciais MUST NOT ser embutidas em imagens, logs ou configurações de produção.

#### Scenario: Provisionamento e login administrativo local
- **GIVEN** o setup de desenvolvimento local provisiona a conta administrativa inicial com identificador e e-mail configurados e a senha está definida em variável de ambiente local
- **WHEN** a pessoa administradora autentica-se usando essa senha
- **THEN** o sistema MUST permitir o acesso administrativo sem exigir validação do e-mail e MUST NOT aceitar outro mecanismo baseado em senha para essa conta local inicial

#### Scenario: Provisionamento fora do ambiente local
- **GIVEN** um setup executado em ambiente diferente do desenvolvimento local
- **WHEN** a conta administrativa inicial é provisionada
- **THEN** o sistema MUST NOT usar senha padrão embutida e MUST obter a credencial por mecanismo de configuração seguro

#### Scenario: Aprovação de participantes pela conta administrativa
- **GIVEN** uma solicitação de participação pendente
- **WHEN** a conta administrativa inicial autenticada e autorizada a revisa
- **THEN** o sistema MUST permitir aprovar ou rejeitar a solicitação e MUST auditar a decisão

### Requirement: Integração Google opcional e separada
A autenticação e o vínculo com Google são opcionais para a primeira entrega de cadastro local e MUST NOT ser pré-requisito para solicitar cadastro, confirmar e-mail, autenticar com usuário/senha ou obter aprovação administrativa. Os comportamentos HU-22/23 permanecem aplicáveis caso a integração Google seja implementada futuramente.

#### Scenario: Fluxo local sem Google
- **GIVEN** a integração Google não está habilitada
- **WHEN** uma pessoa solicita cadastro, confirma seu e-mail ou autentica-se localmente
- **THEN** o sistema MUST permitir o fluxo local sem exigir identidade Google

#### Scenario: Primeiro vínculo Google por coincidência de e-mail
- **GIVEN** uma identidade Google não vinculada e uma conta local preexistente com o mesmo e-mail
- **WHEN** houver correspondência de endereço
- **THEN** o sistema MUST NOT conceder acesso à conta preexistente somente com base na coincidência de e-mail; qualquer primeiro vínculo futuro deve respeitar HU-22/23 e decisão TEC-01 aprovada
