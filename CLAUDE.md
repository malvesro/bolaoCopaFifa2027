# Instruções do projeto — Bolão Copa FIFA 2027

## Contexto e fontes
Este repositório prepara um sistema web de bolão para um único grupo da Copa do Mundo Feminina da FIFA Brasil 2027. A fonte canônica do produto é [`docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md`](docs/requirements/requisitos-bolao-copa-mundo-feminina-2027.md) (v3.2, 18/10/2026). Consulte também [`docs/architecture/arquitetura-software.md`](docs/architecture/arquitetura-software.md), que registra recomendações arquiteturais e decisões pendentes; ela não substitui os requisitos.

Precedência: requisitos aprovados → decisões de produto confirmadas → decisões arquiteturais formalmente aprovadas → especificações OpenSpec aprovadas dentro desses limites → instruções pontuais compatíveis → documentação técnica e boas práticas. Uma solicitação pontual não autoriza alterar silenciosamente regras aprovadas. Se houver conflito, ausência de informação ou decisão de negócio em aberto, descreva o conflito, proponha opções e peça decisão humana antes de implementar a parte afetada.

## Direção arquitetural
A direção técnica é desenvolvimento local via Docker Compose, com Next.js/TypeScript, Python/FastAPI e PostgreSQL em serviços separados; versões ainda serão selecionadas. Windows 11 com WSL 2/Ubuntu é ambiente suportado a validar. A arquitetura recomendada é monólito modular, com DDD pragmático, Clean Architecture e organização por funcionalidades, sem abstrações desnecessárias. Produção não é presumida como idêntica ao ambiente local; GCP é apenas possibilidade de portabilidade, sem implantação ou gestão no escopo. O processo SDD é obrigatório e deve usar OpenSpec para especificação, planejamento e evolução, com governança e aprovações humanas. Consulte a arquitetura e os registros de decisões antes de propor estrutura, dependências ou operação; propostas arquiteturais não aprovadas não prevalecem sobre requisitos.

## Regras de segurança e produto
- Não exponha palpites de terceiros antes do encerramento da janela, nem confie na interface para impor autorização ou prazo; validação deve ocorrer no backend.
- Preserve as regras aprovadas de pontuação, corte de uma hora, privacidade, horário de Brasília e placar eliminatório ao fim de 120 minutos (sem gols de pênaltis). Mudança oficial de kickoff pode reabrir a janela: durante a reabertura, escritas são permitidas até o novo corte e novas leituras de palpites alheios ficam ocultas; divulgação já observada não tem confidencialidade restaurada. Não invente política para situações não especificadas.
- Proteja credenciais, sessões, tokens de recuperação e dados pessoais; não inclua segredos ou dados pessoais em código, documentação ou logs. Operações administrativas devem ter autorização e trilha de auditoria.
- Use privilégios mínimos, validação de entrada e consultas parametrizadas. Documente controles propostos sem alegar conformidade normativa não verificada.

## Qualidade e fluxo de trabalho
Faça mudanças pequenas e revisáveis. Use OpenSpec no fluxo SDD obrigatório para especificar, planejar e evoluir mudanças; artefatos completos não substituem aprovação humana quando necessária. Precedência: requisitos aprovados → decisões de produto confirmadas → decisões arquiteturais aprovadas → especificações OpenSpec aprovadas dentro desses limites. Registre rastreabilidade entre fonte/versão, delta, tarefas e validação; consulte primeiro os requisitos e decisões aplicáveis e obtenha aprovação antes de alterar regras de produto. Cubra regras de domínio, autorização, concorrência, idempotência, ranking e migrações com testes proporcionais à mudança; não afirme que testes passaram sem executá-los.

Consulte a documentação oficial correspondente às versões efetivamente selecionadas. Não invente versões, comandos, dependências, scripts ou recursos de infraestrutura. Não crie `AGENTS.md` automaticamente; só o faça quando houver uma necessidade concreta de compatibilidade identificada. No estado atual não há aplicação ou comandos de build/teste documentados.

## Limites operacionais
Não implemente funcionalidades, não instale dependências, não altere configurações executáveis nem crie recursos de nuvem sem solicitação e aprovação apropriadas. Não realize operações destrutivas ou em produção, não acesse nem publique segredos. Antes de qualquer mudança irreversível, inspecione os alvos e peça confirmação. Registre dúvidas e bloqueios em vez de preencher lacunas com suposições.
