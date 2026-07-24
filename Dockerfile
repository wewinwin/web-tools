# --- Builder stage ---
FROM node:22-alpine AS builder

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy workspace root files
COPY package.json pnpm-workspace.yaml tsconfig.json ./

# Copy package manifests for all packages
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

RUN npm install --legacy-peer-deps

# Copy source code
COPY packages/toolkit/tsconfig.json packages/toolkit/
COPY packages/toolkit/src/ packages/toolkit/src/
COPY packages/api/tsconfig.json packages/api/
COPY packages/api/src/ packages/api/src/

# Build toolkit first, then api
RUN npm --filter @web-tools/toolkit run build && \
    npm --filter @web-tools/api run build

# --- Production stage ---
FROM node:22-alpine

RUN npm install -g npm@latest

WORKDIR /app

COPY package.json pnpm-workspace.yaml ./
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

RUN npm install --omit=dev --legacy-peer-deps

COPY --from=builder /app/packages/toolkit/dist packages/toolkit/dist
COPY --from=builder /app/packages/api/dist packages/api/dist

CMD ["node", "packages/api/dist/index.js"]
