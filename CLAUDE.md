# Instruções do projeto — Bolão Copa FIFA 2027

## Contexto e precedência

Este repositório prepara um bolão web para um grupo único da Copa do Mundo Feminina da FIFA Brasil 2027. A fonte normativa do produto é [`docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md), v3.4 (19/10/2026). Consulte os documentos especializados antes de decidir ou alterar a área correspondente; links aqui são referências, não conteúdo carregado automaticamente.

Precedência: requisitos aprovados → decisões de produto confirmadas → decisões arquiteturais formalmente aprovadas → especificações OpenSpec aprovadas dentro desses limites → solicitações pontuais compatíveis → recomendações técnicas. Solicitação pontual ou artefato OpenSpec completo não altera regra nem substitui aprovação humana. Em conflito ou lacuna, registre fontes, alternativas e impacto e peça decisão antes de implementar comportamento dependente.

## Direção e limites essenciais

- Stack e topologia local definidas: Next.js/TypeScript, FastAPI/Python e PostgreSQL em serviços separados via Docker Compose. Desenvolvimento deve suportar Windows 11 com WSL 2/Ubuntu e Linux. Versões, configuração concreta e compatibilidade ainda não estão validadas.
- Direção arquitetural: monólito modular, DDD pragmático e Clean Architecture, sem abstrações desnecessárias. [ADR-001](docs/architecture/decisoes-tecnicas/ADR-001-vsa-monorepo-e-persistencia.md) registra as direções aprovadas em 19/10/2026: VSA pragmática em módulos por capacidade com `backend/` e `frontend/` no mesmo repositório, sessão opaca no servidor e persistência síncrona inicial. Driver, esquema, detalhes de sessão, locks e implementação continuam sujeitos a design e validação. GCP é apenas possibilidade de portabilidade; implantação e operação em nuvem estão fora do escopo.
- OpenSpec é obrigatório no SDD, com governança e aprovações humanas. Relacione fonte/versão → delta → tarefas → validação; não trate conclusão dos artefatos como autorização de implementação.
- Preserve as regras aprovadas: pontuação 6/3/2/1/0; mata-mata pelo placar ao fim de 120 minutos, sem gols de pênaltis; corte uma hora antes do kickoff oficial vigente; BRT (UTC−3); ranking e desempates conforme requisito. O backend impõe prazo e autorização. Alteração oficial do kickoff pode reabrir a janela; durante a reabertura, novas leituras de palpites alheios ficam ocultas, sem restaurar confidencialidade de divulgações já observadas. Não invente política para situações pendentes.
- Vincule Google/local por correspondência de e-mail somente após verificação do endereço local novo ou alterado por código numérico de seis dígitos enviado a ele, com até três tentativas por verificação (HU-22). Identidade Google já vinculada pode autenticar novamente a conta validada por `sub` (HU-23); primeiro vínculo seguro por coincidência de e-mail, reenvio/reinício de tentativas, proteção do código e colisões ainda exigem decisão. Não confunda com aprovação administrativa ou recuperação HU-21. Proteja credenciais, sessões, tokens e dados pessoais; não exponha palpites alheios antes do corte. Operações administrativas exigem autorização e auditoria. Use privilégio mínimo, validação e consultas parametrizadas; não alegue conformidade não verificada.
- Não implemente funcionalidades, instale dependências, altere configurações executáveis ou crie recursos de nuvem sem autorização apropriada. Não opere em produção, não exponha segredos e não faça ações destrutivas sem inspeção e confirmação.

## Mapa de consulta (abrir antes de trabalhar)

| Tipo de trabalho                          | Fontes a consultar                                                                                                                                                                                                                                                                                                                                           |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Regra ou comportamento do produto         | [Requisitos v3.4](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md) e [decisões/pendências](docs/requirements/decisoes-pendentes.md); verificar aprovação e lacunas antes de propor mudança.                                                                                                                                                   |
| Arquitetura, dados, segurança ou operação | [Arquitetura](docs/architecture/arquitetura-software.md) e [revisão arquitetural](docs/architecture/revisao-arquitetura-multiagentes.md); recomendações não aprovadas não prevalecem sobre requisitos.                                                                                                                                                       |
| Badges/gamificação                        | [PROD-06](docs/requirements/PROD-06-criterios-badges-gamificacao.md); critérios considerados aprovados em 19/10/2026 (registro em decisões pendentes), mas a implementação segue OpenSpec e permanecem bloqueados resultado definitivo (PROD-06.5), partidas canceladas/anuladas (PROD-06.6) e reabertura de prazo; badges não alteram pontos nem desempate. |
| Especificação ou evolução de mudança      | [`openspec/config.yaml`](openspec/config.yaml), artifacts existentes em `openspec/` e comandos/skills OpenSpec disponíveis. Preservar governança humana; não inicializar nem mudar configuração sem solicitação.                                                                                                                                             |
| Instruções de agentes                     | Este `CLAUDE.md` é o ponto de entrada do Claude Code. Documentos em `docs/` são consultados sob demanda; comandos e skills em `.claude/` aplicam-se quando acionados. Não presuma que arquivos de outras ferramentas ou diretórios não rastreados sejam instruções canônicas.                                                                                |

## Qualidade e execução

Faça mudanças pequenas e revisáveis. Consulte documentação oficial correspondente às versões selecionadas; não invente versões, comandos, dependências ou scripts. Cubra regras de domínio, autorização, concorrência, idempotência, ranking e migrações com validação proporcional. Não há aplicação nem comandos de build/teste confirmados no repositório; não declare testes executados sem executá-los. Não crie `AGENTS.md` sem necessidade concreta de compatibilidade identificada.

## Arquitetura de IA e Delegação de Agentes

Sempre que uma tarefa complexa for solicitada neste repositório, você deve, primeiramente, verificar se as configurações de agentes em `.agents/skills/` estão criadas e disponíveis. Caso existam, você deve atuar como a interface principal e delegar a execução consultando ou invocando os subagentes especializados listados abaixo:

1. **Decisões de Design/Estrutura:** Invoque `software-architect` para desenhar diagramas e ADRs antes de codificar.
2. **Quebra de Requisitos:** Acione o `orchestrator` para dividir grandes demandas em tarefas menores.
3. **Código Backend:** Delegue para `backend-expert` tarefas que envolvam Java e Python.
4. **Código Frontend:** Delegue para `frontend-expert` tarefas que envolvam Angular e Next.js.
5. **Revisão de Código:** Submeta alterações para o `code-reviewer` e `quality-critic` antes de consolidar.
6. **Segurança:** Valide novos endpoints obrigatoriamente com o `security-analyst`.
7. **Testes:** Acione o `software-tester` para gerar cenários automatizados em Playwright.
8. **Infraestrutura/Scripts:** Use o `fast-worker` para Docker, Git e CI/CD.

Caso as configurações dos subagentes não estejam presentes na pasta indicada, assuma a execução direta da tarefa utilizando as diretrizes gerais de desenvolvimento deste projeto.
