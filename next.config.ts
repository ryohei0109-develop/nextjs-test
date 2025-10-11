import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.dog.ceo'
      }
    ]
  },
  eslint: {
    // ビルド時の ESLint エラーで失敗させない（暫定）
    ignoreDuringBuilds: true,
  }
};

export default nextConfig;
