#!/bin/bash
set -e

IMAGE_NAME=$1
TAG=$2
CONTAINER_NAME="devops-build-app"

if [ -z "$IMAGE_NAME" ] || [ -z "$TAG" ]; then
  echo "Usage: ./deploy.sh <image_name> <tag>"
  exit 1
fi

docker pull ${IMAGE_NAME}:${TAG}

docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

docker run -d \
  --name ${CONTAINER_NAME} \
  -p 80:80 \
  --restart always \
  ${IMAGE_NAME}:${TAG}

echo "Deployment completed: ${IMAGE_NAME}:${TAG}"
