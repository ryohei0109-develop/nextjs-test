# ===========================
#  Build Stage
# ===========================
FROM node:20-bookworm AS build
WORKDIR /app

# 依存関係のインストール
COPY package*.json ./
RUN npm ci

# Prisma クライアントの生成（ここが最重要）
COPY prisma ./prisma
RUN npx prisma generate

# Next.js ビルド
COPY . .
RUN npm run build

# ===========================
#  Runtime Stage
# ===========================
FROM node:20-bookworm-slim AS runtime
WORKDIR /app

# 必要なランタイムファイルだけコピー
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./public

# Prisma エンジンの明示コピー
COPY --from=build /app/node_modules/@prisma /app/node_modules/@prisma

# OpenSSL 警告を防止（App Runner は OpenSSL 3）
ENV PRISMA_QUERY_ENGINE_LIBRARY=/app/node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000
CMD ["node", "server.js"]
