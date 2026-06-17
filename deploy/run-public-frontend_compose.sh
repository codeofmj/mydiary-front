#!/usr/bin/env bash
set -e

BACKEND_HOST="${BACKEND_HOST:-10.1.2.6}"
FRONTEND_SERVER_NAME="$(hostname)"

cd "$(dirname "$0")/.."

export BACKEND_HOST
export FRONTEND_SERVER_NAME

sudo docker-compose down
sudo docker-compose up -d --build

echo "Frontend container is running."
echo "BACKEND_HOST=$BACKEND_HOST"
echo "FRONTEND_SERVER_NAME=$FRONTEND_SERVER_NAME"