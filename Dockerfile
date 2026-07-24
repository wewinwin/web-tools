dockerfile
FROM node:22-alpine

WORKDIR /app

# 复制依赖文件
COPY package.json pnpm-workspace.yaml ./
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

# 安装依赖
RUN npm install --legacy-peer-deps

# 复制源代码
COPY packages/toolkit/ packages/toolkit/
COPY packages/api/ packages/api/

# 构建
RUN npm --filter @web-tools/toolkit run build && \
    npm --filter @web-tools/api run build

# 启动
CMD ["node", "packages/api/dist/index.js"]
