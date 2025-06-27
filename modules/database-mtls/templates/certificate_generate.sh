#!/bin/bash
set -e

echo "🔧 Installing dependencies..."
apt-get update -y
apt-get install -y docker.io postgresql-client openssl unzip jq
systemctl start docker
systemctl enable docker
echo "✅ Docker and dependencies installed."

# Redirect output to a log file
# exec > >(tee -a /home/ubuntu/startup.log) 2>&1

function get_base64_secrets {
	local secret_id=$1
	# OS: Agnostic
	# Description: Pull the Base 64 encoded secrets from AWS Secrets Manager

	/usr/local/bin/aws secretsmanager get-secret-value --secret-id $secret_id | jq --raw-output '.SecretBinary,.SecretString | select(. != null)'
}

echo "[$(date +"%FT%T")] [Terraform Enterprise] Install AWS CLI" 
curl --noproxy '*' "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m | grep -q "arm\|aarch" && echo "aarch64" || echo "x86_64").zip" -o "awscliv2.zip" > /dev/null 2>&1
unzip awscliv2.zip > /dev/null 2>&1
./aws/install > /dev/null 2>&1
rm -f ./awscliv2.zip
rm -rf ./aws

mkdir -p "/home/ubuntu"
CERT_DIR="/home/ubuntu/mtls-certs"
mkdir -p "$CERT_DIR"

export SERVER_KEY=$CERT_DIR/server.key
export CA=$CERT_DIR/ca.crt
export SERVER_CRT=$CERT_DIR/server.crt

# Decode and log the postgres_client_cert
decoded_cert=$(get_base64_secrets ${postgres_client_cert} | base64 -d) > $SERVER_CRT
echo "===== Decoded postgres_client_cert ====="
echo "$decoded_cert"

# Decode and log the postgres_client_key
decoded_key=$(get_base64_secrets ${postgres_client_key} | base64 -d) > $SERVER_KEY
echo "===== Decoded postgres_client_key ====="
echo "$decoded_key"

# Decode and log the postgres_client_ca
decoded_ca=$(get_base64_secrets ${postgres_client_ca} | base64 -d) > $CA
echo "===== Decoded postgres_client_ca ====="
echo "$decoded_ca"

chmod 600 $SERVER_KEY
echo "✅ Certificates generated."

chown ubuntu:ubuntu "$CERT_DIR"/*

echo "✅ Certificates generated in $CERT_DIR"

# Add user to docker group
usermod -aG docker ubuntu

# Cleanup old container if exists
if docker ps -a --format '{{.Names}}' | grep -qw postgres; then
  echo "Removing existing 'postgres' container..."
  docker rm -f postgres
fi

echo "🚀 Starting PostgreSQL container..."
docker run -d \
  --name postgres \
  -p 5432:5432 \
  -e POSTGRES_USER="hashicorp" \
  -e POSTGRES_PASSWORD="postgres_postgres" \
  -e POSTGRES_DB="hashicorp" \
  postgres:16 || { echo "❌ Docker run failed"; exit 1; }

sleep 5

if ! docker ps | grep -qw postgres; then
  echo "❌ Container failed to start."
  docker logs postgres
  exit 1
fi

echo "✅ Postgres container is running."

# Verify certs exist
for f in server.crt server.key ca.crt; do
  [[ -f "$CERT_DIR/$f" ]] || { echo "❌ Missing $f in $CERT_DIR"; exit 1; }
done

# Validate key matches cert
echo "🔍 Verifying key and cert match..."
openssl x509 -noout -modulus -in "$CERT_DIR/server.crt" | openssl md5
openssl rsa  -noout -modulus -in "$CERT_DIR/server.key" | openssl md5

# Wait for container to initialize
echo "⏳ Waiting for PostgreSQL container to start..."
sleep 30

# Copy certs to container
docker exec postgres mkdir -p /var/lib/postgresql/certs
docker cp "$CERT_DIR/server.crt" postgres:/var/lib/postgresql/certs/
docker cp "$CERT_DIR/server.key" postgres:/var/lib/postgresql/certs/
docker cp "$CERT_DIR/ca.crt"     postgres:/var/lib/postgresql/certs/

# Set permissions inside container
docker exec postgres bash -c "chown postgres:postgres /var/lib/postgresql/certs/* && chmod 600 /var/lib/postgresql/certs/server.key"

# Configure PostgreSQL for SSL
docker exec postgres bash -c "echo \"
ssl = on
ssl_cert_file = '/var/lib/postgresql/certs/server.crt'
ssl_key_file = '/var/lib/postgresql/certs/server.key'
ssl_ca_file = '/var/lib/postgresql/certs/ca.crt'
\" >> /var/lib/postgresql/data/postgresql.conf"

# Update pg_hba.conf
docker exec postgres bash -c "echo \"
hostssl all all 0.0.0.0/0 cert clientcert=verify-full
hostssl all all 0.0.0.0/0 md5
\" >> /var/lib/postgresql/data/pg_hba.conf"

docker restart postgres
echo "🔄 Postgres container restarted with SSL config."

# Wait until port is ready
echo "⏳ Waiting for PostgreSQL to listen on port 5432..."
start_time=$(date +%s)
while ! nc -z localhost 5432; do
  sleep 1
  (( $(date +%s) - start_time > 180 )) && echo "❌ Timeout: PostgreSQL not listening." && exit 1
done

# Check PostgreSQL readiness
echo "⏳ Waiting for PostgreSQL to be ready..."
start_time=$(date +%s)
until docker exec postgres pg_isready -U postgres > /dev/null 2>&1; do
  sleep 1
  (( $(date +%s) - start_time > 180 )) && echo "❌ Timeout: PostgreSQL not ready." && docker logs postgres && exit 1
done

echo "✅ PostgreSQL with mTLS is fully up and running."

# Show psql command for user
echo
echo "👉 Connect using:"
