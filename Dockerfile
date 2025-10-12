# ---------- Builder ----------
FROM node:22-bookworm-slim AS builder
WORKDIR /app

# Prisma スキーマを先にコピー（postinstall を殺すが、保険として）
COPY prisma ./prisma
COPY package.json package-lock.json ./

# ライフサイクルスクリプトを無効化して依存解決（postinstall回避）
RUN npm ci --omit=dev --ignore-scripts

# 残りのソースをコピー
COPY . .

# Prisma Client を明示生成（node_modules に生成物が入る）
RUN npx prisma generate

# Next.js を standalone でビルド
RUN npm run build

# ---------- Runner ----------
FROM node:22-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

# OpenSSL/CA（Prisma エンジン実行時の互換のため）
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# standalone 実行物と静的資産を配置
COPY --from=builder /app/.next/standalone ./ 
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# migrate 用に Prisma CLI／Client／Schema／Migrations を同梱
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma

EXPOSE 3000

# 起動前に migrate deploy を実行 → Next サーバ起動
# standalone のエントリは ./server.js
CMD ["bash", "-lc", "node -v && npx prisma migrate deploy && node server.js"]
