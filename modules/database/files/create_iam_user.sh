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

# Install required PostgreSQL extensions
echo "Installing required PostgreSQL extensions..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_NAME" <<EOF
-- Create required extensions for Terraform Enterprise
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS citext;

-- Verify extensions are installed
SELECT extname FROM pg_extension WHERE extname IN ('hstore', 'uuid-ossp', 'citext');
EOF

# Create IAM user and immediately create their own database
echo "Creating IAM user: ${IAM_USERNAME}"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_NAME" <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${IAM_USERNAME}') THEN
        CREATE USER "${IAM_USERNAME}" WITH LOGIN CREATEDB CREATEROLE;
        GRANT rds_iam TO "${IAM_USERNAME}";
        RAISE NOTICE 'Successfully created IAM user: ${IAM_USERNAME}';
    ELSE
        RAISE NOTICE 'IAM user already exists: ${IAM_USERNAME}';
    END IF;
END \$\$;

-- Immediately create a separate database for the IAM user with IAM user as owner
CREATE DATABASE "${IAM_USERNAME}_db" WITH OWNER = "${IAM_USERNAME}";
EOF

# Install required extensions in the IAM user's database
echo "Setting up extensions in IAM database: ${IAM_USERNAME}_db"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "${IAM_USERNAME}_db" <<EOF
-- Install required extensions
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS citext;

-- Grant full privileges to the IAM user on their own database
GRANT ALL PRIVILEGES ON DATABASE "${IAM_USERNAME}_db" TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON SCHEMA public TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${IAM_USERNAME}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "${IAM_USERNAME}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "${IAM_USERNAME}";
EOF

echo "IAM user setup completed successfully with dedicated database!"
echo "Database name: ${IAM_USERNAME}_db"