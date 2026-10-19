# Checklists: Graft + Claude Code

## 1. Setup inicial (uma vez por projeto)
- [ ] WSL/Ubuntu atualizado e projeto clonado em `~/` (não em `/mnt/c`)
- [ ] `node -v` retorna 20 ou superior
- [ ] `bash tools/graft-starter/setup-graft.sh --dry-run` executado e revisado
- [ ] `bash tools/graft-starter/setup-graft.sh` executado sem erros
- [ ] Pastas `graft/` e `.claude/` existem
- [ ] `git status` revisado; decisão sobre o que versionar registrada no `CLAUDE.md`
- [ ] `CLAUDE.md` criado a partir de `CLAUDE.md.exemplo` e ajustado
- [ ] Nova sessão do Claude Code aberta na raiz e Graft visível (statusline)

## 2. Setup de cada pessoa do time
- [ ] Repositório clonado e Node 20+ instalado
- [ ] Graft instalado (`npm install -g @nanonets/graft`) ou uso via `npx`
- [ ] `graft build` executado para gerar o grafo local
- [ ] Nova sessão do Claude Code aberta na raiz do projeto

## 3. Antes de começar uma tarefa
- [ ] Branch atualizada e grafo atualizado (`graft build`, se necessário)
- [ ] `graft map` ou `graft ask "..."` para entender a área afetada
- [ ] Pedido ao Claude Code descreve objetivo, arquivos prováveis e critério de pronto

## 4. Antes de alterar uma função ou classe
- [ ] `graft callers <símbolo>` executado e impacto compreendido
- [ ] Testes existentes localizados
- [ ] Mudanças de grande impacto combinadas com o time

## 5. Antes de abrir o PR
- [ ] Testes e lint passando
- [ ] Diff revisado por você antes de pedir revisão (não confie cegamente no agente)
- [ ] Nenhum segredo ou arquivo gerado indevido no commit
- [ ] Alterações em `graft/` e `.claude/` coerentes com a política do time
- [ ] Descrição do PR explica o que mudou e como foi testado

## 6. Revisão de PR (revisor)
- [ ] Impacto verificado com `graft callers` nos símbolos alterados
- [ ] Mudanças em `.claude/settings.json` revisadas com atenção (hooks executam comandos)
- [ ] Convenções do `CLAUDE.md` respeitadas

## 7. Quando algo der errado
- [ ] Claude Code não usa o Graft: fechar e abrir nova sessão na raiz
- [ ] Grafo desatualizado: `graft build`
- [ ] `command not found`: abrir novo terminal ou usar `npx @nanonets/graft`
- [ ] Erro `^M` no script: converter fim de linha com `sed -i 's/\r$//' arquivo.sh`
- [ ] Reverter: desfazer com Git as mudanças em `.claude/` e remover `graft/`
