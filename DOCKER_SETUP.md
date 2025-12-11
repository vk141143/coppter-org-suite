# Docker Setup for LiftAway Waste Management App

## Prerequisites
- Docker installed on your system
- Docker Compose (optional, for easier management)

## Build Docker Image

```bash
docker build -t liftaway-waste-management .
```

## Run Container

### Using Docker
```bash
docker run -d -p 8080:80 --name liftaway-app liftaway-waste-management
```

### Using Docker Compose
```bash
docker-compose up -d
```

## Access Application
Open your browser and navigate to:
```
http://localhost:8080
```

## Stop Container

### Using Docker
```bash
docker stop liftaway-app
docker rm liftaway-app
```

### Using Docker Compose
```bash
docker-compose down
```

## View Logs
```bash
docker logs liftaway-app
```

## Rebuild After Changes
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Image Details
- Base Image: debian:latest (build), nginx:alpine (serve)
- Flutter Channel: stable
- Web Renderer: HTML
- Port: 80 (mapped to 8080 on host)
