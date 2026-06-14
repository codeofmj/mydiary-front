#!/usr/bin/env bash
set -e

IMAGE_NAME="my-diary-frontend"
CONTAINER_NAME="my-diary-frontend"
BACKEND_HOST="10.1.2.6"

cd "$(dirname "$0")/.."

docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

docker build \
  --build-arg BACKEND_HOST="$BACKEND_HOST" \
  -t "$IMAGE_NAME" .

docker run -d \
  --name "$CONTAINER_NAME" \
  -p 80:80 \
  --restart unless-stopped \
  "$IMAGE_NAME"

echo "Frontend container is running."
