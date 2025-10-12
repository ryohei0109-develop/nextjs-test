# --- Build stage ---
FROM node:22-bookworm-slim AS build
WORKDIR /app

# 依存解決用に package* と prisma を先にコピー
COPY package*.json ./
COPY prisma ./prisma

# postinstall を抑止して先に依存だけ入れる（prisma generate は後で手動）
RUN npm ci --ignore-scripts

# ソース投入
COPY . .

# Prisma クライアント生成（この時点では schema が存在する）
RUN npx prisma generate

# Next.js を本番ビルド（standalone）
RUN npm run build

# --- Runtime stage ---
FROM node:22-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# OpenSSL 3 を入れる（警告回避 & 互換）
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# standalone最小セット＋Prismaのランタイム資材を明示コピー
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

# 🔑 ここがポイント：Prismaのエンジンとクライアントを同梱
COPY --from=build /app/node_modules/.prisma /app/node_modules/.prisma
COPY --from=build /app/node_modules/@prisma /app/node_modules/@prisma

# 起動前に migrate を適用（初回＆デプロイ時）
CMD ["node", "server.js"]
