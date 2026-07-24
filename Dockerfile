FROM node:22-alpine

# 安装 pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# 设置 CI 环境变量，避免交互问题
ENV CI=true

WORKDIR /app

# 1. 复制根目录的依赖文件
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml tsconfig.json ./

# 2. 复制子包的 package.json (保持目录结构)
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

# 3. 先安装所有依赖（绕过 esbuild 脚本等）
RUN pnpm install --frozen-lockfile --ignore-scripts

# 4. 手动单独构建 esbuild（如果不需要可删掉此行，通常 -ignore-scripts 已经处理了核心问题）
RUN pnpm rebuild esbuild

# 5. 再次运行安装，这会处理剩余的脚本（如 postinstall）
RUN pnpm install --frozen-lockfile

# 6. 复制所有源代码
COPY packages/toolkit/ packages/toolkit/
COPY packages/api/ packages/api/

# 【⚠️核心修改点】：
# 不要单独把 tsconfig.json 复制进去！
# 你在第1步已经复制到 /app/ 目录下了。
# 如果你的子包在根目录执行 build，它们会自动往上找 /app/tsconfig.json。
# 如果你强制复制进去，会覆盖掉原有的代码。

# 7. 构建 toolkit
RUN pnpm --filter @web-tools/toolkit run build

# 8. 构建 api
RUN pnpm --filter @web-tools/api run build

EXPOSE 8080

CMD ["pnpm", "--filter", "@web-tools/api", "start"]
