#!/bin/bash
# set -e
# Update and install Docker
# apt-get update -y
# apt-get install -y docker.io
# systemctl start docker
# systemctl enable docker
# usermod -a -G docker ubuntu

# mkdir -p /home/ubuntu/mtls-certs
# chown ubuntu:ubuntu /home/ubuntu/mtls-certs

# Write the Dockerfile
# cat <<'EOF' > /home/ubuntu/Dockerfile
# FROM postgres:16

# RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /certs && cd /certs && \
#     openssl req -new -x509 -days 365 -nodes \
#       -subj "/CN=Test CA" \
#       -keyout ca.key -out ca.crt && \
#     openssl req -new -nodes \
#       -subj "/CN=postgres" \
#       -keyout server.key -out server.csr && \
#     openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
#       -out server.crt -days 365 && \
#     openssl req -new -nodes \
#       -subj "/CN=pg-client" \
#       -keyout client.key -out client.csr && \
#     openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
#       -out client.crt -days 365 && \
#     chmod 600 server.key client.key

# RUN mkdir -p /var/lib/postgresql/certs && \
#     cp /certs/server.crt /certs/server.key /certs/ca.crt /var/lib/postgresql/certs && \
#     chown -R postgres:postgres /var/lib/postgresql/certs && \
#     chmod 600 /var/lib/postgresql/certs/server.key

# RUN echo "ssl = on" >> /usr/share/postgresql/postgresql.conf.sample && \
#     echo "ssl_cert_file = '/var/lib/postgresql/certs/server.crt'" >> /usr/share/postgresql/postgresql.conf.sample && \
#     echo "ssl_key_file = '/var/lib/postgresql/certs/server.key'" >> /usr/share/postgresql/postgresql.conf.sample && \
#     echo "ssl_ca_file = '/var/lib/postgresql/certs/ca.crt'" >> /usr/share/postgresql/postgresql.conf.sample

# RUN echo "hostssl all all 0.0.0.0/0 cert clientcert=1" > /docker-entrypoint-initdb.d/pg_hba.conf

# CMD ["postgres", "-c", "config_file=/usr/share/postgresql/postgresql.conf.sample"]
# EOF

# Build the Docker image
# cd /home/ubuntu
# docker build -t postgres-mtls .

# Run the container
# docker run -d \
#   -p 5432:5432 \
#   -e POSTGRES_USER=${POSTGRES_USER} \
#   -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
#   -e POSTGRES_DB=${POSTGRES_DB} \
#   --name postgres \
#   postgres:16

# Wait for container to be ready
# sleep 10

# Copy certificates out of container
# docker cp postgres:/certs/export/ca.crt /home/ubuntu/ca.crt
# docker cp postgres:/certs/export/client.crt /home/ubuntu/client.crt
# docker cp postgres:/certs/export/client.key /home/ubuntu/client.key

# Print the certificates to the system log
# echo "-----BEGIN CA CERT ON EC2-----"
# cat /home/ubuntu/ca.crt
# echo "-----END CA CERT ON EC2-----"

# echo "-----BEGIN CLIENT CERT ON EC2-----"
# cat /home/ubuntu/client.crt
# echo "-----END CLIENT CERT ON EC2-----"

# echo "-----BEGIN CLIENT KEY ON EC2-----"
# cat /home/ubuntu/client.key
# echo "-----END CLIENT KEY ON EC2-----"