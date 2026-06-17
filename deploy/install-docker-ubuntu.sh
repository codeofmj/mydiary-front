#!/usr/bin/env bash
set -e

# Docker와 docker-compose가 이미 설치되어 있으면 종료
if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
  echo "Docker and docker-compose are already installed."
  docker --version
  docker-compose --version
  exit 0
fi

sudo apt update

# Docker 설치
sudo apt install -y docker.io

# Docker Compose 설치
sudo apt install -y docker-compose

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker "$USER"

echo "Docker installation completed."
docker --version

echo "Docker Compose installation completed."
docker-compose --version

echo "If docker permission is denied, log out and log in again."