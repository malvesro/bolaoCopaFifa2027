# Design

## Context

Consulte `proposal.md` para a motivação e os limites propostos. Atualmente, `CLAUDE.md`, `CONTRIBUTING.md` e `openspec/config.yaml` descrevem a obrigatoriedade do OpenSpec em termos amplos; o README documenta o fluxo SDD. O guia de configuração do Claude Code e subagents está em `docs/architecture/configuracao-claude-code.md` no commit `7838dffe8f21f2e12ce48f08a7937e73dd7aaafe` da branch `chore/consolida-fundacao-tecnica`; ele pode ser aproveitado seletivamente, sem substituir os perfis existentes em `main`.

A exceção ainda não está em vigor. A atualização dos documentos de política e a incorporação do guia são posteriores à aprovação humana desta change. `skip_specs: true` dispensa apenas o delta de capacidade de produto, inexistente neste escopo; não altera a governança nem autoriza aplicação.

## Goals / Non-Goals

**Goals:**

- Manter uma formulação coerente da exceção nas instruções do projeto, no guia de contribuição, no README e no contexto/comentários do OpenSpec.
- Documentar a configuração compartilhada e local do Claude Code sem pressupor fornecedor, modelo, disponibilidade ou autorização que não tenham sido validados.
- Tornar verificável que a configuração OpenSpec orienta pessoas e agentes, mas não classifica nem dispensa changes automaticamente.

**Non-Goals:**

- Alterar comportamento, requisitos, contratos ou arquitetura do produto.
- Automatizar a classificação de changes ou modificar comandos, skills e gates de `/opsx:apply`.
- Alterar perfis de `.claude/agents/`, configurações locais, permissões, hooks, dependências ou arquivos da skill Caveman.

## Decisions

1. **Repetir a política nos documentos de entrada, preservando a função de cada um.** `CLAUDE.md` será a instrução operacional principal; `CONTRIBUTING.md` descreverá a decisão de fluxo e o registro no PR; o README apresentará o fluxo ao público do repositório; `openspec/config.yaml` orientará a elaboração de artefatos. A redação poderá ser contextual, mas os critérios e limites devem permanecer semanticamente iguais. Alternativa considerada: centralizar a regra em um único documento e apenas vinculá-lo. Foi preterida porque os documentos são pontos de entrada independentes; links complementares podem apontar para a mesma referência sem deixar de explicitar o limite essencial.

2. **Classificar pela semântica e pelo efeito, sem automação.** Somente documentação descritiva ou harness estritamente interno ao desenvolvimento/agentes, sem efeito direto ou indireto no produto, requisitos normativos ou contratos, poderá dispensar uma change. Alterações normativas, mistas não separadas e casos de dúvida permanecem no fluxo OpenSpec. Por exemplo, uma descrição não normativa de um perfil pode ser elegível, mas alterar instruções, permissões, hooks, comandos ou skills que influenciem autorização, execução, release ou operação exige OpenSpec se houver efeito nesses âmbitos; o caminho do arquivo não decide a classificação. A dispensa não remove revisão, aprovação humana ou validação pertinente, e escopo/justificativa devem ser registrados no PR. Alternativa considerada: classificar por diretório, extensão ou tipo de arquivo; foi rejeitada porque documentação pode alterar requisitos e configurações de harness podem afetar o produto indiretamente.

3. **Manter o OpenSpec como orientação, não como mecanismo de autorização.** O contexto e as regras de `openspec/config.yaml` explicarão a exceção e seus limites, sem alegar que o CLI a aplica. O processo não alterará `/opsx:apply` nem sua skill. Essa escolha preserva o gate humano existente e evita introduzir uma automação executável fora do escopo.

4. **Aproveitar o guia de subagents somente como documentação.** Criar `docs/architecture/configuracao-claude-code.md` com distinção entre perfis versionados e preferências locais, limites de `model: inherit`, seleção de ferramenta/modelo e cautelas de custo/compatibilidade. A fonte candidata é `docs/architecture/configuracao-claude-code.md` no commit `7838dffe8f21f2e12ce48f08a7937e73dd7aaafe`; a autorização anterior para aproveitar seletivamente o material não substitui a aprovação desta change nem autoriza sua aplicação. Verificar cada afirmação contra documentação oficial/versionada citada no próprio guia; os perfis atuais mostram configuração declarada, mas não bastam para provar semântica ou permissões efetivas do runtime. Preservar os dez perfis atuais e não copiar configurações executáveis. Alternativa considerada: trazer a configuração completa da branch de referência; foi rejeitada porque incluiria alterações de perfis/configuração além da estratégia intermediária aprovada.

5. **Submeter esta change à aprovação e condicionar sua vigência à incorporação.** A validação OpenSpec não é aprovação. A change deve ser aprovada pelo responsável técnico ou de produto conforme o fluxo humano vigente; a aprovação deve ficar registrada no PR antes de editar os documentos-alvo. A política proposta só entra em vigor após merge aprovado em `main`, branch autoritativa atual; até esse marco, continua valendo a política atual. O PR deve conter a evidência da aprovação humana e o merge em `main` é o marco verificável de incorporação; não inferir aprovação ou vigência a partir de `skip_specs: true` ou da conclusão dos artefatos. Após o gate, atualizar os documentos, revisar o diff completo e validar links, consistência e preservação das exclusões.

## Risks / Trade-offs

- **Critérios para efeito indireto podem exigir julgamento contextual** → declarar explicitamente a regra conservadora: separar mudanças mistas quando viável e usar OpenSpec em caso de dúvida.
- **Redações divergentes entre documentos podem recriar ambiguidade** → revisar os quatro documentos em conjunto usando a mesma lista de critérios e limites.
- **Exemplos de configuração podem ser confundidos com configuração suportada ou recomendação oficial** → marcá-los como conceituais, sem credenciais, e limitar afirmações às observáveis no projeto.
- **Aproveitamento do guia de outra branch pode trazer afirmações obsoletas ou escopo indevido** → adaptar seletivamente e conferir links, arquivos e capacidades contra o checkout atual; preservar perfis e configurações executáveis.
- **Conclusão da change pode ser confundida com autorização ou vigência** → exigir aprovação humana registrada no PR antes da aplicação e considerar a exceção vigente apenas após merge aprovado na branch autoritativa; até lá, seguir a política atual.
- **Template atual de PR exige change aprovada mesmo em trabalho dispensado** → manter `.github/pull_request_template.md` inalterado; instruir no `CONTRIBUTING.md` a deixar desmarcada a caixa “Change OpenSpec”, registrar em “Origem” `N/A — dispensa de OpenSpec conforme [fundamento]` e descrever classificação, escopo e justificativa em “Resumo”. A aprovação humana do responsável técnico ou de produto deve continuar explícita e registrada no PR.

## Migration Plan

Não há migração de dados ou implantação de produto. Após aprovação humana desta change:

1. Criar e revisar `docs/architecture/configuracao-claude-code.md`, citando fontes verificáveis para afirmações técnicas.
2. Atualizar `CLAUDE.md` e `openspec/config.yaml` com a política e referências ao guia.
3. Atualizar `CONTRIBUTING.md` e README com o fluxo, o gate humano e referências ao guia, corrigindo afirmações amplas incompatíveis com a exceção.
4. Revisar consistência, links relativos e o diff; confirmar que perfis, configurações locais, skills e Caveman permaneceram inalterados.
5. Executar as validações documentais definidas em `tasks.md` e relatar somente os resultados realmente obtidos.

Rollback: reverter apenas as alterações documentais desta change, preservando alterações independentes que eventualmente existam no working tree. Não há mudança executável a desativar.
