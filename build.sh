#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Default platform - can be overridden with PLATFORMS env var
PLATFORMS=${PLATFORMS:-"linux/amd64,linux/arm64"}
CACHE_TAG_SUFFIX=${CACHE_TAG_SUFFIX:-"buildcache"}

# 1. Check if a site name is provided
SITE=$1
if [ -z "$SITE" ]; then
  echo "Error: No site name provided."
  echo "Usage: ./build.sh <site-name>"
  echo "Environment variables:"
  echo "  PLATFORMS - target platforms (default: linux/amd64,linux/arm64)"
  echo "  CACHE_TAG_SUFFIX - cache tag suffix (default: buildcache)"
  exit 1
fi

# 2. Ensure buildx is available and enabled
echo "Setting up Docker Buildx..."

# First, check if Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not running. Please start Docker and try again."
  exit 1
fi

# Try to use or create a working builder
BUILDER_NAME="multiarch-builder"

# Remove any broken builders first
docker buildx ls --format "{{.Name}}" | grep -E "^${BUILDER_NAME}" | xargs -r docker buildx rm 2>/dev/null || true

# Create a new builder with docker-container driver for cache support
echo "Creating fresh buildx builder..."
if docker buildx create --name ${BUILDER_NAME} --driver docker-container --use; then
  echo "Successfully created and switched to ${BUILDER_NAME} builder"
else
  echo "Failed to create docker-container builder, using default builder..."
  docker buildx use default
fi

# 3. Build the site with pnpm build from inside the site directory
echo "Building site: ${SITE}"
cd sites/${SITE}
pnpm build
cd ../..

# 4. Define the image tags
IMAGE_TAG="ghcr.io/lekevicius/site-${SITE}"
CACHE_TAG="${IMAGE_TAG}:${CACHE_TAG_SUFFIX}"

# 5. Build and push the multi-arch Docker image with cache
echo "Building multi-arch image for site: ${SITE}"
echo "Platforms: ${PLATFORMS}"
echo "Cache tag: ${CACHE_TAG}"

# Build with appropriate cache strategy based on builder capabilities
CURRENT_BUILDER=$(docker buildx inspect --bootstrap 2>/dev/null | grep "Driver:" | awk '{print $2}')

if [ "$CURRENT_BUILDER" = "docker-container" ]; then
  echo "Using registry cache with docker-container driver..."
  
  # Try registry cache first
  docker buildx build \
    --platform ${PLATFORMS} \
    --cache-from=type=registry,ref=${CACHE_TAG} \
    --cache-to=type=registry,ref=${CACHE_TAG},mode=max \
    --build-arg SITE=${SITE} \
    -t ${IMAGE_TAG} \
    -t ${IMAGE_TAG}:latest \
    --push .
  
  BUILD_EXIT_CODE=$?
  
  if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "Registry cache failed (exit code: $BUILD_EXIT_CODE), trying local cache..."
    docker buildx build \
      --platform ${PLATFORMS} \
      --cache-from=type=local,src=/tmp/.buildx-cache \
      --cache-to=type=local,dest=/tmp/.buildx-cache,mode=max \
      --build-arg SITE=${SITE} \
      -t ${IMAGE_TAG} \
      -t ${IMAGE_TAG}:latest \
      --push .
  fi
else
  echo "Using default builder without advanced caching..."
  docker buildx build \
    --platform ${PLATFORMS} \
    --build-arg SITE=${SITE} \
    -t ${IMAGE_TAG} \
    -t ${IMAGE_TAG}:latest \
    --push .
fi

echo "Successfully built and pushed ${IMAGE_TAG}:latest for platforms: ${PLATFORMS}"

# 6. Verify the multi-arch manifest
echo ""
echo "Verifying multi-arch manifest..."
docker buildx imagetools inspect ${IMAGE_TAG}:latest

echo ""
echo "Image details:"
echo "  Repository: ${IMAGE_TAG}"
echo "  Tags: latest"
echo "  Platforms: ${PLATFORMS}"
echo "  Cache: ${CACHE_TAG}"