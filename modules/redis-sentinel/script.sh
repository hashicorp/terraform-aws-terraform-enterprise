#!/usr/bin/env bash
set -eu pipefail

curl --noproxy '*' --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg \
	| gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
	https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable" \
	| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get --assume-yes update
apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
apt-get --assume-yes autoremove

tfe_dir="/etc/redis"
mkdir -p $tfe_dir

echo ${compose} | base64 -d > $tfe_dir/compose.yaml
docker compose -f $tfe_dir/compose.yaml up -d