# OmniRoute no Docker Engine/WSL2 — instalação com um único script

O desenvolvedor executa **um único comando**; o script verifica pré-requisitos, gera o Docker Compose, preserva os dados, corrige permissões, inicia o OmniRoute e valida o resultado.

## Como executar

No Ubuntu/WSL2, coloque `setup-omniroute.sh` no diretório em que deseja executá-lo e rode:

```bash
bash setup-omniroute.sh
```

Não é necessário executar uma lista de comandos separadamente nem marcar o script como executável.

## O que o script faz

1. Verifica Docker Engine e Docker Compose v2.
2. Se já existir `omniroute`, verifica que a instalação usa o volume nomeado em `/data`, `DATA_DIR=/data`, o usuário `node` e a porta local `127.0.0.1:20128`. Se detectar uma configuração diferente não suportada, interrompe sem remover o container.
3. Em migração, para a aplicação de forma graciosa, cria backup do `storage.sqlite` e de todo o volume, e só então prepara a migração.
4. Gera `~/omniroute-docker/compose.yaml` e `.env`.
5. Executa um serviço temporário como `root` que ajusta o proprietário de `/data` para UID/GID `1000:1000` e define `750` para o diretório.
6. Inicia o OmniRoute como usuário `node`, montando o volume existente em `/data`, com `DATA_DIR=/data`, porta local `20128`, `restart: unless-stopped` e parada graciosa de 40 segundos.
7. Espera o healthcheck, verifica a montagem, testa escrita como `node` e confirma a política de reinício.
8. Se a migração falhar depois de o container antigo ser reservado, tenta restaurá-lo automaticamente. Não remove volumes.

## Arquivos criados no Ubuntu

- `~/omniroute-docker/compose.yaml` — definição Docker Compose, com comentários.
- `~/omniroute-docker/.env` — imagem e volume utilizados.
- `~/omniroute-backups/` — backups privados feitos quando já havia um volume/container.

As pastas de configuração e backup ficam privadas ao usuário (`chmod 700`); os arquivos de configuração/backup recebem permissão restrita. Ao migrar uma instalação existente, o Compose também preserva as variáveis efetivas configuradas no container; por isso, **não publique nem versione o `compose.yaml` gerado**, pois variáveis de ambiente podem conter segredos.

## Resultado esperado

O script imprime etapas numeradas e mensagens `[OK]`, `[AVISO]` ou `[ERRO]`. Ao concluir, mostra `http://localhost:20128`, o caminho do Compose e, quando aplicável, o local do backup.

Abra a interface, confira suas configurações e salve uma alteração de teste. Reiniciar o container deve manter a configuração porque o banco fica no volume `omniroute-data`, separado do ciclo de vida do container. Volumes Docker sobrevivem à remoção do container, a menos que sejam excluídos explicitamente: https://docs.docker.com/engine/storage/volumes/

## Segurança e limites

- O script **nunca** executa `docker volume rm`, `docker volume prune` ou `docker compose down -v`.
- Em container existente, se o banco `/data/storage.sqlite` não puder ser copiado para backup, a migração é interrompida.
- Se o container atual tiver montagens adicionais, usuário, porta ou `entrypoint`/`command` personalizados, o script interrompe sem tentar adivinhar como preservá-los.
- Em instalação nova, a imagem padrão é `diegosouzapw/omniroute:latest`. Para reproduzir builds imutavelmente em equipe, fixem uma tag validada ou digest e revisem a atualização de imagem em separado.
- `restart: unless-stopped` inicia o container quando o Docker Engine está ativo, exceto se ele foi explicitamente parado. Não inicia por si só uma distribuição WSL desligada.

## Referências

- OmniRoute Docker Guide: https://github.com/diegosouzapw/OmniRoute/wiki/Docker-Guide
- Docker volumes: https://docs.docker.com/engine/storage/volumes/
- Docker Compose `depends_on` e `service_completed_successfully`: https://docs.docker.com/reference/compose-file/services/
- Docker Compose `pull_policy`: https://docs.docker.com/reference/compose-file/services/#pull_policy
