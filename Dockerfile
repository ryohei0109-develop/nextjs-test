# --- Build stage ---
FROM node:22-bookworm-slim AS build
WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma
RUN npm ci --ignore-scripts

COPY . .
# Prisma クライアント/エンジンを生成（engineType=library, binaryTargets=debian-openssl-3.0.x）
RUN npx prisma generate

# Next.js 本番ビルド（standalone）
RUN npm run build

# --- Runtime stage ---
FROM node:22-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# OpenSSL を入れておく（警告/互換対策）
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# standalone の最小セット
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

# ★ Prisma 6 系はここだけでOK（.prisma は不要）
COPY --from=build /app/node_modules/@prisma /app/node_modules/@prisma

CMD ["node", "server.js"]
