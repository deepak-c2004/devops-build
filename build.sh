#!/bin/bash
set -e

IMAGE_NAME=$1
TAG=$2

if [ -z "$IMAGE_NAME" ] || [ -z "$TAG" ]; then
  echo "Usage: ./build.sh devops-build-app"
  exit 1
fi

docker build -t ${IMAGE_NAME}:${TAG} .
docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest

echo "Build completed for ${IMAGE_NAME}:${TAG}"

