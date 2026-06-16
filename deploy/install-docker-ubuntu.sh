#!/usr/bin/env bash
set -e

if command -v docker >/dev/null 2>&1; then
  echo "Docker is already installed."
  docker --version

  if docker compose version >/dev/null 2>&1; then
    docker compose version
  else
    echo "Docker Compose plugin is not installed."
  fi
  
  exit 0
fi

sudo apt update
sudo apt install -y docker.io

# Docker Compose plugin 설치 시도
sudo apt install -y docker-compose-plugin || true

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker "$USER"

if docker compose version >/dev/null 2>&1; then
  docker compose version
else
  echo "Docker Compose plugin was not installed."
  echo "If needed, install Docker using the official Docker repository."
fi

docker --version
