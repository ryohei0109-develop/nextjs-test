# --- Build stage ---
FROM node:22-bookworm-slim AS build
WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma
RUN npm ci --ignore-scripts

COPY . .
RUN npx prisma generate
RUN npm run build

# --- Runtime stage ---
FROM node:22-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0
EXPOSE 3000

# 念のため OpenSSL
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Next の standalone 出力（node_modules を含む最小セット）
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

# （明示コピーは不要になるが、残しても害なし）
# COPY --from=build /app/node_modules/@prisma /app/node_modules/@prisma

CMD ["node", "server.js"]
