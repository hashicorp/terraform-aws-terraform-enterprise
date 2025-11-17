#!/bin/bash
set -e

# Database connection test script
echo "Testing PostgreSQL database connectivity..."

# Get database endpoint from the RDS instance (you'll need to update this)
DB_HOST="${1:-SET_DB_HOST_HERE}"
DB_PORT="5432"
DB_NAME="hashicorp"
DB_USER="hashicorp"

echo "Attempting to connect to: ${DB_HOST}:${DB_PORT}"
echo "Database: ${DB_NAME}"
echo "User: ${DB_USER}"

# Test basic connectivity
echo "1. Testing network connectivity..."
nc -zv "${DB_HOST}" "${DB_PORT}" || {
    echo "ERROR: Cannot reach database host ${DB_HOST} on port ${DB_PORT}"
    echo "Checking if PostgreSQL client is installed..."
    which psql || echo "PostgreSQL client not found"
    exit 1
}

echo "2. Network connectivity successful!"

# Test PostgreSQL connection
echo "3. Testing PostgreSQL authentication..."
PGPASSWORD="${PGPASSWORD:-password}" psql \
    "host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB_NAME} sslmode=require" \
    -c "SELECT version();" || {
    echo "ERROR: PostgreSQL authentication failed"
    echo "This might be due to:"
    echo "  - Incorrect password"
    echo "  - Database not ready"
    echo "  - Security group rules"
    exit 1
}

echo "4. PostgreSQL connection successful!"

# Test IAM authentication if enabled
if [ "${TEST_IAM_AUTH:-}" = "true" ]; then
    echo "5. Testing IAM authentication..."
    # This would require IAM token generation
    echo "IAM authentication test not implemented in this script"
fi

echo "All tests passed!"