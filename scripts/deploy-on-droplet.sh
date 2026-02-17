#!/usr/bin/env bash
set -euo pipefail

: "${APP_NAME:?APP_NAME is required}"
: "${IMAGE:?IMAGE is required}"
: "${APP_PORT:?APP_PORT is required}"
: "${CONTAINER_PORT:=3001}"
: "${MONGO_URI:?MONGO_URI is required}"
: "${NODE_ENV:=production}"

CONTAINER_NAME="${APP_NAME}-app"

echo "Deploying ${IMAGE} to ${CONTAINER_NAME}"

docker pull "${IMAGE}"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "${CONTAINER_NAME}"
fi

docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${APP_PORT}:${CONTAINER_PORT}" \
  -e MONGO_URI="${MONGO_URI}" \
  -e NODE_ENV="${NODE_ENV}" \
  "${IMAGE}"

sleep 5
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Deployment successful: ${CONTAINER_NAME} is running"
  docker image prune -f >/dev/null 2>&1 || true
else
  echo "Deployment failed: container is not running"
  docker logs "${CONTAINER_NAME}" || true
  exit 1
fi
