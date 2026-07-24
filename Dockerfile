FROM node:22-alpine

RUN corepack enable && corepack prepare pnpm@latest --activate
ENV CI=true
WORKDIR /app

# 1. 复制依赖文件 (保留根目录的 tsconfig)
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.json ./
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

# 2. 依赖安装
RUN pnpm install --frozen-lockfile --ignore-scripts
RUN pnpm rebuild esbuild
RUN pnpm install --frozen-lockfile

# 3. 【重要修改】：把根目录的 tsconfig.json 复制到子包目录里！
# 因为你的 tsc 是在 /app/packages/api/ 目录下执行的，它需要在那里找到配置文件
COPY tsconfig.json packages/toolkit/
COPY tsconfig.json packages/api/

# 4. 复制源代码
COPY packages/toolkit/ packages/toolkit/
COPY packages/api/ packages/api/

# 5. 构建 (注意顺序，如果 api 依赖 toolkit 的产物，可能 toolkit 需要先构建)
RUN pnpm --filter @web-tools/toolkit run build
RUN pnpm --filter @web-tools/api run build

EXPOSE 8080
CMD ["pnpm", "--filter", "@web-tools/api", "start"]


