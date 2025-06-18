#!/bin/bash
set -e

# Install Docker if not already installed
apt-get update -y
apt-get install -y docker.io postgresql-client openssl

systemctl start docker
systemctl enable docker

echo "installed openssl"

# Set working directory for certificates
# CERT_DIR="/certs"
# mkdir -p "$CERT_DIR"
# cd "$CERT_DIR"

# echo "made certs directory"

# Generate CA certificate
openssl req -new -x509 -days 365 -nodes \
  -subj "/CN=Test CA" \
  -keyout ca.key -out ca.crt

# Generate server certificate
openssl req -new -nodes \
  -subj "/CN=postgres" \
  -keyout server.key -out server.csr

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt -days 365

# Generate client certificate
openssl req -new -nodes \
  -subj "/CN=pg-client" \
  -keyout client.key -out client.csr

openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out client.crt -days 365


echo "certificates generated"
# Secure key files
chmod 600 server.key client.key

# Log certs
echo "===== CA CERT ====="
cat ca.crt
echo "===== CLIENT CERT ====="
cat client.crt
echo "===== CLIENT KEY ====="
cat client.key

# Ensure target directory exists
mkdir -p /home/ubuntu/mtls-certs

# Copy certs to home directory
cp server.crt server.key ca.crt /home/ubuntu/mtls-certs/
chown ubuntu:ubuntu /home/ubuntu/mtls-certs/*

echo "Certificates generated and copied successfully."

# Add 'ubuntu' to 'docker' group (only applies after re-login)
usermod -aG docker ubuntu

# Create certs directory and ensure ownership
CERT_DIR="/home/ubuntu/mtls-certs"

# Remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -qw postgres; then
  echo "Removing existing 'postgres' container..."
  docker rm -f postgres
fi

# Start PostgreSQL container
docker run -d \
  --name postgres \
  -p 5432:5432 \
  -e POSTGRES_USER="hashicorp" \
  -e POSTGRES_PASSWORD="postgres_postgres" \
  -e POSTGRES_DB="hashicorp" \
  postgres:16 || {
    echo "❌ Docker run failed"
    exit 1
  }

echo "Checking if container is still running..."
docker ps --filter name=postgres

# Print logs to debug crash
if ! docker ps | grep -qw postgres; then
  echo "Container crashed. Showing logs:"
  docker logs postgres
  exit 1
fi

if [[ ! -f "$CERT_DIR/server.crt" || ! -f "$CERT_DIR/server.key" || ! -f "$CERT_DIR/ca.crt" ]]; then
  echo "❌ Certificate files missing in $CERT_DIR"
  ls -l "$CERT_DIR"
  exit 1
fi
echo "Match key"

openssl x509 -noout -modulus -in $CERT_DIR/server.crt | openssl md5
openssl rsa -noout -modulus -in $CERT_DIR/server.key | openssl md5

echo "Match key"


# Wait for container to fully initialize
echo "Waiting for Postgres container to start..."
sleep 30


# Create certs directory inside the container
docker exec postgres mkdir -p /var/lib/postgresql/certs
echo "Making directory /var/lib/postgresql/certs inside the container complete"

# Copy certificate files from host to container
docker cp "$CERT_DIR/server.crt" postgres:/var/lib/postgresql/certs/server.crt
docker cp "$CERT_DIR/server.key" postgres:/var/lib/postgresql/certs/server.key
docker cp "$CERT_DIR/ca.crt" postgres:/var/lib/postgresql/certs/ca.crt
echo "copying certs to /var/lib/postgresql/certs inside the container complete"

# Set ownership inside the container
docker exec postgres bash -c "chown postgres:postgres /var/lib/postgresql/certs/*.crt /var/lib/postgresql/certs/*.key"
echo "Setting ownership of certs inside the container complete"
# Restrict private key permissions
docker exec postgres bash -c "chmod 600 /var/lib/postgresql/certs/server.key"
echo "Restricting private key permissions complete"
# Update Postgres config with SSL settings
docker exec postgres bash -c "echo \"ssl = on
ssl_cert_file = '/var/lib/postgresql/certs/server.crt'
ssl_key_file = '/var/lib/postgresql/certs/server.key'
ssl_ca_file = '/var/lib/postgresql/certs/ca.crt'\" >> /var/lib/postgresql/data/postgresql.conf"
echo "Updating Postgres config with SSL settings complete"

# Add client authentication rule
docker exec postgres bash -c "echo \"hostssl all all 0.0.0.0/0 cert clientcert=verify-full\" >> /var/lib/postgresql/data/pg_hba.conf"
echo "Adding client authentication rule complete"
# Then allow password-based authentication over SSL
docker exec postgres bash -c "echo 'hostssl all all 0.0.0.0/0 md5' >> /var/lib/postgresql/data/pg_hba.conf"
# Restart the container to apply changes
docker restart postgres
echo "PostgreSQL container restarted to apply SSL settings."

# Wait for PostgreSQL to start on port 5432 (max 180 seconds)
echo "🔄 Waiting for PostgreSQL to start on port 5432..."
start_time=$(date +%s)
while ! nc -z localhost 5432; do
  sleep 1
  current_time=$(date +%s)
  if (( current_time - start_time > 180 )); then
    echo "❌ Timeout: PostgreSQL did not start listening on port 5432 within 3 minutes."
    exit 1
  fi
done
echo "✅ Port 5432 is open."

# Wait for PostgreSQL to report ready (max 180 seconds)
echo "🔄 Waiting for PostgreSQL to become ready..."
start_time=$(date +%s)
until docker exec postgres pg_isready -U postgres > /dev/null 2>&1; do
  sleep 1
  current_time=$(date +%s)
  if (( current_time - start_time > 180 )); then
    echo "❌ Timeout: PostgreSQL did not become ready within 3 minutes."
    docker logs postgres
    exit 1
  fi
done
echo "✅ PostgreSQL is ready."

echo "PostgreSQL is fully ready."

sleep 50

# psql "host=localhost port=5432 user=postgres password=postgres_postgres dbname=postgres"

echo "PostgreSQL with mTLS is up and running."
