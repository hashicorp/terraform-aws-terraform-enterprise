#!/bin/bash
set -e

# Optional: Uncomment to log to file
# exec > >(tee -a /home/ubuntu/startup.log) 2>&1

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
	/usr/local/bin/aws secretsmanager get-secret-value --secret-id "$secret_id" | jq --raw-output '.SecretBinary,.SecretString | select(. != null)'
}

echo "[$(date +"%FT%T")] [Terraform Enterprise] Installing AWS CLI..." 
curl --noproxy '*' "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m | grep -q 'arm\|aarch' && echo 'aarch64' || echo 'x86_64').zip" -o "awscliv2.zip" > /dev/null 2>&1
unzip awscliv2.zip > /dev/null 2>&1
./aws/install > /dev/null 2>&1
rm -f ./awscliv2.zip
rm -rf ./aws

CERT_DIR="/home/ubuntu/mtls-certs"
mkdir -p "$CERT_DIR"

export SERVER_KEY="$CERT_DIR/server.key"
export SERVER_CRT="$CERT_DIR/server.crt"
export CA="$CERT_DIR/ca.crt"

# Decode and write certificates
echo "===== Decoding postgres_client_cert ====="
get_base64_secrets "$postgres_client_cert" | base64 -d > "$SERVER_CRT"
cat "$SERVER_CRT"

echo "===== Decoding postgres_client_key ====="
get_base64_secrets "$postgres_client_key" | base64 -d > "$SERVER_KEY"
cat "$SERVER_KEY"

echo "===== Decoding postgres_client_ca ====="
get_base64_secrets "$postgres_client_ca" | base64 -d > "$CA"
cat "$CA"

chmod 600 "$SERVER_KEY"
chown ubuntu:ubuntu "$CERT_DIR"/*
echo "✅ Certificates generated in $CERT_DIR"

# Add user to docker group
usermod -aG docker ubuntu

# Remove old container if exists
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

# Check certs exist
for f in server.crt server.key ca.crt; do
  [[ -f "$CERT_DIR/$f" ]] || { echo "❌ Missing $f in $CERT_DIR"; exit 1; }
done

# Verify cert and key match
echo "🔍 Verifying key and cert match..."
openssl x509 -noout -modulus -in "$SERVER_CRT" | openssl md5
openssl rsa  -noout -modulus -in "$SERVER_KEY" | openssl md5

# Wait for PostgreSQL to be ready for config
echo "⏳ Waiting for PostgreSQL container to initialize..."
sleep 30

# Copy certs into the container
docker exec postgres mkdir -p /var/lib/postgresql/certs
docker cp "$SERVER_CRT" postgres:/var/lib/postgresql/certs/server.crt
docker cp "$SERVER_KEY" postgres:/var/lib/postgresql/certs/server.key
docker cp "$CA"         postgres:/var/lib/postgresql/certs/ca.crt

# Set permissions
docker exec postgres bash -c "chown postgres:postgres /var/lib/postgresql/certs/* && chmod 600 /var/lib/postgresql/certs/server.key"

# Configure PostgreSQL for SSL
docker exec postgres bash -c "cat > /var/lib/postgresql/data/postgresql.conf <<EOF
ssl = on
ssl_cert_file = '/var/lib/postgresql/certs/server.crt'
ssl_key_file = '/var/lib/postgresql/certs/server.key'
ssl_ca_file = '/var/lib/postgresql/certs/ca.crt'
EOF"

# Update pg_hba.conf
docker exec postgres bash -c "cat >> /var/lib/postgresql/data/pg_hba.conf <<EOF
hostssl all all 0.0.0.0/0 cert clientcert=verify-full
hostssl all all 0.0.0.0/0 md5
EOF"

docker restart postgres
echo "🔄 Postgres container restarted with SSL config."

# Wait for port readiness
echo "⏳ Waiting for PostgreSQL to listen on port 5432..."
start_time=$(date +%s)
while ! nc -z localhost 5432; do
  sleep 1
  (( $(date +%s) - start_time > 180 )) && echo "❌ Timeout: PostgreSQL not listening." && exit 1
done

# Wait for PostgreSQL readiness
echo "⏳ Waiting for PostgreSQL to be ready..."
start_time=$(date +%s)
until docker exec postgres pg_isready -U postgres > /dev/null 2>&1; do
  sleep 1
  (( $(date +%s) - start_time > 180 )) && echo "❌ Timeout: PostgreSQL not ready." && docker logs postgres && exit 1
done

echo "✅ PostgreSQL with mTLS is fully up and running."

# Show connection example
echo
echo "👉 Connect using:"
