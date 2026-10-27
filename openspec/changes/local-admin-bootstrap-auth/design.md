# Design

## Context

Consulte `proposal.md` para motivação e `specs/identity-email-link/spec.md` para o contrato. O scaffold local usa serviços separados e ainda não tem autenticação funcional. ADR-001 direciona sessão opaca mantida no servidor; detalhes de cookie/sessão seguem sujeitos a desenho. PROD-07 exige aprovação administrativa dos participantes. A conta inicial precisa de identificador e e-mail de configuração, mas seu login local de desenvolvimento não dependerá da validação do e-mail.

## Goals / Non-Goals

**Goals:**
- Separar explicitamente o ambiente local de desenvolvimento dos demais ambientes.
- Confinar o bypass de validação de e-mail à conta administrativa inicial local e à senha local definida.
- Impedir que a senha local padrão seja ativada ou aceita em produção.
- Manter a confirmação de e-mail dos cadastros de participantes e a verificação HU-22 para vínculo Google como fluxos distintos.

**Non-Goals:**
- Definir ou implementar autenticação Google, vínculo de identidades ou recuperação de senha.
- Remover validação de credenciais para outras contas locais.
- Escolher detalhes de sessão/cookie ainda não aprovados nem implementar o sistema.

## Decisions

- **Escopo delimitado ao login inicial:** esta execução implementa somente autenticação administrativa local; cadastro e aprovação de participantes, painel administrativo e auditoria de decisões não fazem parte do escopo desta change.
- **Exceção por ambiente e identidade, não bypass global:** com `ENVIRONMENT=development`, somente a identidade `admin` provisionada localmente pode usar a senha configurada em `LOCAL_ADMIN_PASSWORD`. Ambientes desconhecidos ou não locais não fazem bootstrap nem habilitam esse login. A variável ausente ou vazia não autentica; a alternativa de desativar globalmente validação de e-mail/senha foi rejeitada.
- **Sem validação de e-mail para essa conta local:** não será exigido nem enviado e-mail para autenticar `admin`; isso não marca o endereço como verificado nem altera HU-22 ou confirmação exigida de outros usuários. A credencial não deve aparecer em logs. Não há mecanismo de persistência de usuário existente no scaffold; manter a identidade inicial provisionada pelo bootstrap da aplicação e evitar criar modelo de usuário/banco fora do escopo aprovado.
- **Sessão efêmera em memória:** emitir identificador opaco aleatório associado à identidade administrativa, armazená-lo somente em memória de um único processo backend e transportá-lo em cookie `HttpOnly`. Logout remove a sessão; reinício do backend invalida todas as sessões. Não persistir sessão no banco, `localStorage` ou bundle do frontend. O Compose local deve manter um único processo/worker para esta sessão; múltiplos workers não são suportados por este desenho. Configurar atributos de cookie compatíveis com HTTP local; esta sessão local não deve ser apresentada como adequada à produção.
- **Autorização administrativa separada:** o login autentica a identidade; não implementa aprovação ou liberação de participação de terceiros.

## Risks / Trade-offs

- [Ambiente incorretamente identificado como local] → habilitar a exceção somente por configuração de execução validada no backend; ambientes desconhecidos devem falhar fechados e testes devem provar que produção rejeita o caminho.
- [Senha local configurada usada fora do desenvolvimento] → habilitar o endpoint somente em `ENVIRONMENT=development`; manter o arquivo local fora do controle de versão e verificar imagens e logs sem expor o segredo.
- [E-mail configurado confundido com e-mail verificado] → persistir/representar separadamente configuração de endereço e estado de verificação; não reutilizar a exceção para HU-22 nem para os cadastros de participantes.
- [Escopo da conta inicial conflitar com decisões PROD-07/08] → atualizar as decisões canônicas e obter aprovação humana antes de implementação; este design não substitui essa aprovação.

## Migration Plan

1. Registrar a regra local e os limites de produção nas decisões PROD-07/08 e aprovar a mudança de produto.
2. Desenhar o provisionamento local e os controles de configuração, credencial e sessão em implementação posterior aprovada.
3. Validar testes negativos para ambientes não locais e para contas que não sejam a administrativa inicial.

Rollback: desabilitar o provisionamento/login inicial local e exigir o fluxo administrativo alternativo aprovado; nunca introduzir a senha padrão em ambientes não locais como mecanismo de rollback.

## Open Questions

- A mudança é uma proposta de produto: confirmar formalmente a exceção local e o tratamento da conta inicial nas fontes canônicas antes de implementar.
- O login local comum e confirmação de e-mail dos participantes são parte da change prévia de cadastro/admissão, não deste escopo específico de bootstrap administrativo.
