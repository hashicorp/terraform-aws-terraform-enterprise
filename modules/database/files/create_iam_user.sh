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

# Aggressive cleanup for terraform-registry migration state
echo "Performing aggressive terraform-registry migration state cleanup..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_NAME" <<EOF
-- Force terminate any active connections that might hold locks
SELECT 'Terminating active database connections...' as status;
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = current_database() 
  AND pid <> pg_backend_pid() 
  AND usename != 'rdsadmin';

-- Clear all advisory locks forcefully
SELECT 'Clearing all advisory locks...' as status;
SELECT pg_advisory_unlock_all();

-- Debug: Show current migration state
SELECT 'DEBUG: Checking existing migration tables...' as status;
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_name IN ('schema_migrations', 'schema_version', 'gorp_migrations', 'migrations');

-- Show current content if schema_migrations exists
DO \$\$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'schema_migrations') THEN
        RAISE NOTICE 'Current schema_migrations content:';
        PERFORM version, dirty FROM schema_migrations ORDER BY version;
    END IF;
END \$\$;

-- Drop all possible migration tracking tables with CASCADE
DROP TABLE IF EXISTS schema_migrations CASCADE;
DROP TABLE IF EXISTS schema_version CASCADE; 
DROP TABLE IF EXISTS gorp_migrations CASCADE;
DROP TABLE IF EXISTS migrations CASCADE;

-- Drop and recreate terraform_registry schema if it exists
DROP SCHEMA IF EXISTS terraform_registry CASCADE;
CREATE SCHEMA IF NOT EXISTS terraform_registry;
GRANT ALL PRIVILEGES ON SCHEMA terraform_registry TO "${IAM_USERNAME}";

-- Remove any stale locks specifically for golang-migrate
-- golang-migrate uses advisory lock with classid 1410924490
SELECT 'Clearing golang-migrate specific locks...' as status;
SELECT pg_advisory_unlock(classid, objid) 
FROM pg_locks 
WHERE locktype = 'advisory' AND classid = 1410924490;

-- Create completely fresh schema_migrations table with exact golang-migrate format
SELECT 'Creating fresh schema_migrations table...' as status;
CREATE TABLE schema_migrations (
    version bigint NOT NULL PRIMARY KEY,
    dirty boolean NOT NULL DEFAULT false
);

-- Grant comprehensive permissions to IAM user
GRANT ALL PRIVILEGES ON schema_migrations TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${IAM_USERNAME}";
GRANT USAGE ON SCHEMA terraform_registry TO "${IAM_USERNAME}";
GRANT CREATE ON SCHEMA terraform_registry TO "${IAM_USERNAME}";

-- Reset any database-level configuration that might affect migrations
SELECT 'Resetting database configuration...' as status;
SELECT pg_reload_conf();

-- Final verification
SELECT 'FINAL STATE: Migration table structure:' as status;
\\d schema_migrations;

SELECT 'FINAL STATE: No existing migration records:' as status;
SELECT COUNT(*) as migration_count FROM schema_migrations;

SELECT 'FINAL STATE: Available schemas:' as status;
SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast');
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