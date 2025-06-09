#!/bin/bash

# Deploy script for Docker containers
set -e

echo "🚀 Starting deployment process..."

# Variables
CONTAINER_NAME="reacttestapp-container"
IMAGE_NAME="react-app"
DOCKER_HUB_USERNAME="naveenkumar492"

# Get current git branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $BRANCH"

# Stop and remove existing container
echo "Stopping existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Deploy based on branch
if [ "$BRANCH" = "dev" ]; then
    echo "Deploying dev version..."
    docker run -d --name $CONTAINER_NAME -p 80:80 $DOCKER_HUB_USERNAME/dev:dev
elif [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
    echo "Deploying production version..."
    docker run -d --name $CONTAINER_NAME -p 80:80 $DOCKER_HUB_USERNAME/prod:prod
else
    echo "Deploying latest version..."
    docker run -d --name $CONTAINER_NAME -p 80:80 reacttestapp:latest
fi

# Check if container is running
sleep 5
if docker ps | grep -q $CONTAINER_NAME; then
    echo "✅ Container deployed successfully!"
    echo "🌐 Application is running on http://localhost"
else
    echo "❌ Deployment failed!"
    docker logs $CONTAINER_NAME
    exit 1
fi

echo "🎉 Deployment completed!"