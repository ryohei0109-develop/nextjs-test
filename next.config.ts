import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  experimental: {
    serverComponentsExternalPackages: ["@prisma/client", "prisma"],
  },
  outputFileTracingIncludes: {
    "/": [
      "./node_modules/@prisma/client/**/*",
      "./node_modules/@prisma/engines/**/*",
    ],
  },
};

export default nextConfig;
