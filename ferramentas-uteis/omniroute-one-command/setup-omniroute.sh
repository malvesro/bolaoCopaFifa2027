#!/usr/bin/env bash
# Instala/migra o OmniRoute para Docker Compose no Ubuntu/WSL2.
# Execute com: bash setup-omniroute.sh
# O script preserva o volume, cria backup antes de migrar container existente,
# corrige permissões, sobe o serviço e verifica a inicialização.
set -Eeuo pipefail

readonly CONTAINER_NAME="omniroute"
readonly DEFAULT_IMAGE="diegosouzapw/omniroute:latest"
readonly DEFAULT_VOLUME="omniroute-data"
readonly INSTALL_DIR="${OMNIROUTE_INSTALL_DIR:-$HOME/omniroute-docker}"
readonly BACKUP_ROOT="${OMNIROUTE_BACKUP_DIR:-$HOME/omniroute-backups}"
readonly URL="http://localhost:20128"

STEP=0
OLD_CONTAINER_STOPPED=0
ROLLBACK_CONTAINER=""
SUCCESS=0
BACKUP_DIR=""
OLD_CONTAINER_WAS_RUNNING=0
PROJECT_NAME="omniroute-managed"

ok()   { printf '\033[32m[OK]\033[0m %s\n' "$*"; }
info() { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[AVISO]\033[0m %s\n' "$*"; }
fail() { printf '\033[31m[ERRO]\033[0m %s\n' "$*" >&2; exit 1; }
step() { STEP=$((STEP + 1)); printf '\n\033[1m[ETAPA %s]\033[0m %s\n' "$STEP" "$*"; }

rollback_on_failure() {
  local rc=$?
  trap - EXIT
  if (( rc != 0 )); then
    printf '\n\033[31m[ERRO]\033[0m A instalação/migração falhou na etapa %s.\n' "$STEP" >&2
    if [[ -n "$ROLLBACK_CONTAINER" ]] && docker inspect "$ROLLBACK_CONTAINER" >/dev/null 2>&1; then
      warn "Tentando restaurar o container anterior '$ROLLBACK_CONTAINER'..."
      if docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
        docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
      fi
      if docker rename "$ROLLBACK_CONTAINER" "$CONTAINER_NAME" >/dev/null 2>&1; then
        if (( OLD_CONTAINER_WAS_RUNNING == 1 )); then
          if docker start "$CONTAINER_NAME" >/dev/null 2>&1; then
            ok "Container anterior restaurado e iniciado. O volume não foi removido."
          else
            warn "Container antigo renomeado para '$CONTAINER_NAME', mas não iniciou. Consulte: docker logs $CONTAINER_NAME"
          fi
        else
          ok "Container anterior restaurado como '$CONTAINER_NAME' e mantido parado, como estava originalmente."
        fi
      else
        warn "Não foi possível renomear automaticamente. O container anterior continua disponível como '$ROLLBACK_CONTAINER'."
      fi
    elif (( OLD_CONTAINER_STOPPED == 1 )) && docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
      warn "Tentando iniciar novamente o container anterior..."
      docker start "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    if [[ -n "$BACKUP_DIR" ]]; then
      printf 'Backup (se criado): %s\n' "$BACKUP_DIR"
    fi
  fi
  exit "$rc"
}
trap rollback_on_failure EXIT

step "Verificando Docker Engine e Docker Compose"
command -v docker >/dev/null 2>&1 || fail "Docker CLI não encontrado. Execute este script no Ubuntu/WSL2 com Docker instalado."
docker info >/dev/null 2>&1 || fail "Docker Engine não está acessível. Verifique: systemctl status docker"
docker compose version >/dev/null 2>&1 || fail "Docker Compose v2 não está disponível. Verifique: docker compose version"
ok "Docker Engine acessível e Docker Compose v2 disponível."

mkdir -p "$INSTALL_DIR"
chmod 700 "$INSTALL_DIR"

EXISTING=0
ENVIRONMENT_JSON=""
IMAGE_REF="${OMNIROUTE_IMAGE:-$DEFAULT_IMAGE}"
VOLUME_NAME="${OMNIROUTE_VOLUME:-$DEFAULT_VOLUME}"

step "Verificando se já existe um container OmniRoute"
if docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  EXISTING=1
  info "Container existente detectado; preparando uma migração com backup e rollback."

  IMAGE_REF="$(docker inspect --format '{{.Config.Image}}' "$CONTAINER_NAME")"
  [[ -n "$IMAGE_REF" ]] || fail "Não foi possível identificar a imagem atual. Nenhuma alteração foi feita."
  docker image inspect "$IMAGE_REF" >/dev/null 2>&1 || fail "A imagem local '$IMAGE_REF' não foi encontrada. Para evitar uma atualização involuntária, a migração foi interrompida."

  # A tag (por exemplo, :latest) pode ter mudado desde que o container foi criado.
  # Se ela já não aponta para a imagem exata em execução, usa o digest imutável
  # da imagem original; sem digest disponível, interrompe em vez de atualizar às cegas.
  existing_image_id="$(docker inspect --format '{{.Image}}' "$CONTAINER_NAME")"
  tagged_image_id="$(docker image inspect --format '{{.Id}}' "$IMAGE_REF")"
  if [[ "$existing_image_id" != "$tagged_image_id" ]]; then
    immutable_ref="$(docker image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$existing_image_id" | grep -m1 '@sha256:' || true)"
    [[ -n "$immutable_ref" ]] || fail "A tag '$IMAGE_REF' não aponta para a imagem original e não há digest disponível. Nenhuma alteração foi feita para evitar uma atualização de versão."
    IMAGE_REF="$immutable_ref"
    docker image inspect "$IMAGE_REF" >/dev/null 2>&1 || fail "A referência imutável '$IMAGE_REF' não está disponível localmente. Nenhuma alteração foi feita."
    warn "A tag original mudou; a migração usará o digest exato da imagem do container existente: $IMAGE_REF"
  fi

  configured_user="$(docker inspect --format '{{.Config.User}}' "$CONTAINER_NAME")"
  [[ "$configured_user" == "node" ]] || fail "O container existente usa o usuário '$configured_user', não 'node'. Nenhuma alteração foi feita; a configuração precisa ser revisada manualmente."

  env_lines="$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$CONTAINER_NAME")"
  grep -Fxq 'DATA_DIR=/data' <<< "$env_lines" || fail "O container não declara DATA_DIR=/data. Nenhuma alteração foi feita para evitar usar o diretório de dados errado."

  mount_count="$(docker inspect --format '{{len .Mounts}}' "$CONTAINER_NAME")"
  [[ "$mount_count" == "1" ]] || fail "O container tem $mount_count montagens; o script espera somente o volume /data. Nenhuma alteração foi feita para não perder outras montagens."
  mount_info="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Type}}|{{.Name}}{{end}}{{end}}' "$CONTAINER_NAME")"
  [[ "$mount_info" == volume\|* ]] || fail "Não foi encontrado um volume Docker nomeado em /data. Nenhuma alteração foi feita."
  VOLUME_NAME="${mount_info#volume|}"
  [[ "$VOLUME_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || fail "O nome do volume existente não é compatível com a validação segura do script."

  port_binding="$(docker port "$CONTAINER_NAME" 20128/tcp 2>/dev/null || true)"
  grep -Fxq '127.0.0.1:20128' <<< "$port_binding" || fail "A porta 20128 não está publicada exatamente em 127.0.0.1:20128. Nenhuma alteração foi feita para não mudar silenciosamente a exposição de rede."

  container_entrypoint="$(docker inspect --format '{{json .Config.Entrypoint}}' "$CONTAINER_NAME")"
  image_entrypoint="$(docker image inspect --format '{{json .Config.Entrypoint}}' "$IMAGE_REF")"
  container_cmd="$(docker inspect --format '{{json .Config.Cmd}}' "$CONTAINER_NAME")"
  image_cmd="$(docker image inspect --format '{{json .Config.Cmd}}' "$IMAGE_REF")"
  [[ "$container_entrypoint" == "$image_entrypoint" && "$container_cmd" == "$image_cmd" ]] || fail "O container tem entrypoint/command personalizado. O script interrompeu sem alterar nada para não perder essa configuração."

  # Preserva todas as variáveis efetivas atuais do container. Escapamos '$' como
  # '$$' para o Compose não interpretar valores com cifrão como interpolação.
  ENVIRONMENT_JSON="$(docker inspect --format '{{json .Config.Env}}' "$CONTAINER_NAME" | sed 's/\$/$$/g')"
  [[ -n "$ENVIRONMENT_JSON" && "$ENVIRONMENT_JSON" != "null" ]] || fail "Não foi possível preservar as variáveis de ambiente existentes."

  # Confirma que a imagem contém shell e tar antes de parar a aplicação.
  if ! docker run --rm --user 0:0 --mount "type=volume,src=$VOLUME_NAME,dst=/data,readonly" \
       --entrypoint /bin/sh "$IMAGE_REF" -lc 'command -v tar >/dev/null 2>&1' >/dev/null 2>&1; then
    fail "A imagem atual não oferece /bin/sh e tar para criar um backup consistente do volume. Nenhuma alteração foi feita."
  fi
  existing_project_preflight="$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project"}}' "$CONTAINER_NAME" 2>/dev/null || true)"
  existing_workdir_preflight="$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$CONTAINER_NAME" 2>/dev/null || true)"
  # Evita que Compose confunda o container antigo renomeado com um serviço do
  # mesmo projeto. O caso já gerenciado na pasta esperada sai pelo caminho idempotente abaixo.
  if [[ "$existing_project_preflight" == "$PROJECT_NAME" && "$existing_workdir_preflight" != "$INSTALL_DIR" ]]; then
    PROJECT_NAME="omniroute-migrate-$$"
  fi
  ok "Imagem, usuário, DATA_DIR, volume, porta e comandos conferidos; volume '$VOLUME_NAME' será preservado."
