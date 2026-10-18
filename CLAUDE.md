# Instruções do projeto — Bolão Copa FIFA 2027

## Contexto e fontes
Este repositório prepara um sistema web de bolão para um único grupo da Copa do Mundo Feminina da FIFA Brasil 2027. A fonte de verdade do produto é [`docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md) (v3.1, 18/10/2026). Consulte também [`docs/architecture/arquitetura-software.md`](docs/architecture/arquitetura-software.md), que registra recomendações arquiteturais e decisões pendentes; ela não substitui os requisitos.

Precedência: requisitos aprovados → decisões de produto confirmadas → decisões arquiteturais formalmente aprovadas → instruções pontuais compatíveis → documentação técnica e boas práticas. Uma solicitação pontual não autoriza alterar silenciosamente regras aprovadas. Se houver conflito, ausência de informação ou decisão de negócio em aberto, descreva o conflito, proponha opções e peça decisão humana antes de implementar a parte afetada.

## Direção arquitetural
A direção técnica registrada é desenvolvimento local via Docker Compose, com frontend, backend e PostgreSQL em serviços separados; Next.js/TypeScript e Python/FastAPI são referências arquiteturais, com versões ainda por selecionar. GCP é somente um possível destino de portabilidade, sem implantação ou gestão no escopo. Consulte a arquitetura antes de propor estrutura, dependências ou operação. O processo decidido é leve, com governança manual; OpenSpec está disponível como scaffolding, mas não é obrigatório.

## Regras de segurança e produto
- Não exponha palpites de terceiros antes do encerramento da janela, nem confie na interface para impor autorização ou prazo; validação deve ocorrer no backend.
- Preserve as regras aprovadas de pontuação, corte de uma hora, privacidade, horário de Brasília e placar eliminatório ao fim de 120 minutos (sem gols de pênaltis). Não invente política para situações não especificadas.
- Proteja credenciais, sessões, tokens de recuperação e dados pessoais; não inclua segredos ou dados pessoais em código, documentação ou logs. Operações administrativas devem ter autorização e trilha de auditoria.
- Use privilégios mínimos, validação de entrada e consultas parametrizadas. Documente controles propostos sem alegar conformidade normativa não verificada.

## Qualidade e fluxo de trabalho
Faça mudanças pequenas e revisáveis. Para mudanças de produto, consulte primeiro os requisitos e decisões aplicáveis; se o fluxo SDD for aprovado, atualize/obtenha especificação e aprovação antes de implementar. Cubra regras de domínio, autorização, concorrência, idempotência, ranking e migrações com testes proporcionais à mudança; não afirme que testes passaram sem executá-los.

Consulte a documentação oficial correspondente às versões efetivamente selecionadas. Não invente versões, comandos, dependências, scripts ou recursos de infraestrutura. Não crie `AGENTS.md` automaticamente; só o faça quando houver uma necessidade concreta de compatibilidade identificada. No estado atual não há aplicação ou comandos de build/teste documentados.

## Limites operacionais
Não implemente funcionalidades, não instale dependências, não altere configurações executáveis nem crie recursos de nuvem sem solicitação e aprovação apropriadas. Não realize operações destrutivas ou em produção, não acesse nem publique segredos. Antes de qualquer mudança irreversível, inspecione os alvos e peça confirmação. Registre dúvidas e bloqueios em vez de preencher lacunas com suposições.
