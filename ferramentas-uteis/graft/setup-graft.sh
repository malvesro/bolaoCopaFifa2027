#!/usr/bin/env bash
# setup-graft.sh: configura o Graft para Claude Code no projeto atual (WSL/Ubuntu).
# Uso: bash tools/graft-starter/setup-graft.sh [--dry-run] [--help]
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      cat <<'EOF'
Uso: bash setup-graft.sh [--dry-run]
  --dry-run  Mostra o que o "graft init" faria, sem alterar arquivos.
Execute na raiz do repositório (dentro de um projeto Git).
EOF
      exit 0 ;;
    *) echo "Opção desconhecida: $arg" >&2; exit 2 ;;
  esac
done

log()  { printf '[setup-graft] %s\n' "$*"; }
fail() { printf '[setup-graft] ERRO: %s\n' "$*" >&2; exit 1; }

command -v git  >/dev/null 2>&1 || fail "Git não encontrado."
command -v node >/dev/null 2>&1 || fail "Node.js não encontrado. Instale o Node 20+ (ex.: nvm install 20)."
command -v npm  >/dev/null 2>&1 || fail "npm não encontrado."

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 20 ] || fail "Node $(node -v) detectado; é necessário Node 20 ou superior."

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || fail "Execute dentro de um repositório Git."
cd "$ROOT"
log "Projeto: $ROOT"

case "$ROOT" in
  /mnt/*) log "AVISO: projeto em /mnt (disco do Windows). Para melhor desempenho, use ~/ no WSL." ;;
esac

if command -v graft >/dev/null 2>&1; then
  log "Graft já instalado: $(graft --version 2>/dev/null || echo 'versão desconhecida')"
else
  log "Instalando @nanonets/graft globalmente..."
  npm install -g @nanonets/graft || fail "Falha na instalação global. Use nvm ou rode: npx @nanonets/graft init"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  log "Modo simulação: nenhuma alteração será feita."
  graft init --agents claude --no-global --dry-run || fail "Simulação falhou. Rode 'graft init --help' e ajuste."
  log "Simulação concluída. Rode novamente sem --dry-run para aplicar."
  exit 0
fi

log "Executando graft init para o Claude Code..."
if ! graft init --agents claude --no-global; then
  log "Opções não aceitas por esta versão; tentando 'graft init' interativo."
  graft init || fail "Falha no graft init."
fi

[ -d graft ]   && log "OK: pasta graft/ criada."   || log "AVISO: pasta graft/ não encontrada."
[ -d .claude ] && log "OK: pasta .claude/ presente." || log "AVISO: pasta .claude/ não encontrada."

log "Concluído. Abra uma NOVA sessão do Claude Code na raiz do projeto."
log "Confira 'git status' e siga o CHECKLISTS.md."