else
  info "Nenhum container '$CONTAINER_NAME' encontrado; será criada uma instalação nova ou reutilizado o volume existente '$VOLUME_NAME'."
  [[ "$VOLUME_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || fail "Nome do volume inválido: '$VOLUME_NAME'."
  if ! docker image inspect "$IMAGE_REF" >/dev/null 2>&1; then
    info "Baixando a imagem $IMAGE_REF..."
    docker pull "$IMAGE_REF" || fail "Não foi possível baixar a imagem '$IMAGE_REF'."
  fi
  ok "Imagem disponível: $IMAGE_REF"
fi

# Se esta instalação já é gerenciada por este próprio script no diretório esperado,
# não recriamos o container a cada execução. Apenas validamos e, se necessário,
# corrigimos a permissão do volume de forma explícita.
if (( EXISTING == 1 )); then
  existing_project="$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project"}}' "$CONTAINER_NAME" 2>/dev/null || true)"
  existing_workdir="$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$CONTAINER_NAME" 2>/dev/null || true)"
  if [[ "$existing_project" == "omniroute-managed" && "$existing_workdir" == "$INSTALL_DIR" && -f "$INSTALL_DIR/compose.yaml" && -f "$INSTALL_DIR/.env" ]]; then
    step "Verificando uma instalação já gerenciada por este script"
    if ! docker exec --user node "$CONTAINER_NAME" sh -lc 'test -w /data && f="/data/.omniroute-write-test-$$" && touch "$f" && rm -f "$f"' >/dev/null 2>&1; then
      warn "A permissão de escrita precisa ser corrigida; aplicando a propriedade correta ao volume existente."
      docker exec --user 0:0 "$CONTAINER_NAME" sh -lc 'set -eu; chown -R 1000:1000 /data; chmod 750 /data; stat -c "Permissoes=%A | UID:GID=%u:%g | Diretorio=%n" /data'
      docker exec --user node "$CONTAINER_NAME" sh -lc 'set -eu; test -w /data; f="/data/.omniroute-write-test-$$"; touch "$f"; rm -f "$f"'
    fi
    current_restart="$(docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' "$CONTAINER_NAME")"
    if [[ "$current_restart" != "unless-stopped" ]]; then
      docker update --restart unless-stopped "$CONTAINER_NAME" >/dev/null
      ok "Política de reinicialização ajustada para unless-stopped."
    fi
    current_state="$(docker inspect --format '{{.State.Status}}' "$CONTAINER_NAME")"
    [[ "$current_state" == "running" ]] || fail "A instalação Compose já existe, mas o container não está em execução (estado=$current_state). Consulte docker logs $CONTAINER_NAME."
    ok "Instalação já gerenciada; container e volume validados sem recriação desnecessária."
    printf 'URL: %s\nCompose: %s/compose.yaml\n' "$URL" "$INSTALL_DIR"
    SUCCESS=1
    exit 0
  fi
