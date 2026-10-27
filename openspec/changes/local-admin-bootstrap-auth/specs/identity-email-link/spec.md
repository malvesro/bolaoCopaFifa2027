## ADDED Requirements

### Requirement: Login administrativo local de desenvolvimento
Em `ENVIRONMENT=development`, o sistema MUST permitir autenticar `admin` sem validar e-mail usando a senha de `LOCAL_ADMIN_PASSWORD`, configurada localmente fora do controle de versão; ausente ou vazia, o login MUST ser rejeitado. A sessão MUST ser opaca, mantida em memória e enviada em cookie `HttpOnly`. Fora desse ambiente, o login MUST permanecer desativado. A exceção não altera HU-22, HU-21 ou a aprovação de participantes.

#### Scenario: Login local válido
- **GIVEN** o backend está configurado com `ENVIRONMENT=development` e a identidade administrativa local foi provisionada
- **WHEN** a pessoa envia usuário `admin` e a senha configurada em `LOCAL_ADMIN_PASSWORD`
- **THEN** o sistema MUST criar uma sessão autenticada em memória e enviá-la em cookie `HttpOnly` sem exigir validação de e-mail

#### Scenario: Credencial administrativa local inválida
- **GIVEN** o backend está configurado com `ENVIRONMENT=development`
- **WHEN** a pessoa envia usuário ou senha incorretos para o login administrativo
- **THEN** o sistema MUST rejeitar a autenticação e MUST NOT criar sessão

#### Scenario: Bootstrap e login desativados fora de desenvolvimento
- **GIVEN** o backend está configurado com ambiente diferente de `development`
- **WHEN** o serviço inicia ou recebe tentativa de login com a credencial padrão local
- **THEN** o sistema MUST NOT provisionar a identidade administrativa padrão nem autenticar essa credencial

#### Scenario: Sessão ausente, logout ou reinício
- **GIVEN** não há sessão administrativa válida em memória
- **WHEN** a pessoa solicita recurso protegido, encerra sessão ou o backend reinicia
- **THEN** o sistema MUST rejeitar recurso protegido e MUST invalidar a sessão encerrada ou perdida no reinício

#### Scenario: Separação de e-mail, recuperação e admissão
- **GIVEN** a identidade administrativa local autenticou-se sem validar e-mail
- **WHEN** essa identidade é usada em fluxos de verificação HU-22, recuperação HU-21 ou admissão de participantes
- **THEN** a autenticação MUST NOT marcar e-mail como verificado nem substituir os requisitos desses fluxos
