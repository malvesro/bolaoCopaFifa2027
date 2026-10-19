# ADR-001 — VSA pragmática em monorepo e persistência inicial

**Data:** 19/10/2026
**Status:** Direções recomendadas aprovadas pelo solicitante nesta conversa; desenho detalhado e implementação sujeitos a OpenSpec e aprovação humana aplicável. Aprovador organizacional não identificado.
**Fontes:** requisitos v3.4 (regras de produto); `decisoes-pendentes.md` (TEC-01/02/03, PROD-01/02/04/06/07); `arquitetura-software.md` (direção e alternativas); recomendações apresentadas ao solicitante sobre VSA no mesmo repositório e escolhas estratégicas.

## Contexto e decisão de direção

Manter `backend/` e `frontend/` na raiz do **mesmo repositório**, com toolchains e runtimes separados e comunicação por contrato de API. Organizar o backend em módulos por capacidade de negócio, com **fatias verticais por caso de uso** dentro dos módulos. Preservar um domínio proprietário e independente de FastAPI/SQLAlchemy para invariantes compartilhadas; a fatia reutiliza essa regra em vez de copiá-la. Aplicar DDD e Clean Architecture pragmaticamente: portas/adaptadores onde houver fronteira efetiva, sem árvores de camadas vazias por rotina. No frontend, agrupar código por funcionalidade sob `features/` e manter `app/` como composição/roteamento; telas e módulos backend não precisam ter correspondência 1:1. Contratos explícitos protegem os limites entre módulos e runtimes; a forma exata de exposição e o verificador de imports serão definidos no design da mudança.

Usar o PostgreSQL como autoridade de dados. Tratar revisões oficiais e auditoria como fatos, e pontuação, ranking e badges como derivados determinísticos, reconstruíveis e idempotentes; badges não dependem da projeção de ranking. Iniciar com recálculo coerente/transacional síncrono e **SQLAlchemy com sessões síncronas como direção inicial proporcional**, medindo latência e concorrência antes de considerar processamento assíncrono, fila ou outbox. A integridade do corte e da primeira divulgação requer protocolo de ingresso e barreira de publicação comprovados por testes concorrentes no PostgreSQL; um lock isolado não comprova que pedidos ainda não registrados terminaram.

Para a sessão web, a direção é **sessão opaca revogável mantida no servidor**, com cookie e defesa CSRF adequados à topologia efetiva. A API impõe autorização; renderização e cache do Next.js não substituem proteção no backend, especialmente durante reabertura do corte. Detalhes de expiração, cookie, CSRF, armazenamento e revogação exigem design e testes; a minuta TEC-01/PROD-07, que propõe JWT/refresh, não está aprovada em sua integralidade.

## Alternativas e consequências

- `fontes/features/<capacidade>/{backend,frontend}` ou um pacote único para Python/TypeScript: rejeitado como padrão; mistura toolchains e pressupõe correspondência inexistente entre telas e domínios. Uma pasta `fontes/{backend,frontend}` acrescenta aninhamento sem ganho identificado para este scaffold.
- Camadas completas `domain/application/adapters` replicadas em cada módulo: rejeitadas como obrigação estrutural; preserva-se a direção das dependências quando necessária, com código organizado pelo caso de uso.
- SQLAlchemy assíncrono e workers/filas desde o início: adiados até evidência de carga ou limites de latência; não há proibição futura. JWT curto com refresh foi considerado, mas a direção de sessão revogável no servidor favorece invalidação e simplifica o estado de admissão. Detalhes ainda exigem análise de ameaça.

**Efeito:** a árvore de diretórios ainda não implementa a decisão. O scaffold pode conter pastas de camadas vazias, que não são um contrato arquitetural. `asyncpg` no manifesto e `DATABASE_URL` de exemplo não estão alinhados com a direção síncrona; a seleção do driver, versões, pacotes, Alembic, session scope e compatibilidade de runtime pertencem à change técnica e não foram aprovados ou executados por este ADR. O mecanismo de sincronização do corte, ordenação de concorrência, política de conflitos e apresentação de projeções atrasadas permanecem abertos. Nenhuma regra de produto é modificada.

## Próxima validação

Abrir change OpenSpec específica para organização interna, com fonte/versão → deltas/cenários → tarefas → validação de dependências e fatia piloto; não inserir na change de scaffold `2026-10-18-technical-foundation`. Abrir change distinta para identidade (HU-22/23, TEC-01/PROD-07) após decidir lacunas do primeiro vínculo e dos controles técnicos residuais. Implementação, instalação de pacotes e execução local continuam fora do escopo desta decisão documental.
