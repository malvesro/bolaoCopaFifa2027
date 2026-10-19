# Frontend - Next.js/TypeScript

Esta pasta contém o scaffold da aplicação Next.js/TypeScript. A direção de funcionalidades em `features/` está registrada no `docs/architecture/decisoes-tecnicas/ADR-001-vsa-monorepo-e-persistencia.md`; organização interna, contratos e segurança da sessão dependem do design das changes aplicáveis.

## Estrutura

- `app/` - Rotas, layouts, loading/error/not-found (App Router)
- `features/` - Organização por funcionalidades (auth, tournament, predictions, ranking, admin, support)
- `components/` - Componentes acessíveis reutilizáveis
- `lib/api/` - Cliente tipado para comunicação com o backend, serialização, erros e sessão
- `lib/dates/` - Formatação do horário BRT (UTC-03:00)
- `tests/` - Testes unitários e de integração do frontend

## Convenções

- Preferir App Router e Server Components para renderização/leitura segura
- Manter componentes de cliente pequenos, apenas para formulário, contador, interações e APIs do navegador
- Nunca serializar em props dados privados alheios ao usuário
- Chamada de API centralizada com tipos de contrato e mapeamento de erro previsível
- Estados explícitos de carregamento, erro, vazio e sucesso
- Formulário valida no cliente por UX e no backend por segurança
- Datas formatadas com UTC-03:00 conforme requisito
- Acessibilidade: navegação por teclado, rótulos e erros associados, contraste, foco visível