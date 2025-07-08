#!/bin/bash
set -euxo pipefail

echo "🔧 Installing dependencies..."
apt-get update -y && apt-get install -y docker.io postgresql-client openssl unzip jq
systemctl enable --now docker
usermod -aG docker ubuntu

echo "⬇️ Installing AWS CLI..."
curl -sS --noproxy '*' "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m | grep -q 'arm\|aarch' && echo 'aarch64' || echo 'x86_64').zip" -o "awscliv2.zip" > /dev/null 2>&1
unzip -q awscliv2.zip > /dev/null 2>&1
./aws/install > /dev/null 2>&1
rm -rf aws awscliv2.zip > /dev/null 2>&1

# Create cert dir and download secrets
CERT_DIR="/home/ubuntu/mtls-certs"
mkdir -p "$CERT_DIR"

function get_secret {
	local secret_id=$1
	/usr/local/bin/aws secretsmanager get-secret-value --secret-id "$secret_id" | jq --raw-output '.SecretBinary,.SecretString | select(. != null)'
}

echo "🔐 Decoding secrets..."
get_secret "$POSTGRES_CLIENT_CERT" | base64 -d > "$CERT_DIR/server.crt"
get_secret "$POSTGRES_CLIENT_KEY"  | base64 -d > "$CERT_DIR/server.key"
get_secret "$POSTGRES_CLIENT_CA"   | base64 -d > "$CERT_DIR/ca.crt"

chmod 600 "$CERT_DIR/"*
chown ubuntu:ubuntu "$CERT_DIR/"*

# Remove old container if exists
docker rm -f postgres 2>/dev/null || true

docker volume create postgres-certs

docker run --rm \
  -v postgres-certs:/target \
  -v "$CERT_DIR:/source:ro" \
  postgres:16 \
  bash -c "
    cp /source/server.crt /source/server.key /source/ca.crt /target/ &&
    chown postgres:postgres /target/server.key /target/server.crt /target/ca.crt &&
    chmod 600 /target/server.key &&
    chmod 644 /target/server.crt /target/ca.crt
  "

docker run -d \
  --name postgres \
  -p 5432:5432 \
  -v postgres-certs:/certs:ro \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -e POSTGRES_DB="$POSTGRES_DB" \
  postgres:16 \
  postgres \
  -c ssl=on \
  -c ssl_cert_file='/certs/server.crt' \
  -c ssl_key_file='/certs/server.key' \
  -c ssl_ca_file='/certs/ca.crt'

# echo "🚀 Starting PostgreSQL container with mounted certs..."
# docker run -d \
#   --name postgres \
#   -p 5432:5432 \
#   -v "$CERT_DIR:/certs:ro" \
#   -e POSTGRES_USER="$POSTGRES_USER" \
#   -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
#   -e POSTGRES_DB="$POSTGRES_DB" \
#   postgres:16

# echo "⏳ Waiting for PostgreSQL to initialize..."
# sleep 30

# echo "🔧 Configuring PostgreSQL for SSL..."
# docker exec postgres bash -c "cat >> /var/lib/postgresql/data/postgresql.conf" <<EOF
# ssl = on
# ssl_cert_file = '/certs/server.crt'
# ssl_key_file = '/certs/server.key'
# ssl_ca_file = '/certs/ca.crt'
# EOF

# docker exec postgres bash -c "cat >> /var/lib/postgresql/data/pg_hba.conf" <<EOF
# hostssl all all 0.0.0.0/0 cert clientcert=verify-full
# hostssl all all 0.0.0.0/0 md5
# EOF

# docker restart postgres

# echo "✅ PostgreSQL restarted with mTLS configuration."

# Wait until PostgreSQL is up
echo "⏳ Waiting for PostgreSQL to become ready..."
timeout=180
start=$(date +%s)
while ! docker exec postgres pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
  sleep 1
  [[ $(( $(date +%s) - start )) -gt $timeout ]] && echo "❌ Timeout waiting for PostgreSQL" && docker logs postgres && exit 1
done

echo "✅ PostgreSQL with mTLS is fully up and running."
