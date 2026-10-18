# Proposal

## Why

A documentação principal contém referências e instruções de épocas diferentes, redundâncias entre a arquitetura e os requisitos canônicos, e um prompt histórico longo que pode ser confundido com orientação vigente. Reorganizar e validar os documentos agora reduzirá contexto enganoso para agentes sem alterar regras de produto ou decisões aprovadas.

## What Changes

- Enxugar o `CLAUDE.md` e torná-lo um ponto de entrada operacional com links explícitos por tipo de tarefa, precedência e distinção entre instrução carregada automaticamente e material consultado sob demanda.
- Atualizar referências e status do prompt arquitetural legado, da revisão multiagentes e da arquitetura, removendo afirmações obsoletas e redundâncias sem promover recomendações técnicas a decisões.
- Corrigir links e referências inválidos ou pouco acessíveis, incluindo os exemplos técnicos/documentais identificados na auditoria.
- Criar `docs/architecture/plano-reestruturacao-documentacao.md` com diagnóstico, justificativas e registro conciso do plano executado e das validações.
- Avaliar explicitamente a remoção de documentos legados que geram contexto enganoso. Remover o `docs/architecture/PROMPT-ARQUITETURA-CLAUDE-CODE.md` somente após migrar sua proveniência útil para documentação vigente, corrigir suas referências e confirmar que não contém regra ou decisão única; preservar sua recuperação no histórico Git. Não excluir scaffolds de ferramentas não rastreados nem outras fontes sem rastrear dependências e justificar a preservação do conteúdo.
- Validar links relativos, caminhos citados, consistência de status/precedência, invariantes aprovadas e referências OpenSpec. Não inicializar nem alterar configuração/schema OpenSpec.

## Capabilities

### New Capabilities

Nenhuma.

### Modified Capabilities

Nenhuma. Esta mudança é exclusivamente documental; não altera comportamento especificado do sistema. O change opta por `skip_specs: true`.

## Impact

- Documentos: `CLAUDE.md`, `docs/architecture/arquitetura-software.md`, `docs/architecture/revisao-arquitetura-multiagentes.md`, referências aplicáveis em `docs/requirements/decisoes-pendentes.md` e `docs/requirements/PROD-06-criterios-badges-gamificacao.md`, prompt arquitetural legado e novo plano de reestruturação.
- OpenSpec: apenas artefatos de planejamento desta mudança; configuração e specs-base permanecem inalteradas.
- Código, APIs, dependências e comportamento executável: sem impacto.