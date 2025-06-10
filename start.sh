#!/usr/bin/env bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Docker is installed
if ! command_exists docker; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Set environment variables
export DOCKER_DB_NAME=truck_signs_db
export DOCKER_DB_USER=postgres
export DOCKER_DB_PASSWORD=postgres
export DOCKER_DB_HOST=truck_signs_db
export DJANGO_SUPERUSER_USERNAME=admin
export DJANGO_SUPERUSER_EMAIL=admin@example.com
export DJANGO_SUPERUSER_PASSWORD=admin

# Function to check if PostgreSQL is ready
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    for i in {1..30}; do
        if docker exec $DOCKER_DB_HOST pg_isready -h localhost -U $DOCKER_DB_USER -d $DOCKER_DB_NAME > /dev/null 2>&1; then
            echo "PostgreSQL is ready!"
            return 0
        fi
        echo "Waiting for PostgreSQL... attempt $i of 30"
        sleep 2
    done
    echo "Error: PostgreSQL did not become ready in time"
    return 1
}

# Create a named volume for PostgreSQL data
echo "Creating PostgreSQL volume..."
docker volume create truck_signs_postgres_data

# Clean up existing containers
echo "Cleaning up existing containers..."
docker stop truck-signs-web $DOCKER_DB_HOST 2>/dev/null || true
docker rm truck-signs-web $DOCKER_DB_HOST 2>/dev/null || true

# Remove existing network
echo "Removing existing network..."
docker network rm truck-signs-network 2>/dev/null || true

# Create network
echo "Creating network..."
docker network create truck-signs-network

# Build the web image
echo "Building web image..."
docker build -t truck-signs-api .

# Start the database container with the named volume
echo "Starting database container..."
docker run -d \
    --name $DOCKER_DB_HOST \
    --network truck-signs-network \
    -e POSTGRES_DB=$DOCKER_DB_NAME \
    -e POSTGRES_USER=$DOCKER_DB_USER \
    -e POSTGRES_PASSWORD=$DOCKER_DB_PASSWORD \
    -v truck_signs_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:13

# Wait for PostgreSQL to be ready
wait_for_postgres
if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to PostgreSQL"
    exit 1
fi

# Start the web container
echo "Starting web container..."
docker run -d \
    --name truck-signs-web \
    --network truck-signs-network \
    -e DOCKER_DB_NAME=$DOCKER_DB_NAME \
    -e DOCKER_DB_USER=$DOCKER_DB_USER \
    -e DOCKER_DB_PASSWORD=$DOCKER_DB_PASSWORD \
    -e DOCKER_DB_HOST=$DOCKER_DB_HOST \
    -e DJANGO_SUPERUSER_USERNAME=$DJANGO_SUPERUSER_USERNAME \
    -e DJANGO_SUPERUSER_EMAIL=$DJANGO_SUPERUSER_EMAIL \
    -e DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD \
    -p 8020:8020 \
    truck-signs-api

# Check container status
echo "Checking container status..."
docker ps

# Show logs
echo "Showing logs..."
docker logs -f truck-signs-web 