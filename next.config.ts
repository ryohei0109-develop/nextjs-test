import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // App Runner は Node サーバ型なのでデフォルト（server）でOK
  // サイズ削減のため standalone 出力
  output: "standalone",

  // 本番で ESLint によるビルド失敗は避ける（任意）
  eslint: { ignoreDuringBuilds: true },

  // 型チェック失敗でビルド止めたくない場合は true に（任意）
  // typescript: { ignoreBuildErrors: false },

  // 必要なら experimental はここに（Next 15 は top-level に置く想定）
  experimental: {
    // 例: typedRoutes など必要に応じて
    // typedRoutes: true,
  },
};

export default nextConfig;
