#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Integration Tests Environment..."

# Ensure we are in the project root
cd "$(dirname "$0")/.."

# Start Backend and DB
echo "🐳 Starting Backend and Database containers..."
docker compose up -d backend db

# Wait for Backend to be ready
echo "⏳ Waiting for Backend to be ready..."
# Simple wait loop checking the health endpoint
RETRIES=30
until curl -s http://localhost:3000/health > /dev/null; do
    echo "Waiting for backend... ($RETRIES retries left)"
    RETRIES=$((RETRIES-1))
    if [ $RETRIES -le 0 ]; then
        echo "❌ Backend failed to start in time."
        docker compose logs backend
        exit 1
    fi
    sleep 2
done

echo "✅ Backend is UP!"

# Run Flutter Integration Tests
echo "🧪 Running Flutter Integration Tests..."
cd frontend
flutter test test/integration/backend_connection_test.dart

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Integration Tests Passed!"
else
    echo "❌ Integration Tests Failed!"
fi

# Cleanup (Optional - comment out if you want to inspect)
# echo "🧹 Cleaning up..."
# docker compose down

exit $TEST_EXIT_CODE
