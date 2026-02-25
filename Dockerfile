# ---------- Base ----------
FROM node:20-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV NODE_ENV=production

# ---------- Build Stage ----------
FROM base AS build
WORKDIR /app

COPY . .

RUN corepack enable
RUN apk add --no-cache python3 make g++

RUN pnpm install --frozen-lockfile
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

# ---------- Runtime Stage ----------
FROM node:20-alpine AS api

WORKDIR /app
ENV NODE_ENV=production

# Install runtime deps only (smaller image)
RUN apk add --no-cache ffmpeg

COPY --from=build --chown=node:node /prod/api /app

USER node

EXPOSE 8080

CMD ["node", "src/cobalt"]
