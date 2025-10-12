# ---- Base ----
FROM node:22.20.0-slim AS base
ENV NODE_ENV=production
WORKDIR /app

# システム更新（必要最低限）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ---- Deps layer ----
FROM base AS deps
# 依存関係解決のため package* と prisma スキーマを先にコピー
COPY package.json package-lock.json ./
COPY prisma ./prisma

# ここで postinstall を無効化して "npm ci"
#  => prisma がコピーされる前に generate が走って失敗…を防止
RUN npm ci --ignore-scripts

# ---- Build ----
FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./package.json
COPY --from=deps /app/package-lock.json ./package-lock.json

# アプリ本体と Prisma, Next 構成をコピー
COPY . .

# Prisma クライアント生成 → Next ビルド
# package.json の build に prisma generate が入っているが、
# ここで明示的に実行しておく（冪等なので二重でも問題なし）
RUN npx prisma generate && npm run build

# ---- Runtime ----
FROM base AS runner
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
WORKDIR /app

# 必要物だけコピー
COPY --from=build /app/package.json ./
COPY --from=deps  /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/prisma ./prisma

EXPOSE 3000

# 起動時に migrate deploy を噛ませてから start
CMD ["sh", "-c", "npm run migrate:deploy && npm run start"]
