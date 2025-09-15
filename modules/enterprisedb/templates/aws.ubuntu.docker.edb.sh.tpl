#!/usr/bin/env bash
set -eu pipefail

function retry {
  local retries=$1
  shift

  local count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** $count))
    count=$(($count + 1))
    if [ $count -lt $retries ]; then
      echo "Retry $count/$retries exited $exit, retrying in $wait seconds..."
      sleep $wait
    else
      echo "Retry $count/$retries exited $exit, no more retries left."
      return $exit
    fi
  done
  return 0
  
}

log_pathname="/var/log/startup.log"

echo "[$(date +"%FT%T")] [EnterpriseDB] Installing Docker Engine from Repository" | tee -a $log_pathname
curl --noproxy '*' --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg \
	| gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
	https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable" \
	| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
retry 10 apt-get --assume-yes update
retry 10 apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
retry 10 apt-get --assume-yes autoremove

echo "[$(date +"%FT%T")] [EnterpriseDB] Installing EnterpriseDB" | tee -a $log_pathname
hostname > /var/log/edb.log
docker login -u="${registry_username}" -p="${registry_password}" quay.io

export HOST_IP=$(hostname -i)

edb_dir="/etc/edb"
mkdir -p $edb_dir

echo ${docker_compose_yaml} | base64 -d > $edb_dir/compose.yaml

docker compose -f /etc/edb/compose.yaml up -d