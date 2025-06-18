
echo "installed openssl"

# Set working directory for certificates
CERT_DIR="/certs"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

echo "made certs directory"

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
# echo "===== SERVER CERT ====="
# cat server.crt
# echo "===== SERVER KEY ====="
# cat server.key

# Ensure target directory exists
mkdir -p /home/ubuntu/mtls-certs

# Copy certs to home directory
cp server.crt server.key ca.crt /home/ubuntu/mtls-certs/
chown ubuntu:ubuntu /home/ubuntu/mtls-certs/*

echo "Certificates generated and copied successfully."
