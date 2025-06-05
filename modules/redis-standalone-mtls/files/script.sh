#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

set -eu pipefail

function get_base64_secrets {
	local secret_id=$1
	# OS: Agnostic
	# Description: Pull the Base 64 encoded secrets from AWS Secrets Manager

	/usr/local/bin/aws secretsmanager get-secret-value --secret-id $secret_id | jq --raw-output '.SecretBinary,.SecretString | select(. != null)'
}

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

curl --noproxy '*' --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg \
	| gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
	https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable" \
	| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
retry 10 apt-get --assume-yes update
retry 10 apt-get --assume-yes install docker-ce docker-ce-cli containerd.io redis-tools
retry 10 apt-get --assume-yes autoremove


echo "[$(date +"%FT%T")] [Terraform Enterprise] Install AWS CLI" 
curl --noproxy '*' "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m | grep -q "arm\|aarch" && echo "aarch64" || echo "x86_64").zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -f ./awscliv2.zip
rm -rf ./aws

tfe_dir="/etc/redis"
mkdir -p $tfe_dir

export FULLCHAIN=$tfe_dir/fullchain.pem
export PRIVKEY=$tfe_dir/privkey.pem
export ISRGROOTX1=$tfe_dir/isrgrootx1.pem
echo ${compose} | base64 -d > $tfe_dir/compose.yaml

fullchain=$(get_base64_secrets ${redis_client_cert})
privkey=$(get_base64_secrets ${redis_client_key})
isrgrootx1=$(get_base64_secrets ${redis_client_ca})

echo ${fullchain} | base64 -d > $FULLCHAIN
echo ${privkey} | base64 -d > $PRIVKEY
echo ${isrgrootx1} | base64 -d > $ISRGROOTX1

chmod a+r $FULLCHAIN
chmod a+r $PRIVKEY
chmod a+r $ISRGROOTX1
docker compose -f $tfe_dir/compose.yaml up -d