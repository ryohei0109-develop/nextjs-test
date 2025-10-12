# --- Build stage ---
FROM node:20-bookworm-slim AS build
WORKDIR /app

# 依存インストール（キャッシュ効く順）
COPY package*.json ./
RUN npm ci

# ソース投入
COPY . .

# Prismaのクライアント生成（DB接続は不要）
RUN npx prisma generate || true

# Next.jsを本番ビルド（standalone）
RUN npm run build

# --- Runtime stage ---
FROM node:20-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# standalone方式で必要物だけコピー
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public
COPY --from=build /app/prisma ./prisma

# 起動前に本番DBへマイグレーションを適用（初回＆デプロイ時）
# ※ DATABASE_URL は App Runner の環境変数で渡します
CMD ["sh", "-c", "npx prisma migrate deploy && node server.js"]
