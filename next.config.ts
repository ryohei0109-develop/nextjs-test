import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // App Runner の Node ランタイムで動かす前提
  output: "standalone",

  // 必要ならここに（Next 15 は experimental をトップレベルで）
  experimental: {
    typedRoutes: true,
  },

  // もし ESLint エラーでビルドが止まると困る場合のみ有効化
  // eslint: { ignoreDuringBuilds: true },

  // 画像最適化を App Runner 内でやる場合はこのままでOK
  // もし外部CDNのみで完結させるなら unoptimized: true の検討も可
  images: {
    // remotePatterns: [{ protocol: "https", hostname: "..." }],
  },
};

export default nextConfig;
