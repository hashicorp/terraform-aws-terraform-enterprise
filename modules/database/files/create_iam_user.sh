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
-- Check and clean up terraform-registry migration state
-- The terraform-registry service uses schema_migrations table to track its own migrations
-- If migrations are in a dirty state, we need to reset them

-- Check if schema_migrations table exists
DO \$\$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'schema_migrations' AND table_schema = 'public') THEN
        -- Delete any dirty migration records that might be causing issues
        DELETE FROM schema_migrations WHERE dirty = true;
        
        -- If we're stuck on version 4, reset to a clean state
        UPDATE schema_migrations SET dirty = false WHERE version = 4 AND dirty = true;
        
        -- Show current migration state
        SELECT 'Current schema_migrations state:' as info;
        SELECT version, dirty FROM schema_migrations ORDER BY version;
        
        RAISE NOTICE 'Cleaned up terraform-registry migration state';
    ELSE
        RAISE NOTICE 'schema_migrations table does not exist yet - will be created by registry service';
    END IF;
END \$\$;
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