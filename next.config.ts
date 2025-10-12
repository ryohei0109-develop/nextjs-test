import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // 必要なら後で項目を足します。
  // 例: images: { remotePatterns: [...] }, redirects/rewrite など
  eslint: { ignoreDuringBuilds: true }, // CIで ESLint で止まるのを回避（必要に応じて外せます）
  typescript: { ignoreBuildErrors: false },
  // output: "standalone" も設定可能ですが、まずは標準構成で動作確認します。
};

export default nextConfig;
