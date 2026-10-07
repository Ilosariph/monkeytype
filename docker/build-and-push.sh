#!/usr/bin/env bash
# Builds the monkeytype-frontend and monkeytype-backend images and pushes them
# to the given registry. Redis and MongoDB use the stock images from Docker Hub
# (see docker-compose.yml) and are not built here.
#
# Usage:
#   docker/build-and-push.sh <registry> [tag]
#
# Examples:
#   docker/build-and-push.sh registry.example.com
#   docker/build-and-push.sh registry.example.com/myuser v1.2.3
#
# Images are pushed as <registry>/monkeytype-frontend:<tag> and
# <registry>/monkeytype-backend:<tag>, plus :latest.
# tag defaults to the current git commit (short sha).
#
# Env:
#   PLATFORMS  target platforms (default: linux/amd64), e.g. linux/amd64,linux/arm64
#
# Log in to the registry first: docker login <registry>

set -euo pipefail

if [ $# -lt 1 ]; then
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi

REGISTRY="${1%/}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAG="${2:-$(git -C "$ROOT" rev-parse --short HEAD)}"
PLATFORMS="${PLATFORMS:-linux/amd64}"
SERVER_VERSION="$(git -C "$ROOT" describe --tags --always 2>/dev/null || echo "$TAG")"

# the default docker builder can't build multiple platforms at once
BUILDER_ARGS=()
if [[ "$PLATFORMS" == *,* ]]; then
  if ! docker buildx inspect monkeytype-builder >/dev/null 2>&1; then
    docker buildx create --name monkeytype-builder --driver docker-container >/dev/null
  fi
  BUILDER_ARGS=(--builder monkeytype-builder)
fi

build_and_push() {
  local name="$1"
  shift
  local image="$REGISTRY/$name"

  echo "==> Building and pushing $image:$TAG ($PLATFORMS)"
  docker buildx build \
    ${BUILDER_ARGS[@]+"${BUILDER_ARGS[@]}"} \
    --platform "$PLATFORMS" \
    --file "$ROOT/docker/${name#monkeytype-}/Dockerfile" \
    --tag "$image:$TAG" \
    --tag "$image:latest" \
    --push \
    "$@" \
    "$ROOT"
}

build_and_push monkeytype-backend --build-arg "server_version=$SERVER_VERSION"
build_and_push monkeytype-frontend

echo
echo "Done. Pushed:"
echo "  $REGISTRY/monkeytype-backend:$TAG"
echo "  $REGISTRY/monkeytype-frontend:$TAG"
echo "(both also tagged :latest)"