fi

step "Gerando configuração Docker Compose comentada"
# `.env` contém somente o nome da imagem e do volume. As variáveis do container
# existente (que podem conter dados sensíveis) ficam no compose.yaml, protegido
# com permissão 600 e dentro de uma pasta privada do usuário.
printf 'OMNIROUTE_IMAGE=%s\nOMNIROUTE_VOLUME=%s\n' "$IMAGE_REF" "$VOLUME_NAME" > "$INSTALL_DIR/.env"
chmod 600 "$INSTALL_DIR/.env"

if (( EXISTING == 1 )); then
  cat > "$INSTALL_DIR/compose.yaml" <<EOF
# Gerado por setup-omniroute.sh. Mantém a configuração de ambiente já existente.
services:
  permissions-init:
    image: \${OMNIROUTE_IMAGE}
    pull_policy: never
    user: "0:0"
    entrypoint: ["/bin/sh", "-lc"]
    command: |
      set -eu
      echo "[1/3] Corrigindo proprietário de /data para UID:GID 1000:1000..."
      chown -R 1000:1000 /data
      echo "[OK] Proprietário corrigido."
      echo "[2/3] Definindo permissões 750 no diretório /data..."
      chmod 750 /data
      echo "[OK] Permissões aplicadas."
      echo "[3/3] Conferindo resultado..."
      stat -c 'Permissoes=%A | UID:GID=%u:%g | Diretorio=%n' /data
      test -w /data
      echo "[OK] Preparação do volume concluída."
    volumes:
      - omniroute-data:/data
    restart: "no"

  omniroute:
    image: \${OMNIROUTE_IMAGE}
    pull_policy: never
    container_name: omniroute
    user: "node"
    restart: unless-stopped
    stop_grace_period: 40s
    environment: ${ENVIRONMENT_JSON}
    ports:
      - "127.0.0.1:20128:20128"
    volumes:
      - omniroute-data:/data
    depends_on:
      permissions-init:
        condition: service_completed_successfully

