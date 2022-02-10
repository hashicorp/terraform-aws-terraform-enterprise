#!/usr/bin/env bash
set -euo pipefail
log_pathname="/var/log/ptfe.log"
echo "[Terraform Enterprise] Setting up" | tee -a $log_pathname
# General OS management
install_jq() {
  curl --silent -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
  chmod +x /bin/jq
}

install_awscli() {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -f ./awscliv2.zip
  rm -rf ./aws
}

configure_ca_certificate() {
    echo "[$(date +"%FT%T")] [Terraform Enterprise] Skipping CA certificate configuration" | tee -a /var/log/ptfe.log
  }

configure_proxy() {
  local proxy_ip="$1"
  # Use a unique name so no_proxy can be exported
  local no_proxy_local="$2"
  local distribution="$3"
  local cert_pathname=""

  cat <<EOF >>/etc/environment
http_proxy="$proxy_ip"
https_proxy="$proxy_ip"
no_proxy="$no_proxy_local"
EOF

  cat <<EOF >/etc/profile.d/proxy.sh
http_proxy="$proxy_ip"
https_proxy="$proxy_ip"
no_proxy="$no_proxy_local"
EOF

  export http_proxy="$proxy_ip"
  export https_proxy="$proxy_ip"
  export no_proxy="$no_proxy_local"
}

install_packages() {
  local distribution="$1"

  case "$distribution" in
    "ubuntu")
      apt-get update -y
      apt-get install -y unzip
      ;;
    "rhel")
      yum install -y \
        unzip \
        https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      systemctl enable amazon-ssm-agent
      systemctl start amazon-ssm-agent
      ;;
  esac
}

detect_distribution() {
  local distribution_name=""
  local distribution=""

  distribution_name=$(grep "^NAME=" /etc/os-release | cut -d"\"" -f2)

  case "$distribution_name" in
    "Red Hat"*)
      distribution="rhel"
      ;;
    "Ubuntu"*)
      distribution="ubuntu"
      ;;
    *)
      echo "Unsupported operating system '$distribution_name' detected"
      exit 1
  esac

  echo "$distribution"
}

retrieve_tfe_license() {
  echo "[$(date +"%FT%T")] [Terraform Enterprise] Retrieving Terraform Enterprise license" | tee -a /var/log/ptfe.log
  license_data_b64=$(\
    aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-2:873298400219:secret:qwe-ei2Fwd \
    | jq --raw-output '.SecretBinary,.SecretString | select(. != null)')
  echo $license_data_b64 | base64 --decode > /etc/ptfe-license.rli
}

install_tfe() {
  echo "[Terraform Enterprise] Setting up" | tee -a /var/log/ptfe.log

  local proxy_ip="$1"
  local no_proxy="$2"
  local active_active="$3"
  local private_ip=""
  local arguments=()
    echo "[Terraform Enterprise] Creating mounted disk directory at '/opt/hashicorp/data'" | tee -a $log_pathname
  mkdir --parents /opt/hashicorp/data
  chmod og+rw /opt/hashicorp/data
  
  private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  arguments+=("fast-timeouts" "private-address=$private_ip" "public-address=$private_ip")

  if [[ $proxy_ip != "" ]]
  then
    arguments+=("http-proxy=$proxy_ip" "additional-no-proxy=$no_proxy")
  else
    arguments+=("no-proxy")
  fi

  
  replicated_directory="/tmp/replicated"
  install_pathname="$replicated_directory/install.sh"

    install_url="https://get.replicated.com/docker/terraformenterprise/active-active"
  echo "[Terraform Enterprise] Downloading Replicated installation script from '$install_url' to '$install_pathname'" | tee -a $log_pathname
  curl --create-dirs --output $install_pathname $install_url
    chmod +x $install_pathname
  cd $replicated_directory
  $install_pathname "${arguments[@]}" | tee -a $log_pathname
}

configure_tfe() {
  local replicated="$1"
  local settings="$2"

  echo "$replicated" | base64 -d > /etc/replicated.conf
  echo "$settings" | base64 -d > /etc/ptfe-settings.json
}

