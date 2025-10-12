# ベース: Node 22 + Debian slim
FROM node:22-bookworm-slim AS base
ENV NODE_ENV=production
WORKDIR /app

# OpenSSL 3 / CA を用意（Prismaのネイティブライブラリで必要）
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 依存関係をインストール（devDeps も含めて入れる：実行時に prisma CLI を使うため）
# npmを利用（pnpm/yarnを使う場合は適宜変更）
COPY package.json package-lock.json ./
RUN npm ci

# Prisma のスキーマ/マイグレーションを先に配置＆クライアント生成
# 生成物は node_modules/@prisma/client に入る
COPY prisma ./prisma
RUN npx prisma generate

# アプリ本体を配置してビルド
COPY . ./
# Next.js ビルド（エラー時はログを見やすくするためCI=false）
ENV CI=false
RUN npm run build

# App Runner は 8080 を想定
ENV PORT=8080
EXPOSE 8080

# ヘルスチェックは "/" を叩く前提
# 起動時に migrate deploy を実行 → その後アプリ起動
# DATABASE_URL は App Runner の環境変数で注入される（このDockerfileでは定義しない）
CMD sh -c "\
  echo '==> Prisma migrate deploy を実行' && \
  npx prisma migrate deploy && \
  echo '==> Next.js を起動' && \
  npm run start -- -p ${PORT}"
