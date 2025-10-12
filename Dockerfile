# --- Build stage ---
FROM node:22-bookworm-slim AS build
WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma
RUN npm ci --ignore-scripts

COPY . .
RUN npx prisma generate
RUN npm run build

# --- Runtime stage ---
FROM node:22-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0
EXPOSE 3000

# OpenSSL（念のため）
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Next の standalone 出力
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

# Prisma のランタイム資材を同梱
COPY --from=build /app/node_modules/@prisma /app/node_modules/@prisma

# ★ Prisma Query Engine の場所を明示：bookworm(OpenSSL 3系)
ENV PRISMA_QUERY_ENGINE_LIBRARY=/app/node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node

# 起動
CMD ["node", "server.js"]
