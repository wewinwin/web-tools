FROM node:22-alpine

RUN corepack enable && corepack prepare pnpm@latest --activate
ENV CI=true
WORKDIR /app

# 1. 复制依赖清单
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.json ./
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

# 2. 安装依赖
RUN pnpm install --frozen-lockfile --ignore-scripts
RUN pnpm install --frozen-lockfile

# 3. 复制所有源代码
COPY packages/toolkit/ packages/toolkit/
COPY packages/api/ packages/api/

# 4. 构建（pnpm 会自动跑到子目录去执行我们刚才改好的命令）
RUN pnpm --filter @web-tools/toolkit run build
RUN pnpm --filter @web-tools/api run build

EXPOSE 8080
# 修改后的启动，依赖环境变量在 Railway 控制台配置
CMD ["pnpm", "--filter", "@web-tools/api", "start"]
