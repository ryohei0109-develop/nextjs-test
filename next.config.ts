import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  // App Router/Pages どちらでもOK。特別な出力モードは使わずシンプルに起動
  // （standaloneを使うとPrisma CLIが落ちることがあるため、まずは安定重視）
  // output: "standalone",
  // 必要に応じて画像ドメイン等を設定
  images: {
    // domains: ["example.com"],
  },
  experimental: {
    // 必要なら適宜
  },
};

export default nextConfig;
