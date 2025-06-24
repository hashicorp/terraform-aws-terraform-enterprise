# #!/bin/bash
# set -e

# mkdir -p "/home/ubuntu"

# # Redirect all output to log file
# exec > >(tee -a /home/ubuntu/startup.log) 2>&1
# set -x  # Print each command as it runs (for full trace)

# echo "🔧 Installing dependencies..."
# apt-get update -y
# apt-get install -y docker.io postgresql-client openssl
# systemctl start docker
# systemctl enable docker
# echo "✅ Docker and dependencies installed."

# echo "🔐 Generating SSL certificates..."

# # Generate CA
# openssl req -new -x509 -days 365 -nodes \
#   -subj "/CN=Test CA" \
#   -keyout ca.key -out ca.crt

# # Generate Server Certificate
# openssl req -new -nodes \
#   -subj "/CN=postgres" \
#   -keyout server.key -out server.csr

# openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
#   -out server.crt -days 365

# # Generate Client Certificate
# openssl req -new -nodes \
#   -subj "/CN=pg-client" \
#   -keyout client.key -out client.csr

# openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
#   -out client.crt -days 365

# chmod 600 server.key client.key
# echo "✅ Certificates generated."

# # Log certs
# echo "===== CA CERT =====";      cat ca.crt
# echo "===== CLIENT CERT =====";  cat client.crt
# echo "===== CLIENT KEY =====";   cat client.key

# # Prepare cert directory
# CERT_DIR="/home/ubuntu/mtls-certs"
# mkdir -p "$CERT_DIR"
# cp server.crt server.key ca.crt "$CERT_DIR/"
# chown ubuntu:ubuntu "$CERT_DIR"/*

# echo "✅ Certificates copied to $CERT_DIR."

# # Add user to docker group
# usermod -aG docker ubuntu

# # Cleanup existing container
# if docker ps -a --format '{{.Names}}' | grep -qw postgres; then
#   echo "Removing existing 'postgres' container..."
#   docker rm -f postgres
# fi

# echo "🚀 Starting PostgreSQL container..."
# docker run -d \
#   --name postgres \
#   -p 5432:5432 \
#   -e POSTGRES_USER=${POSTGRES_USER} \
#   -e POSTGRES_PASSWORD="postgres_postgres" \
#   -e POSTGRES_DB=${POSTGRES_DB} \
#   postgres:16 || { echo "❌ Docker run failed"; exit 1; }

# # Validate container is running
# sleep 5
# if ! docker ps | grep -qw postgres; then
#   echo "❌ Postgres container failed to start. Logs:"
#   docker logs postgres
#   exit 1
# fi

# echo "✅ Postgres container is running."

# # Verify certs exist
# for f in server.crt server.key ca.crt; do
#   [[ -f "$CERT_DIR/$f" ]] || { echo "❌ Missing $f in $CERT_DIR"; exit 1; }
# done

# # Validate key matches cert
# echo "🔍 Verifying key and cert match..."
# openssl x509 -noout -modulus -in "$CERT_DIR/server.crt" | openssl md5
# openssl rsa  -noout -modulus -in "$CERT_DIR/server.key" | openssl md5

# # Wait for container to initialize
# echo "⏳ Waiting for PostgreSQL container to start..."
# sleep 30

# # Copy certs to container
# docker exec postgres mkdir -p /var/lib/postgresql/certs
# docker cp "$CERT_DIR/server.crt" postgres:/var/lib/postgresql/certs/
# docker cp "$CERT_DIR/server.key" postgres:/var/lib/postgresql/certs/
# docker cp "$CERT_DIR/ca.crt"     postgres:/var/lib/postgresql/certs/

# # Set permissions inside container
# docker exec postgres bash -c "chown postgres:postgres /var/lib/postgresql/certs/* && chmod 600 /var/lib/postgresql/certs/server.key"

# echo "✅ Certificates copied and secured inside container."

# # Enable SSL in Postgres config
# docker exec postgres bash -c "echo \"ssl = on
# ssl_cert_file = '/var/lib/postgresql/certs/server.crt'
# ssl_key_file  = '/var/lib/postgresql/certs/server.key'
# ssl_ca_file   = '/var/lib/postgresql/certs/ca.crt'\" >> /var/lib/postgresql/data/postgresql.conf"

# # Enable client auth
# docker exec postgres bash -c "echo \"hostssl all all 0.0.0.0/0 cert clientcert=verify-full\" >> /var/lib/postgresql/data/pg_hba.conf"
# docker exec postgres bash -c "echo \"hostssl all all 0.0.0.0/0 md5\" >> /var/lib/postgresql/data/pg_hba.conf"

# docker restart postgres
# echo "🔄 Postgres container restarted with SSL settings."

# # Wait for PostgreSQL on port 5432
# echo "⏳ Waiting for PostgreSQL to listen on port 5432..."
# start_time=$(date +%s)
# while ! nc -z localhost 5432; do
#   sleep 1
#   (( $(date +%s) - start_time > 180 )) && echo "❌ Timeout: PostgreSQL not listening." && exit 1
# done

# # Wait for readiness
# echo "⏳ Waiting for PostgreSQL to be ready..."
# start_time=$(date +%s)
# until docker exec postgres pg_isready -U postgres > /dev/null 2>&1; do
#   sleep 1
#   (( $(date +%s) - start_time > 180 )) && echo "❌ Timeout: PostgreSQL not ready." && docker logs postgres && exit 1
# done

# echo "✅ PostgreSQL with mTLS is fully up and running."