volumes:
  omniroute-data:
    name: \${OMNIROUTE_VOLUME}
EOF
else
  cat > "$INSTALL_DIR/compose.yaml" <<'EOF'
# Gerado por setup-omniroute.sh para instalação nova do OmniRoute.
services:
  permissions-init:
    image: ${OMNIROUTE_IMAGE}
    pull_policy: never
    user: "0:0"
    entrypoint: ["/bin/sh", "-lc"]
    command: |
      set -eu
      echo "[1/3] Corrigindo proprietário de /data para UID:GID 1000:1000..."
      chown -R 1000:1000 /data
      echo "[OK] Proprietário corrigido."
      echo "[2/3] Definindo permissões 750 no diretório /data..."
      chmod 750 /data
      echo "[OK] Permissões aplicadas."
      echo "[3/3] Conferindo resultado..."
      stat -c 'Permissoes=%A | UID:GID=%u:%g | Diretorio=%n' /data
      test -w /data
      echo "[OK] Preparação do volume concluída."
    volumes:
      - omniroute-data:/data
    restart: "no"

  omniroute:
    image: ${OMNIROUTE_IMAGE}
    pull_policy: never
    container_name: omniroute
    user: "node"
    restart: unless-stopped
    stop_grace_period: 40s
    environment:
      DATA_DIR: /data
    ports:
      - "127.0.0.1:20128:20128"
    volumes:
      - omniroute-data:/data
    depends_on:
      permissions-init:
        condition: service_completed_successfully

volumes:
  omniroute-data:
    name: ${OMNIROUTE_VOLUME}
EOF
fi
chmod 600 "$INSTALL_DIR/compose.yaml"

compose() {
  docker compose --project-directory "$INSTALL_DIR" --env-file "$INSTALL_DIR/.env" \
    -p "$PROJECT_NAME" -f "$INSTALL_DIR/compose.yaml" "$@"
}
compose config -q || fail "Docker Compose recusou a configuração gerada. O container existente ainda não foi removido."
ok "compose.yaml gerado e validado em $INSTALL_DIR."

