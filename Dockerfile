FROM node:22-alpine

# 安装 pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# 设置 CI 环境变量
ENV CI=true

WORKDIR /app

# 复制依赖文件
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

# 复制 TypeScript 配置文件
COPY tsconfig.json ./
RUN ls -la tsconfig.json

# 安装依赖（所有 install 都加上 --ignore-scripts）
RUN pnpm approve-builds || true
RUN pnpm install --frozen-lockfile --ignore-scripts --shamefully-hoist
RUN pnpm rebuild esbuild

# 复制源代码
COPY packages/toolkit/ packages/toolkit/
COPY packages/api/ packages/api/

# 把 tsconfig.json 复制到子包目录
COPY tsconfig.json packages/toolkit/
COPY tsconfig.json packages/api/

# 构建 toolkit
RUN pnpm --filter @web-tools/toolkit run build

# 强制重新建立 workspace 链接（也加上 --ignore-scripts）
RUN pnpm install --frozen-lockfile --ignore-scripts --shamefully-hoist

# 构建 api
RUN pnpm --filter @web-tools/api run build

EXPOSE 8080

CMD ["pnpm", "start"]
