# Bolão Copa FIFA 2027

Plataforma web para bolão de palpites da Copa do Mundo Feminina da FIFA Brasil 2027.

## Estrutura do Projeto

- `frontend/` - Aplicação Next.js/TypeScript
- `backend/` - API FastAPI/Python
- `docker/` - Configurações Docker (se necessário)
- `docs/` - Documentação do projeto
- `openspec/` - Artefatos OpenSpec para especificação orientada a mudanças

## Pré-requisitos

- Docker e Docker Compose
- Node.js >= 18 (para desenvolvimento local)
- Python >= 3.11 (para desenvolvimento local)

## Desenvolvimento Local

Para iniciar o ambiente de desenvolvimento:

```bash
docker-compose up --build
```

O frontend estará disponível em http://localhost:3000
O backend estará disponível em http://localhost:8000

## Documentação

Consulte a documentação em `docs/` para:
- Requisitos do produto
- Arquitetura de software
- Decisões pendentes
- Guia do OpenSpec

## Licença

Este projeto está sob licença privada para uso interno do grupo único especificado nos requisitos.