step "Criando backup e preparando migração (se houver container anterior)"
if (( EXISTING == 1 )); then
  mkdir -p "$BACKUP_ROOT"
  chmod 700 "$BACKUP_ROOT"
  BACKUP_DIR="$BACKUP_ROOT/omniroute-$(date +%Y%m%d-%H%M%S)-$$"
  mkdir -p "$BACKUP_DIR"
  chmod 700 "$BACKUP_DIR"

  was_running="$(docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME")"
  if [[ "$was_running" == "true" ]]; then
    OLD_CONTAINER_WAS_RUNNING=1
    info "Parando o OmniRoute graciosamente (até 40 segundos) antes do backup..."
    docker stop --timeout 40 "$CONTAINER_NAME" >/dev/null || fail "Não foi possível parar o container com segurança."
    OLD_CONTAINER_STOPPED=1
  fi

  # Copia o banco SQLite para facilitar recuperação, além do arquivo compactado
  # de todo /data para preservar arquivos auxiliares existentes.
  if ! docker cp "$CONTAINER_NAME:/data/storage.sqlite" "$BACKUP_DIR/storage.sqlite" >/dev/null 2>&1; then
    fail "Não foi possível copiar /data/storage.sqlite. O container não será removido; veja o estado e os logs."
  fi
  [[ -s "$BACKUP_DIR/storage.sqlite" ]] || fail "O banco de backup está vazio. Migração cancelada por segurança."
  if ! docker run --rm --user 0:0 --mount "type=volume,src=$VOLUME_NAME,dst=/data,readonly" \
       --entrypoint /bin/sh "$IMAGE_REF" -lc 'tar -czf - -C /data .' > "$BACKUP_DIR/data-volume.tar.gz"; then
    fail "Falha ao arquivar o volume. O container anterior será restaurado."
  fi
  [[ -s "$BACKUP_DIR/data-volume.tar.gz" ]] || fail "O arquivo do volume ficou vazio; migração cancelada."
  chmod 600 "$BACKUP_DIR/storage.sqlite" "$BACKUP_DIR/data-volume.tar.gz"
  ok "Backup do banco e de todo o volume criado em $BACKUP_DIR."
else
  # Se já existir um volume sem container, faz backup antes de reutilizá-lo.
  if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    mkdir -p "$BACKUP_ROOT"
    chmod 700 "$BACKUP_ROOT"
    BACKUP_DIR="$BACKUP_ROOT/omniroute-volume-$(date +%Y%m%d-%H%M%S)-$$"
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"
    if ! docker run --rm --user 0:0 --mount "type=volume,src=$VOLUME_NAME,dst=/data,readonly" \
         --entrypoint /bin/sh "$IMAGE_REF" -lc 'tar -czf - -C /data .' > "$BACKUP_DIR/data-volume.tar.gz"; then
      fail "O volume existente não pôde ser copiado; nenhuma aplicação foi iniciada."
    fi
    [[ -s "$BACKUP_DIR/data-volume.tar.gz" ]] || fail "Backup do volume existente vazio; operação cancelada."
    chmod 600 "$BACKUP_DIR/data-volume.tar.gz"
    ok "Backup preventivo do volume existente criado em $BACKUP_DIR."
  else
    info "Volume novo; não há dados anteriores a copiar."
  fi
fi

step "Preparando o volume e iniciando o OmniRoute"
if (( EXISTING == 1 )); then
  ROLLBACK_CONTAINER="omniroute-rollback-$(date +%Y%m%d%H%M%S)-$$"
  docker rename "$CONTAINER_NAME" "$ROLLBACK_CONTAINER" || fail "Não foi possível reservar o nome do container para migração."
  ok "Container antigo preservado temporariamente como '$ROLLBACK_CONTAINER'."
fi

# Sempre remove o container one-shot antigo, se houver, para garantir que a
# preparação das permissões seja executada nesta implantação.
compose rm -sf permissions-init >/dev/null 2>&1 || true
compose up -d || fail "Docker Compose não conseguiu iniciar os serviços."
ok "Docker Compose iniciou a preparação e a aplicação."

