#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

set -euxo pipefail

apt-get update -y && apt-get install -y postgresql-client

# Set environment variables for database connection
export PGPASSWORD="${DB_PASSWORD}"

echo "Connecting to PostgreSQL database..."
echo "Host: ${DB_HOST}"
echo "Port: ${DB_PORT}"
echo "Username: ${DB_USERNAME}"
echo "Database: ${DB_NAME}"

# Wait for database to be ready
echo "Waiting for database to be available..."
for i in {1..30}; do
    if psql "host=${DB_HOST} port=${DB_PORT} user=${DB_USERNAME} dbname=${DB_NAME} sslmode=require" -c "SELECT 1;" >/dev/null 2>&1; then
        echo "Database is ready!"
        break
    else
        echo "Attempt $i/30: Database not ready, waiting 10 seconds..."
        sleep 10
    fi
    
    if [ $i -eq 30 ]; then
        echo "ERROR: Database not available after 30 attempts"
        exit 1
    fi
done

# Create IAM user in PostgreSQL
echo "Creating IAM user: ${IAM_USERNAME}"
psql "host=${DB_HOST} port=${DB_PORT} user=${DB_USERNAME} dbname=${DB_NAME} sslmode=require" -c "
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${IAM_USERNAME}') THEN
        CREATE USER \"${IAM_USERNAME}\" WITH LOGIN;
        GRANT rds_iam TO \"${IAM_USERNAME}\";
        GRANT CONNECT ON DATABASE \"${DB_NAME}\" TO \"${IAM_USERNAME}\";
        GRANT USAGE ON SCHEMA public TO \"${IAM_USERNAME}\";
        GRANT CREATE ON SCHEMA public TO \"${IAM_USERNAME}\";
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"${IAM_USERNAME}\";
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"${IAM_USERNAME}\";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"${IAM_USERNAME}\";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"${IAM_USERNAME}\";
        RAISE NOTICE 'Successfully created IAM user: ${IAM_USERNAME}';
    ELSE
        RAISE NOTICE 'IAM user already exists: ${IAM_USERNAME}';
    END IF;
END \$\$;
"

# Verify user creation
echo "Verifying IAM user creation..."
psql "host=${DB_HOST} port=${DB_PORT} user=${DB_USERNAME} dbname=${DB_NAME} sslmode=require" -c "
SELECT 
    usename as username,
    usesuper as is_superuser,
    usecreatedb as can_create_db
FROM pg_user 
WHERE usename = '${IAM_USERNAME}';
"

echo "IAM user setup completed successfully!"