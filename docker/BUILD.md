## Build locally

From root directoy:

```
  docker buildx build --progress=plain --no-cache -t monkeytype/monkeytype-backend:latest . -f  ./docker/backend/Dockerfile
  docker buildx build --progress=plain --no-cache -t  monkeytype/monkeytype-frontend:latest . -f  ./docker/frontend/Dockerfile
```

## Build and push to your own registry

```
  docker login registry.example.com
  ./docker/build-and-push.sh registry.example.com [tag]
```

Pushes `registry.example.com/monkeytype-backend` and `registry.example.com/monkeytype-frontend` (`:<tag>` and `:latest`, tag defaults to the git short sha). Set `PLATFORMS=linux/amd64,linux/arm64` for multi-arch builds. Redis and MongoDB use the stock Docker Hub images.
