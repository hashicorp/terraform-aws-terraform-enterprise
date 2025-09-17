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

# For passwordless postgres, we start with basic configuration
# IAM authentication will be handled at the RDS level
docker run -d \
  --name postgres \
  -p 5432:5432 \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -e POSTGRES_DB="$POSTGRES_DB" \
  postgres:16

# Wait until PostgreSQL is up
echo "Waiting for PostgreSQL to become ready..."
timeout=180
start=$(date +%s)
while ! docker exec postgres pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; do
  sleep 1
  [[ $(( $(date +%s) - start )) -gt $timeout ]] && echo "Timeout waiting for PostgreSQL" && docker logs postgres && exit 1
done

echo "PostgreSQL with passwordless authentication is fully up and running."