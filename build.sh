#!/bin/bash

# Build script for Docker images
set -e

echo "🚀 Starting Docker build process..."

# Variables
IMAGE_NAME="reacttestapp"
DEV_TAG="dev"
PROD_TAG="prod"
DOCKER_HUB_USERNAME="your-dockerhub-username"

# Get current git branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $BRANCH"

# Build Docker image
if [ "$BRANCH" = "dev" ]; then
    echo "Building image for dev branch..."
    docker build -t $IMAGE_NAME:$DEV_TAG .
    docker tag $IMAGE_NAME:$DEV_TAG $DOCKER_HUB_USERNAME/dev:$DEV_TAG
    echo "✅ Dev image built successfully!"
elif [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
    echo "Building image for production branch..."
    docker build -t $IMAGE_NAME:$PROD_TAG .
    docker tag $IMAGE_NAME:$PROD_TAG $DOCKER_HUB_USERNAME/prod:$PROD_TAG
    echo "✅ Production image built successfully!"
else
    echo "Building image for feature branch..."
    docker build -t $IMAGE_NAME:latest .
    echo "✅ Feature image built successfully!"
fi

echo "Build process completed!"