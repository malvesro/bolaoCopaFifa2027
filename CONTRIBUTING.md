# Guia de Contribuição

Obrigado por contribuir com o Bolão da Copa do Mundo Feminina da FIFA Brasil 2027. Este guia resume o fluxo do projeto. Em caso de divergência, prevalecem os documentos citados na seção "Onde está cada documento".

> **Aviso:** os comandos de build, lint e testes ainda **não foram validados por execução** neste repositório. Não há suíte de testes implementada. Não declare nada como testado sem executá-lo e registrar o resultado.

## 1. Fluxo de trabalho (SDD com OpenSpec)

O desenvolvimento segue **Spec-Driven Development** com OpenSpec, que é obrigatório. A governança e as aprovações são **humanas**. Concluir os artefatos de uma change não autoriza implementação.

1. **Leia o `CLAUDE.md`** na raiz, que define precedência e limites.
2. **Identifique o requisito de origem** nos [Requisitos v3.4](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md) e verifique pendências em [Decisões Pendentes](docs/requirements/decisoes-pendentes.md).
3. **Crie a change** em `openspec/changes/<nome>/` (por exemplo, com `/opsx:propose <nome>`). Ela deve conter `proposal.md`, `design.md` e `tasks.md`, com a fonte e a versão citadas.
4. **Obtenha aprovação humana** do responsável técnico ou de produto. Nenhuma linha de código deve ser alterada antes dela.
5. **Implemente em fatias pequenas** a partir das tarefas aprovadas (`/opsx:apply`).
6. **Valide** a change com `openspec validate --all --strict` e execute os testes pertinentes, registrando o resultado real.
7. **Arquive** a change concluída (`/opsx:archive`) somente após a validação.

Regras que exigem atenção especial: pontuação 6/3/2/1/0, corte uma hora antes do kickoff oficial vigente, desempates do ranking e mata-mata apurado aos 120 minutos. Essas regras não podem ser alteradas sem decisão aprovada.

## 2. Convenções de commit e branch

**Commits** seguem [Conventional Commits](https://www.conventionalcommits.org/) em português, como no histórico do projeto:

```
feat: adiciona endpoint de palpites
docs: atualiza proposta OpenSpec de fundação técnica
chore: ajusta configuração do editor
```

Tipos usados no histórico até agora: `docs`, `feat` e `chore`.

**Branches** (convenção proposta, ainda não formalizada): `tipo/descricao-curta`, em minúsculas e com hífens, por exemplo `docs/revisao-prod-06` ou `feat/cadastro-palpites`.

## 3. O que NÃO fazer

Resumo das restrições do `CLAUDE.md`:

- Não implemente funcionalidades sem change OpenSpec aprovada.
- Não exponha palpites de outros participantes antes do corte.
- Não grave segredos, senhas, tokens ou dados pessoais no repositório. Use o `.env.example` como modelo e nunca versione o `.env`.
- Não opere ambientes de produção nem faça ações destrutivas sem inspeção e confirmação.
- Não instale dependências, altere configurações executáveis ou crie recursos de nuvem sem autorização.
- Não crie `AGENTS.md` nem documentação extra sem necessidade identificada e solicitação.
- Não trate a conclusão de um artefato OpenSpec como aprovação humana.
- Não invente política para situações pendentes. Registre a lacuna e peça decisão.

## 4. Antes de abrir um Pull Request

- Use o template em `.github/pull_request_template.md`.
- Mantenha as mudanças pequenas e revisáveis.
- Atualize a documentação afetada e cite a change e o requisito de origem.
- Declare apenas os testes e validações que foram efetivamente executados.

## 5. Onde está cada documento

| Assunto | Documento |
|---|---|
| Instruções para agentes e precedência | [`CLAUDE.md`](CLAUDE.md) |
| Visão geral, Docker e onboarding | [`README.md`](README.md) |
| Variáveis de ambiente (modelo) | [`.env.example`](.env.example) |
| Regras de produto (fonte normativa v3.4) | [`docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md) |
| Decisões pendentes e status | [`docs/requirements/decisoes-pendentes.md`](docs/requirements/decisoes-pendentes.md) |
| Critérios de badges (PROD-06) | [`docs/requirements/PROD-06-criterios-badges-gamificacao.md`](docs/requirements/PROD-06-criterios-badges-gamificacao.md) |
| Arquitetura de software | [`docs/architecture/arquitetura-software.md`](docs/architecture/arquitetura-software.md) |
| Revisão arquitetural multiagentes | [`docs/architecture/revisao-arquitetura-multiagentes.md`](docs/architecture/revisao-arquitetura-multiagentes.md) |
| Configuração OpenSpec | [`openspec/config.yaml`](openspec/config.yaml) |
| Changes OpenSpec | [`openspec/changes/`](openspec/changes/) |
| Guia do backend | [`backend/README.md`](backend/README.md) |
| Guia do frontend | [`frontend/README.md`](frontend/README.md) |

Lembre-se: os documentos de `docs/` são consultados sob demanda. Ao decidir ou alterar uma área, abra o documento correspondente antes.
