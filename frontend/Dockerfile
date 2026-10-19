# Base comum: Node 20 LTS (Next 14 exige Node >= 18.17)
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

# Dependências (exige package-lock.json)
FROM base AS deps
RUN npm ci

# Desenvolvimento: usado pelo docker-compose (target: dev) com o código montado por volume
FROM deps AS dev
ENV NEXT_TELEMETRY_DISABLED=1
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Build de produção (output standalone)
FROM deps AS builder
ENV NEXT_TELEMETRY_DISABLED=1
COPY . .
RUN npm run build

# Produção: imagem final enxuta, usuário não-root
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
