# ==========================================================
# Build stage
# ==========================================================
FROM node:22-bookworm-slim AS build

WORKDIR /app

# package.jsonとlockファイルを先にコピー（キャッシュを効かせる）
COPY package*.json ./

# Prismaスキーマを先にコピーしておく
COPY prisma ./prisma

# 依存関係をインストール（--ignore-scriptsでpostinstallをスキップ）
RUN npm ci --ignore-scripts

# ソースコードをコピー
COPY . .

# 🔥 Prisma Clientを生成（必須）
RUN npx prisma generate

# Next.jsのビルド（standalone出力）
RUN npm run build

# ==========================================================
# Runtime stage
# ==========================================================
FROM node:22-bookworm-slim AS runtime

WORKDIR /app

# 本番用の軽量構成
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0
EXPOSE 3000

# OpenSSLを入れる（Prismaのlibquery_engine依存）
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# --- standalone構成をコピー ---
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

# --- Prismaエンジンを同梱（これが超重要）---
COPY --from=build /app/node_modules/@prisma /app/node_modules/@prisma

# --- Prisma Query Engineのライブラリパスを指定（明示）---
ENV PRISMA_QUERY_ENGINE_LIBRARY=/app/node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node

# --- 起動コマンド ---
CMD ["node", "server.js"]
