#!/bin/bash

set -e -u -o pipefail

apt-get --yes --option "Acquire::Retries=5" update
apt-get install --yes unzip

mkdir -p /etc/mitmproxy

touch /etc/systemd/system/mitmproxy.service
chown root:root /etc/systemd/system/mitmproxy.service
chmod 0644 /etc/systemd/system/mitmproxy.service

cat <<EOF >/etc/systemd/system/mitmproxy.service
[Unit]
Description=mitmproxy
ConditionPathExists=/etc/mitmproxy
[Service]
ExecStart=/usr/local/bin/mitmdump -p ${http_proxy_port} --set confdir=/etc/mitmproxy --ssl-insecure
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo "[$(date +"%FT%T")]  Downloading mitmproxy tar from the web" | tee -a /var/log/ptfe.log
curl -Lo /tmp/mitmproxy.tar.gz https://snapshots.mitmproxy.org/6.0.2/mitmproxy-6.0.2-linux.tar.gz
tar xvf /tmp/mitmproxy.tar.gz -C /usr/local/bin/

echo "[$(date +"%FT%T")] Installing JQ" | tee -a /var/log/ptfe.log
curl --noproxy '*' -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x /bin/jq

echo "[$(date +"%FT%T")] Installing aws" | tee -a /var/log/ptfe.log
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -f ./awscliv2.zip
rm -rf ./aws

echo "[$(date +"%FT%T")] Downloading Public Certificate and Private Key" | tee -a /var/log/ptfe.log
# Obtain access token for Azure Key Vault
certificate_data_b64=$(\
  aws secretsmanager get-secret-value --secret-id ${certificate_secret.arn} \
  | jq --raw-output '.SecretBinary,.SecretString | select(. != null)')
key_data_b64=$(\
  aws secretsmanager get-secret-value --secret-id ${private_key_secret.arn} \
  | jq --raw-output '.SecretBinary,.SecretString | select(. != null)')

echo "[$(date +"%FT%T")]  Deploying Public Certificate and Private Key for mitmproxy" | tee -a /var/log/ptfe.log
cat <<EOF >/etc/mitmproxy/mitmproxy-ca.pem
$(echo $certificate_data_b64 | base64 --decode)
$(echo $key_data_b64 | base64 --decode)
EOF

echo "[$(date +"%FT%T")]  Starting mitmproxy service"
systemctl daemon-reload
systemctl start mitmproxy
systemctl enable mitmproxy
