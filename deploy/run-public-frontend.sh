#!/usr/bin/env bash
set -e

IMAGE_NAME="my-diary-frontend"
CONTAINER_NAME="my-diary-frontend"
BACKEND_HOST="${BACKEND_HOST:-10.1.2.6}"
FRONTEND_SERVER_NAME="$(hostname)"

cd "$(dirname "$0")/.."

docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

docker build \
  -t "$IMAGE_NAME" .

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 80:80 \
  -e BACKEND_HOST="$BACKEND_HOST" \
  -e FRONTEND_SERVER_NAME="$FRONTEND_SERVER_NAME" \
  --restart unless-stopped \
  "$IMAGE_NAME"

echo "Frontend container is running."
echo "BACKEND_HOST=$BACKEND_HOST"
echo "FRONTEND_SERVER_NAME=$FRONTEND_SERVER_NAME"
