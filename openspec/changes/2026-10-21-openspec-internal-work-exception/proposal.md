# Proposta: exceção de OpenSpec para documentação interna e harness

## Por quê

As instruções atuais tornam OpenSpec obrigatório de forma ampla, embora mudanças internas de documentação ou do harness de desenvolvimento/agentes possam não alterar comportamento, requisitos ou contratos do produto. Definir uma exceção objetiva reduz processo desnecessário sem dispensar revisão, autorização humana ou OpenSpec para mudanças com efeito no produto.

## O que muda

- Delimitar OpenSpec obrigatório a mudanças de produto e a mudanças técnicas que afetem comportamento, requisitos, contratos, dados, arquitetura, segurança, release, implantação ou operação do produto.
- Permitir dispensar change OpenSpec apenas para trabalho estritamente interno de documentação descritiva ou harness de desenvolvimento/agentes, quando não houver efeito direto ou indireto no produto, nos requisitos normativos ou nos contratos.
- Classificar pela semântica e pelo efeito da mudança, não pela extensão ou caminho do arquivo. Documentação que altera o significado de requisito não é elegível.
- Exigir para a dispensa registro do escopo e da justificativa no PR, mantendo revisão, aprovação humana e validações pertinentes. Mudanças mistas devem ser separadas quando possível; caso contrário, OpenSpec é obrigatório. Dúvida de classificação ou impacto também segue OpenSpec até esclarecimento. `CONTRIBUTING.md` explicará como registrar a dispensa nos campos existentes do template de PR, sem alterar `.github/pull_request_template.md`.
- Refletir a mesma política em `CLAUDE.md`, `CONTRIBUTING.md`, `README.md` e `openspec/config.yaml`, e incorporar seletivamente o guia `docs/architecture/configuracao-claude-code.md` da branch `chore/consolida-fundacao-tecnica` (referência: commit `7838dffe8f21f2e12ce48f08a7937e73dd7aaafe`), sem tratar a autorização do guia como aprovação da change ou da aplicação.
- Preservar os perfis atuais em `.claude/agents/`, configuração local e skill Caveman; não alterar configuração executável nem o fluxo `/opsx:apply` nesta change.

Esta própria mudança de governança segue a política vigente, que exige OpenSpec, e deve receber aprovação humana explícita antes de atualizar os documentos-alvo. A exceção proposta só passa a valer depois que a política for incorporada por merge aprovado em `main`, branch autoritativa atual; até então, permanece vigente a política atual.

## Capacidades

### Novas capacidades

Nenhuma.

### Capacidades modificadas

Nenhuma capacidade ou comportamento de produto é alterado. A política modifica o processo interno de contribuição, não contratos do sistema; a change declara `skip_specs: true` em `.openspec.yaml`.

## Impacto

Afeta `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `openspec/config.yaml` e o novo `docs/architecture/configuracao-claude-code.md`, além dos artefatos desta change. Não altera aplicação, API, persistência, dependências ou execução do produto. Exige aprovação humana desta change antes de atualizar as fontes de política.
