# syntax=docker/dockerfile:1

######## Build frontend ########
FROM node:22-alpine3.20 AS build

WORKDIR /app

# Install build deps
RUN apk add --no-cache git

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
ENV APP_BUILD_HASH=api-only
RUN npm run build


######## Backend ########
FROM python:3.11-slim-bookworm AS backend

WORKDIR /app/backend

# Environment configuration for API-only mode
ENV ENV=prod \
    PORT=7042\
    OPENAI_API_BASE_URL="https://api.openai.com/v1" \
    OPENAI_API_KEY="" \
    WEBUI_SECRET_KEY="" \
    SCARF_NO_ANALYTICS=true \
    DO_NOT_TRACK=true \
    ANONYMIZED_TELEMETRY=false \
    RAG_EMBEDDING_MODEL="" \
    RAG_RERANKING_MODEL="" \
    HF_HOME="/app/backend/data/cache/embedding/models" \
    TIKTOKEN_ENCODING_NAME="cl100k_base" \
    TIKTOKEN_CACHE_DIR="/app/backend/data/cache/tiktoken"

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git build-essential pandoc curl jq && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY ./backend/requirements.txt ./requirements.txt
RUN pip3 install --no-cache-dir uv && \
    uv pip install --system -r requirements.txt --no-cache-dir

# Copy built frontend files
COPY --from=build /app/build /app/build
COPY --from=build /app/CHANGELOG.md /app/CHANGELOG.md
COPY --from=build /app/package.json /app/package.json

# Copy backend code
COPY ./backend .
# Copy customization.json
COPY customization.json /app/customization.json

EXPOSE 7042

HEALTHCHECK CMD curl --silent --fail http://localhost:${PORT:-7042}/health || exit 1

CMD ["bash", "start.sh"]
