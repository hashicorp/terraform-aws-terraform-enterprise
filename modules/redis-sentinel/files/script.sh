#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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

export SENTINEL_ENTRYPOINT=$tfe_dir/senitnel.sh

echo ${compose} | base64 -d > $tfe_dir/compose.yaml
echo ${sentinel_start_script} | base64 -d > $SENTINEL_ENTRYPOINT
chmod a+x $SENTINEL_ENTRYPOINT
docker compose -f $tfe_dir/compose.yaml up -d
