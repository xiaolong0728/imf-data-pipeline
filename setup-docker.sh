#!/bin/bash

echo "Setting up IMF data pipeline with Docker..."

# Create Docker network
echo "Creating Docker network..."
docker network create imf-network

# Stop and remove existing containers if they exist
echo "Cleaning up existing containers..."
docker stop postgres-imf metabase 2>/dev/null || true
docker rm postgres-imf metabase 2>/dev/null || true

# Run PostgreSQL
echo "Starting PostgreSQL container..."
docker run -d \
  --name postgres-imf \
  --network imf-network \
  -e POSTGRES_DB=imf_data \
  -e POSTGRES_USER=xiaolong \
  -e POSTGRES_PASSWORD=xiaolong \
  -p 5432:5432 \
  postgres:14

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Run Metabase
echo "Starting Metabase container..."
docker run -d \
  --name metabase \
  --network imf-network \
  -p 3000:3000 \
  metabase/metabase

echo "Setup complete!"
echo "Metabase will be available at: http://localhost:3000"
echo "PostgreSQL is accessible at: localhost:5432"
echo ""
echo "In Metabase, use these connection settings:"
echo "Host: postgres-imf"
echo "Port: 5432"
echo "Database: imf_data"
echo "Username: xiaolong"
echo "Password: xiaolong" 