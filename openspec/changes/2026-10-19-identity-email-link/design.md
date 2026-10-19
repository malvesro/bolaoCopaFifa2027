# Design proposto: Identidade local e Google por e-mail

## Estado e fontes

Requisito v3.4, HU-22 fixa correspondência por e-mail, reverificação do novo endereço local com código numérico de seis dígitos e no máximo três tentativas por verificação; HU-23 permite autenticação Google de identidade já vinculada à conta validada. HU-21 mantém recuperação de senha distinta e PROD-07 mantém aprovação administrativa. ADR-001 aprova direção de sessão opaca revogável, sem fixar parâmetros. Esta change ainda não tem desenho implementável completo. A minuta `docs/architecture/decisoes-tecnicas/TEC-01-PROD-07-autenticacao-admissao.md` contém mecanismos prévios conflitantes e segue não aprovada.

## Fronteiras previstas

O backend `identity` (existente somente como scaffold) deve ser dono da verificação, vínculo, identidade Google e autorização de admissão; `frontend/features/auth` e contratos HTTP serão criados depois das decisões pendentes. Tratar `sub` como identificador da identidade Google já vinculada no retorno; e-mail é atributo de correspondência sujeito a mudanças, não chave permanente de identidade. O novo endereço local exige nova verificação; não herda o status do endereço antigo. A persistência precisa garantir unicidade, concorrência de verificações/vínculos e aplicação de até três tentativas por verificação, sem definir agora tabelas, constraints ou regras de exclusão (OPS-01). O código não pode ser exposto em logs ou armazenado em claro sem análise e aprovação de desenho seguro. Reenvio e eventual reinício de tentativas exigem política que não contorne silenciosamente o limite diante do espaço de 10⁶ combinações.

## Alternativas e decisões que faltam

- **Vínculo automático só por igualdade do e-mail:** não adotado; não comprova controle de uma conta preexistente e pode associar contas indevidamente. Fluxo com confirmação de controle adicional é alternativa recomendada, mas mecanismo e estados precisam de decisão.
- **Identificar Google por e-mail:** não adotado; o `sub` é a referência estável do provedor e mudanças de endereço precisam de procedimento.
- **Reaproveitar o token de recuperação da HU-21:** rejeitado por ter finalidade e política de validade próprias; não é a verificação HU-22.
- **Sessão JWT/refresh da minuta:** substituída como direção por sessão opaca revogável no servidor (ADR-001); cookie, CSRF, duração e revogação ainda exigem análise de ameaça.

Pendências antes de implementar: validade e consumo do código, reenvio e eventual reinício das três tentativas, limite de solicitações e anti-enumeração; prova de controle para o primeiro vínculo com conta existente; colisões/duplicidades (inclusive pendente/rejeitada/bloqueada), momento e efeitos da alteração de endereço sobre contato/login/vínculos, validação das declarações do provedor Google; sequência verificação→aprovação; envio/bounce (OPS-03); migração e exclusão (OPS-01). Registrar alternativas, impacto e aprovação de cada política no TEC-01/PROD-07 e refletir nos cenários e tarefas antes de executar código.

## Validação futura

Testes de domínio/API para código de seis dígitos, reverificação após troca de endereço, terceira tentativa aceita e quarta rejeitada por verificação, uso restrito à finalidade, retorno de Google já vinculado por `sub` e bloqueio de primeiro vínculo indevido; concorrência/unicidade e consumo sob PostgreSQL real; fluxos E2E de identidade local, Google e admissão, com teste negativo para enumeração e vazamento. Não foram feitos testes de runtime nem foi escolhido driver de persistência.
