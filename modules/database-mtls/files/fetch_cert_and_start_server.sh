#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

set -eu pipefail

apt-get update -y && apt-get install -y docker.io postgresql-client openssl unzip jq
systemctl enable --now docker
usermod -aG docker ubuntu

curl -sS --noproxy '*' "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m | grep -q 'arm\|aarch' && echo 'aarch64' || echo 'x86_64').zip" -o "awscliv2.zip" > /dev/null 2>&1
unzip -q awscliv2.zip > /dev/null 2>&1
./aws/install > /dev/null 2>&1
rm -rf aws awscliv2.zip > /dev/null 2>&1

CERT_DIR="/home/ubuntu/mtls-certs"
mkdir -p "$CERT_DIR"

function get_secret {
	local secret_id=$1
	/usr/local/bin/aws secretsmanager get-secret-value --secret-id "$secret_id" | jq --raw-output '.SecretBinary,.SecretString | select(. != null)'
}

get_secret "$POSTGRES_CLIENT_CERT" | base64 -d > "$CERT_DIR/server.crt"
get_secret "$POSTGRES_CLIENT_KEY"  | base64 -d > "$CERT_DIR/server.key"
get_secret "$POSTGRES_CLIENT_CA"   | base64 -d > "$CERT_DIR/ca.crt"

chmod 600 "$CERT_DIR/"*
chown ubuntu:ubuntu "$CERT_DIR/"*

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

# Wait until PostgreSQL is up
echo "Waiting for PostgreSQL to become ready..."
timeout=180
start=$(date +%s)
while ! docker exec postgres pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
  sleep 1
  [[ $(( $(date +%s) - start )) -gt $timeout ]] && echo "Timeout waiting for PostgreSQL" && docker logs postgres && exit 1
done

echo "PostgreSQL with mTLS is fully up and running."
