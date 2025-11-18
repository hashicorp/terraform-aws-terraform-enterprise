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

-- Verify extensions are installed and available
SELECT extname, nspname 
FROM pg_extension e 
JOIN pg_namespace n ON e.extnamespace = n.oid 
WHERE extname IN ('hstore', 'uuid-ossp', 'citext');

-- Ensure extensions are accessible from all schemas
-- Grant USAGE on extension types to public to ensure global availability
GRANT USAGE ON TYPE citext TO public;
GRANT USAGE ON TYPE hstore TO public;
GRANT USAGE ON TYPE uuid TO public;

-- Verify types are accessible
SELECT typname, typnamespace, n.nspname as schema_name
FROM pg_type t
JOIN pg_namespace n ON t.typnamespace = n.oid
WHERE typname IN ('citext', 'hstore', 'uuid');
EOF

# DEFINITIVE terraform-registry migration state reset
echo "Performing definitive terraform-registry migration state reset..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_NAME" <<EOF
-- Force terminate ALL connections except our own to ensure clean state
SELECT 'Terminating all database connections...' as status;
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = current_database() 
  AND pid <> pg_backend_pid();

-- Wait for connections to fully close
SELECT pg_sleep(3);

-- Clear ALL advisory locks including golang-migrate locks
SELECT 'Clearing all advisory locks...' as status;
SELECT pg_advisory_unlock_all();

-- Force unlock specific golang-migrate locks (classid 1410924490)
-- This is the key issue - golang-migrate holds locks that persist
SELECT pg_advisory_unlock(1410924490, hashtext(current_database()::text));

-- Delete any stale lock records
DELETE FROM pg_locks WHERE locktype = 'advisory';

-- NUCLEAR OPTION: Drop and recreate the entire database schema
-- This ensures absolutely clean state
SELECT 'Dropping public schema...' as status;
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO "${IAM_USERNAME}";
GRANT ALL ON SCHEMA public TO public;

-- Recreate all extensions in the fresh public schema
CREATE EXTENSION citext SCHEMA public;
CREATE EXTENSION hstore SCHEMA public;
CREATE EXTENSION "uuid-ossp" SCHEMA public;

-- Grant usage on extension types
GRANT USAGE ON TYPE citext TO "${IAM_USERNAME}";
GRANT USAGE ON TYPE hstore TO "${IAM_USERNAME}";  
GRANT USAGE ON TYPE uuid TO "${IAM_USERNAME}";
GRANT USAGE ON TYPE citext TO public;
GRANT USAGE ON TYPE hstore TO public;
GRANT USAGE ON TYPE uuid TO public;

-- Create terraform_registry schema fresh
CREATE SCHEMA terraform_registry;
GRANT ALL PRIVILEGES ON SCHEMA terraform_registry TO "${IAM_USERNAME}";

-- Create a completely fresh schema_migrations table with NO existing data
-- This is critical - golang-migrate checks this table for dirty state
CREATE TABLE schema_migrations (
    version bigint NOT NULL PRIMARY KEY,
    dirty boolean NOT NULL DEFAULT false
);

-- Grant full permissions
GRANT ALL PRIVILEGES ON schema_migrations TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA terraform_registry TO "${IAM_USERNAME}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA terraform_registry TO "${IAM_USERNAME}";

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "${IAM_USERNAME}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "${IAM_USERNAME}";
ALTER DEFAULT PRIVILEGES IN SCHEMA terraform_registry GRANT ALL ON TABLES TO "${IAM_USERNAME}";
ALTER DEFAULT PRIVILEGES IN SCHEMA terraform_registry GRANT ALL ON SEQUENCES TO "${IAM_USERNAME}";

-- Set search path for IAM user
ALTER USER "${IAM_USERNAME}" SET search_path = public, terraform_registry;

-- Force PostgreSQL to reload configuration
SELECT pg_reload_conf();

-- Final verification
SELECT 'FINAL STATE: Clean migration table:' as status;
SELECT COUNT(*) as migration_count FROM schema_migrations;

SELECT 'FINAL STATE: Available extensions:' as status;
SELECT extname FROM pg_extension WHERE extname IN ('hstore', 'uuid-ossp', 'citext');

SELECT 'FINAL STATE: Advisory locks cleared:' as status;
SELECT COUNT(*) as active_advisory_locks FROM pg_locks WHERE locktype = 'advisory';

SELECT 'SUCCESS: Database reset complete for terraform-registry-api' as status;
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