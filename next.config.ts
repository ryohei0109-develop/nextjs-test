import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // ここは experimental ではなくトップレベル（Next 15）
  typedRoutes: true,

  reactStrictMode: true,

  // CI 中の ESLint 失敗で止めたくない場合は有効化（任意）
  eslint: { ignoreDuringBuilds: true },

  // 画像やファイルトレースを有効化（デフォでOKだが明示）
  outputFileTracing: true,

  // App Runner のポートは環境変数 PORT=3000 で受けるので特に不要
  // 必要なら他の設定を追記
};

export default nextConfig;
