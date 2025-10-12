# ===== base =====
FROM node:22-bookworm-slim AS base
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
# App Runner 既定ポート（今回は 3000）
ENV PORT=3000

# ===== deps: 依存を入れる。postinstall は無効化し、devDeps も入れる =====
FROM base AS deps
WORKDIR /app

# 先に package をコピー（キャッシュ効率）
COPY package.json package-lock.json ./

# postinstall（= prisma generate）をここでは走らせない
# → prisma/ をまだコピーしていないため。後段で明示実行します。
RUN npm ci --ignore-scripts

# ===== builder: ソース投入→ビルド（devDeps 必須）=====
FROM base AS builder
WORKDIR /app

# node_modules（devDeps 付き）を引き継ぐ
COPY --from=deps /app/node_modules ./node_modules

# Prisma スキーマやソース一式をコピー
COPY . .

# ビルド前に generate を含む build を実行
# package.json の "build": "prisma generate && next build" を利用
# DATABASE_URL は generate には不要ですが、プラグインによっては欲しがることがあるので ARG で受け取り可能に
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL

# Next/Tailwind のビルド（devDependencies が必要）
RUN npm run build

# 本番用に devDeps を除去（ランナーに渡す node_modules を軽量化）
RUN npm prune --omit=dev

# ===== runner: 実行用（できるだけ軽く）=====
FROM node:22-bookworm-slim AS runner
WORKDIR /app

# 本番向け
ENV NODE_ENV=production
ENV PORT=3000

# ランタイムに必要な最低限をコピー
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
# Prisma Client は node_modules 内に生成済み。念のためスキーマも持っておく（不要なら省略可）
COPY --from=builder /app/prisma ./prisma

# ここで migrate を実行してから立ち上げ（初回・スキーマ変更時の安全策）
# App Runner 側で DATABASE_URL を環境変数として設定済みであることが前提
CMD sh -c "npx prisma migrate deploy && node node_modules/next/dist/bin/next start -p ${PORT}"
