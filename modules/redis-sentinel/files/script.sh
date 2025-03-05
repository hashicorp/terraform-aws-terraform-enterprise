#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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


curl --noproxy '*' --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg \
	| gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
	https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable" \
	| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
retry 10 apt-get --assume-yes update
retry 10 apt-get --assume-yes install docker-ce docker-ce-cli containerd.io redis-tools
retry 10 apt-get --assume-yes autoremove

tfe_dir="/etc/redis"
mkdir -p $tfe_dir
get_linux_ip() {
  ip addr show | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d/ -f1 | head -n 1
}
export HOST_IP=$(get_linux_ip)
export SENTINEL_ENTRYPOINT=$tfe_dir/senitnel.sh
export REDIS_CONF=$tfe_dir/redis.conf
export REDIS_INIT=$tfe_dir/redis-init.sh
echo ${compose} | base64 -d > $tfe_dir/compose.yaml
echo ${sentinel_start_script} | base64 -d > $SENTINEL_ENTRYPOINT
echo ${redis_conf} | base64 -d > $REDIS_CONF
echo ${redis_init} | base64 -d > $REDIS_INIT
chmod a+r $REDIS_CONF
chmod a+x $SENTINEL_ENTRYPOINT
chmod a+x $REDIS_INIT
docker compose -f $tfe_dir/compose.yaml up -d