step "Aguardando a saúde do OmniRoute"
health_supported="$(docker inspect --format '{{if .State.Health}}yes{{else}}no{{end}}' "$CONTAINER_NAME" 2>/dev/null || echo no)"
if [[ "$health_supported" == "yes" ]]; then
  ready=0
  for attempt in $(seq 1 60); do
    state="$(docker inspect --format '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo missing)"
    health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$CONTAINER_NAME" 2>/dev/null || echo none)"
    if [[ "$state" == "running" && "$health" == "healthy" ]]; then ready=1; break; fi
    if [[ "$state" == "exited" || "$state" == "dead" || "$health" == "unhealthy" || "$state" == "missing" ]]; then
      docker logs --tail 80 "$CONTAINER_NAME" >&2 || true
      fail "O container não iniciou corretamente (estado=$state, saúde=$health)."
    fi
    sleep 3
  done
  (( ready == 1 )) || { docker logs --tail 80 "$CONTAINER_NAME" >&2 || true; fail "O OmniRoute não ficou healthy em 180 segundos."; }
  ok "Healthcheck do OmniRoute: healthy."
else
  state="$(docker inspect --format '{{.State.Status}}' "$CONTAINER_NAME")"
  [[ "$state" == "running" ]] || fail "Container não está em execução (estado=$state)."
  warn "A imagem não define healthcheck; o script verificará a escrita no volume e a publicação da porta."
fi

step "Validando volume, permissões, política de reinício e porta"
actual_volume="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}{{end}}' "$CONTAINER_NAME")"
[[ "$actual_volume" == "$VOLUME_NAME" ]] || fail "Volume inesperado em /data: '${actual_volume:-nenhum}', esperado '$VOLUME_NAME'."
ok "Volume '$VOLUME_NAME' montado em /data."

actual_restart="$(docker inspect --format '{{.HostConfig.RestartPolicy.Name}}' "$CONTAINER_NAME")"
[[ "$actual_restart" == "unless-stopped" ]] || fail "Política de reinício incorreta: '$actual_restart'."
ok "Política de reinício: unless-stopped."

if docker exec --user node "$CONTAINER_NAME" sh -lc 'set -eu; test -w /data; f="/data/.omniroute-write-test-$$"; touch "$f"; rm -f "$f"'; then
  ok "Usuário node consegue gravar e remover um arquivo de teste em /data."
else
  fail "Usuário node sem permissão de escrita em /data."
fi

actual_port="$(docker port "$CONTAINER_NAME" 20128/tcp 2>/dev/null || true)"
grep -Fxq '127.0.0.1:20128' <<< "$actual_port" || fail "Porta 20128 não está publicada somente no loopback."
ok "Porta local disponível em $URL (não exposta diretamente na rede)."

if docker exec "$CONTAINER_NAME" sh -lc 'test -s /data/storage.sqlite' >/dev/null 2>&1; then
  db_stat="$(docker exec "$CONTAINER_NAME" sh -lc 'stat -c "Tamanho=%s bytes | Modificado=%y | Proprietario=%U:%G" /data/storage.sqlite')"
  ok "Banco persistente encontrado: $db_stat"
else
  warn "storage.sqlite ainda não existe. Em instalação nova, abra a interface e salve uma configuração para inicializar o banco."
fi

step "Finalizando implantação"
if [[ -n "$ROLLBACK_CONTAINER" ]] && docker inspect "$ROLLBACK_CONTAINER" >/dev/null 2>&1; then
  # Já validamos a aplicação nova; remove apenas o container antigo, nunca o volume.
  docker rm "$ROLLBACK_CONTAINER" >/dev/null || fail "A aplicação está saudável, mas não foi possível remover o container antigo parado '$ROLLBACK_CONTAINER'. O volume e o backup foram preservados."
  ROLLBACK_CONTAINER=""
  OLD_CONTAINER_STOPPED=0
  ok "Container antigo removido depois da validação; o volume persistente foi mantido."
fi
SUCCESS=1
ok "Implantação concluída."
printf '\nURL: %s\n' "$URL"
printf 'Compose: %s/compose.yaml\n' "$INSTALL_DIR"
printf 'Para consultar logs: cd %q && docker compose -p %q logs --tail 100 omniroute\n' "$INSTALL_DIR" "$PROJECT_NAME"
if [[ -n "$BACKUP_DIR" ]]; then printf 'Backup de segurança: %s\n' "$BACKUP_DIR"; fi
printf '\n[IMPORTANTE] Abra a interface, confira suas configurações e faça um teste de reinicialização do container.\n'
