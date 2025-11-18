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

# Clean up any dirty migration states for terraform-registry
echo "Cleaning up terraform-registry migration state..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_NAME" <<EOF
-- Clean up terraform-registry migration state with comprehensive approach
-- The terraform-registry service likely uses golang-migrate which tracks state in schema_migrations

-- Show current state for debugging
SELECT 'Before cleanup - checking for schema_migrations table:' as status;
SELECT table_name FROM information_schema.tables WHERE table_name = 'schema_migrations';

-- Remove any existing migration state completely
DROP TABLE IF EXISTS schema_migrations CASCADE;
DROP TABLE IF EXISTS schema_version CASCADE;
DROP TABLE IF EXISTS gorp_migrations CASCADE;
DROP TABLE IF EXISTS migrations CASCADE;

-- Also check for any locks that might be held
DELETE FROM pg_locks WHERE locktype = 'advisory' AND classid = 1410924490;

-- Recreate clean schema_migrations table
CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL DEFAULT false,
    PRIMARY KEY (version)
);

-- Grant permissions to our IAM user
GRANT ALL PRIVILEGES ON schema_migrations TO "${IAM_USERNAME}";

-- Show final state
SELECT 'After cleanup - migration table ready:' as status;
\\d schema_migrations;
EOF

# Create IAM user in PostgreSQL
echo "Creating IAM user: ${IAM_USERNAME}"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_NAME" <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${IAM_USERNAME}') THEN
        CREATE USER "${IAM_USERNAME}" WITH LOGIN CREATEDB CREATEROLE;
        GRANT rds_iam TO "${IAM_USERNAME}";
        GRANT CONNECT ON DATABASE "${DB_NAME}" TO "${IAM_USERNAME}";
        GRANT CREATE ON DATABASE "${DB_NAME}" TO "${IAM_USERNAME}";
        GRANT USAGE ON SCHEMA public TO "${IAM_USERNAME}";
        GRANT CREATE ON SCHEMA public TO "${IAM_USERNAME}";
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${IAM_USERNAME}";
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${IAM_USERNAME}";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "${IAM_USERNAME}";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "${IAM_USERNAME}";
        
        -- Grant access to use installed extensions
        GRANT USAGE ON TYPE citext TO "${IAM_USERNAME}";
        GRANT USAGE ON TYPE hstore TO "${IAM_USERNAME}";
        GRANT USAGE ON TYPE uuid TO "${IAM_USERNAME}";
        
        RAISE NOTICE 'Successfully created IAM user: ${IAM_USERNAME}';
    ELSE
        RAISE NOTICE 'IAM user already exists: ${IAM_USERNAME}';
        
        -- Ensure existing user has required permissions
        GRANT CONNECT ON DATABASE "${DB_NAME}" TO "${IAM_USERNAME}";
        GRANT CREATE ON DATABASE "${DB_NAME}" TO "${IAM_USERNAME}";
        GRANT USAGE ON SCHEMA public TO "${IAM_USERNAME}";
        GRANT CREATE ON SCHEMA public TO "${IAM_USERNAME}";
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${IAM_USERNAME}";
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${IAM_USERNAME}";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "${IAM_USERNAME}";
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "${IAM_USERNAME}";
        
        -- Grant access to use installed extensions
        GRANT USAGE ON TYPE citext TO "${IAM_USERNAME}";
        GRANT USAGE ON TYPE hstore TO "${IAM_USERNAME}";
        GRANT USAGE ON TYPE uuid TO "${IAM_USERNAME}";
        
        RAISE NOTICE 'Updated permissions for IAM user: ${IAM_USERNAME}';
    END IF;
END \$\$;
EOF

echo "IAM user setup completed successfully!"