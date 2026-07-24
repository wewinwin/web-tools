FROM node:22-alpine

# 安装 pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# 复制依赖文件
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

# 安装依赖（绕过 esbuild 脚本问题）
RUN pnpm approve-builds || true
RUN pnpm install --frozen-lockfile --ignore-scripts
RUN pnpm rebuild esbuild

# 复制源代码
COPY packages/toolkit/ packages/toolkit/
COPY packages/api/ packages/api/

# 构建
RUN pnpm --filter @web-tools/toolkit run build && \
    pnpm --filter @web-tools/api run build

EXPOSE 8080

CMD ["pnpm", "start"]
