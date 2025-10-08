#!/bin/bash
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
source ~/.bashrc
pyenv activate open-webui


# Current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to customization.json 
CUSTOMIZATION_JSON="$SCRIPT_DIR/../customization.json"

# Extract backend_port using jq with fallback
BACKEND_PORT=$(jq -r '.backend.port // 8080' "$CUSTOMIZATION_JSON" 2>/dev/null)

# Fallback to env PORT or default
PORT="${PORT:-$BACKEND_PORT}"

# Final fallback if everything fails
PORT="${PORT:-8080}"
echo "JSON File at: $CUSTOMIZATION_JSON"
echo "Starting server on port: $PORT"

uvicorn open_webui.main:app --port "$PORT" --host 0.0.0.0 --forwarded-allow-ips '*' --reload
