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

echo "[$(date +"%FT%T")] [Terraform Enterprise] Install AWS CLI" 
curl --noproxy '*' "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m | grep -q "arm\|aarch" && echo "aarch64" || echo "x86_64").zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -f ./awscliv2.zip
rm -rf ./aws

echo '----------'

echo $(get_base64_secrets ${postgres_client_cert})
echo $(get_base64_secrets ${postgres_client_key})
echo $(get_base64_secrets ${postgres_client_ca})
