This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.


## prisma studioの起動方法
npx prisma studio

## さとへのmemo
1. 下記コマンドを実行
npx prisma generate
※ターミナルを別で立ち上げて実行しておくと楽

2. prisma.tsのimportを下記に変更
import { PrismaClient } from '@/generated/prisma'


## ChatGTPへのデプロイ設定ファイル作成指示メモ
next.js+prisma+posgresqlで、GitHubActions+AWS ECR+AppRunnerでCI/CDを構築している。 
で、エラーばっかりで全然うまくいかないから、教えてほしい。
Prisma周りでかなりエラーでる。 

下記ファイルの書き方について、全量をちょうだい
・Dockerfile 
・next.config.ts 
・deploy-apprunner.yml
・push-initial-image.yml
※他にも書き換えが必要なファイルがあれば指示して。

■補足
・トライ&エラーじゃなくて、一発で必ず成功する設定ファイルをちょうだい。
・Node.jsのバージョンはv22.20.0です。
・今現在の各種設定ファイルは添付しました。
・AppRunnerは デプロイ方法を「手動」にしています。
・環境変数はAppRunnerとGitHubActionsともに「DATABASE_URL」のみ設定しています。
・AppRunnerのポートは3000
・Dockerfileの書き方について、npm ci の実行中に postinstall（= prisma generate）が走って、まだ prisma/ フォルダを COPY していないためスキーマが見つからず失敗する、なんてことはやめてね。
・nextjs-test\prisma\migrations\20251011033524_init\migration.sqlはGitHub上で管理できている。
・next.jsのバージョンは15.5.4
  →つまり、next.config.tsにexperimentalをもし書く場合は、外に出さないとダメだよ
・prismaのバージョンは6.16.2
・standaloneはどっちでもいいが、まずしっかり動いてほしい。
・tailwindは4系を使っている

■注意点
・OIDCのrole-to-assumeは"arn:aws:iam::775209358765:role/github-oidc-deploy-role"です。
  →ダブルクォーテーションで囲まないとエラーになるよね？
・AppRunnerのARNは"arn:aws:apprunner:ap-northeast-1:775209358765:service/nextjs-test/0c09533fdc5d41ddb9d5f5d446fc0e85"です。
  →これもダブルクォーテーションで囲まないとエラーになるよね？
・「--omit=dev」はビルド前に使っちゃダメだと思うんだけど、それはわかってるよね？
・Dockerfileにて、base で NODE_ENV=production を宣言した状態で npm ci を実行すると devDependencies がインストールされません（= Tailwind / @tailwindcss/postcss / Typescript などが無い）→ Next の CSS ビルドでコケます。
  →これ注意してね
