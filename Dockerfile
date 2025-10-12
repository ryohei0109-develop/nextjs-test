# ---------- Builder ----------
FROM node:22.20.0-slim AS builder
ENV NODE_ENV=development
WORKDIR /app

# まず package* と prisma を入れる（postinstall=prisma generate 対策）
COPY package*.json ./
COPY prisma ./prisma

# dev 依存関係込みで入れる（ビルドに必要）
RUN npm ci

# 残りのソースを投入
COPY . .

# Next.js は standalone 出力。package.json の "build" は
# "prisma generate && next build" を想定（ユーザ提供の定義）。:contentReference[oaicite:1]{index=1}
RUN npm run build

# ---------- Runner ----------
FROM node:22.20.0-slim AS runner
ENV NODE_ENV=production
WORKDIR /app

# App Runner は 3000 を使う条件なので固定
ENV PORT=3000

# Next の standalone 方式に従って必要物だけコピー
# - .next/standalone 内に Node 実行に必要な node_modules がまとまる
# - .next/static と public は別コピー
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./public/.next/static
COPY --from=builder /app/public ./public
# マイグレーション実行用に migrations も持ってくる
COPY --from=builder /app/prisma ./prisma

# 健康のため（が、基本 slim には CA 入ってます）
# RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

EXPOSE 3000

# 起動時に migrate deploy -> Next を起動
# App Runner の環境変数に DATABASE_URL を設定しておくこと。
CMD bash -lc "npx prisma migrate deploy && node server.js"