proxy_ip=""
no_proxy="127.0.0.1,169.254.169.254,.aws.ce.redhat.com"
replicated="eyJCeXBhc3NQcmVmbGlnaHRDaGVja3MiOnRydWUsIkRhZW1vbkF1dGhlbnRpY2F0aW9uUGFzc3dvcmQiOiI3U2ZWaWRRVlZXMVlPdVhrIiwiRGFlbW9uQXV0aGVudGljYXRpb25UeXBlIjoicGFzc3dvcmQiLCJJbXBvcnRTZXR0aW5nc0Zyb20iOiIvZXRjL3B0ZmUtc2V0dGluZ3MuanNvbiIsIkxpY2Vuc2VGaWxlTG9jYXRpb24iOiIvZXRjL3B0ZmUtbGljZW5zZS5ybGkiLCJUbHNCb290c3RyYXBIb3N0bmFtZSI6InF3ZS50ZmUtbW9kdWxlcy10ZXN0LmF3cy5wdGZlZGV2LmNvbSIsIlRsc0Jvb3RzdHJhcFR5cGUiOiJzZWxmLXNpZ25lZCJ9"
settings="eyJhcmNoaXZpc3RfdG9rZW4iOnsidmFsdWUiOiI4OTc1YjU3ZmIwMDE1MTdmZTAwOWIzMTBkYTkwYWZjZCJ9LCJjb29raWVfaGFzaCI6eyJ2YWx1ZSI6IjVhZTE5YWNhZjZkNGZkYzc1Y2FhOGZkOTI1NmM1NTc2In0sImRpc2tfcGF0aCI6eyJ2YWx1ZSI6Ii9vcHQvaGFzaGljb3JwL2RhdGEifSwiZW5jX3Bhc3N3b3JkIjp7InZhbHVlIjoiN2NjYmM0NjAyYmM0NTFjZmExNmUwM2JhZDc2NTY5YzUifSwiaG9zdG5hbWUiOnsidmFsdWUiOiJxd2UudGZlLW1vZHVsZXMtdGVzdC5hd3MucHRmZWRldi5jb20ifSwiaWFjdF9zdWJuZXRfbGlzdCI6eyJ2YWx1ZSI6IjAuMC4wLjAvMCJ9LCJpYWN0X3N1Ym5ldF90aW1lX2xpbWl0Ijp7InZhbHVlIjoiNjAifSwiaW5zdGFsbF9pZCI6eyJ2YWx1ZSI6IjI4ZjVkODY4MTQ4OTNhNDVmYWFmYmZmNTJhZDFlZmMwIn0sImluc3RhbGxhdGlvbl90eXBlIjp7InZhbHVlIjoicHJvZHVjdGlvbiJ9LCJpbnRlcm5hbF9hcGlfdG9rZW4iOnsidmFsdWUiOiI4MGZjNjJhMzIwMjQwYjAyZTI4ZGEyNGMzNTU0ZTFjNCJ9LCJwcm9kdWN0aW9uX3R5cGUiOnsidmFsdWUiOiJkaXNrIn0sInJlZ2lzdHJ5X3Nlc3Npb25fZW5jcnlwdGlvbl9rZXkiOnsidmFsdWUiOiI5NzhhNDJjZDM4YTU2N2Q3ZmIxNDU2Yzg5OTFjYjU0MSJ9LCJyZWdpc3RyeV9zZXNzaW9uX3NlY3JldF9rZXkiOnsidmFsdWUiOiI5OTkzNGI4ZDY1YmY3NDNhMzI0YTQyZGU0NDkxZmI5NSJ9LCJyb290X3NlY3JldCI6eyJ2YWx1ZSI6ImU0MTAyODkxNGJiZTYzZjFiYjZmM2M2YTU5YmU3Y2Q1In0sInVzZXJfdG9rZW4iOnsidmFsdWUiOiI4N2MwN2Y5MzRhOTc5ZDllMDcxZGMzMGJkYzU3MGRkNCJ9fQ=="
active_active="false"

distribution=$(detect_distribution)
configure_tfe "$replicated" "$settings"
install_packages "$distribution"
install_awscli
install_jq
retrieve_tfe_license
configure_ca_certificate "$distribution"

if [[ $proxy_ip != "" ]]
then
  configure_proxy "$proxy_ip" "$no_proxy" "$distribution"
fi


install_tfe "$proxy_ip" "$no_proxy" "$active_active" 