// next.config.ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",

  // Prisma を外部依存として扱う（bundler に消されないように）
  experimental: {
    serverComponentsExternalPackages: ["@prisma/client", "prisma"],
  },

  outputFileTracingIncludes: {
    "/": [
      "./node_modules/@prisma/client/**/*",
      "./node_modules/@prisma/engines/**/*",
    ],
  },

  images: {
    remotePatterns: [
      { protocol: "https", hostname: "images.dog.ceo" },
    ],
  },
};

export default nextConfig;
