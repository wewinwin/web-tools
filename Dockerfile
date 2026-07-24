FROM node:22-alpine

WORKDIR /app

COPY package.json pnpm-workspace.yaml ./
COPY packages/toolkit/package.json packages/toolkit/
COPY packages/api/package.json packages/api/

RUN npm install --legacy-peer-deps

COPY packages/toolkit/ packages/toolkit/
COPY packages/api/ packages/api/

RUN npm --filter @web-tools/toolkit run build && \
    npm --filter @web-tools/api run build

EXPOSE 8080

CMD ["npm", "start"]
