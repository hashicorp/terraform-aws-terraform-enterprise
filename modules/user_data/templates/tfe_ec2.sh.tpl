#!/usr/bin/env bash
set -euo pipefail
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

configure_proxy() {
  local proxy_ip="$1"
  # Use a unique name so no_proxy can be exported
  local no_proxy_local="$2"
  local proxy_cert="$3"
  local s3_bucket_bootstrap="$4"
  local distribution="$5"
  local cert_pathname=""

  if [[ $proxy_cert != "" ]]
  then
    if [[ $distribution == "ubuntu" ]]
    then
      mkdir -p /usr/local/share/ca-certificates/extra
      cert_pathname="/usr/local/share/ca-certificates/extra/cust-ca-certificates.crt"
      aws s3 cp "s3://$s3_bucket_bootstrap/$proxy_cert" "$cert_pathname"
      update-ca-certificates
    elif [[ $distribution == "rhel" ]]
    then
      mkdir -p /usr/share/pki/ca-trust-source/anchors
      cert_pathname="/usr/share/pki/ca-trust-source/anchors/cust-ca-certificates.crt"
      aws s3 cp "s3://$s3_bucket_bootstrap/$proxy_cert" "$cert_pathname"
      update-ca-trust
    fi
  fi

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

  if [[ $proxy_cert != "" ]]
  then
    install_jq
    jq ". + { ca_certs: { value: \"$(cat $cert_pathname)\" } }" -- /etc/ptfe-settings.json > ptfe-settings.json.updated
    cp ./ptfe-settings.json.updated /etc/ptfe-settings.json
  fi
}

install_packages() {
  local distribution="$1"

  case "$distribution" in
    "ubuntu")
      apt-get update -y
      apt-get install -y unzip
      ;;
    "rhel")
      yum install -y unzip
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
  local s3_bucket_bootstrap="$1"
  local tfe_license="$2"

  aws s3 cp "s3://$s3_bucket_bootstrap/$tfe_license" /etc/ptfe-license.rli
}

install_tfe() {
  echo "[Terraform Enterprise] Setting up" | tee -a /var/log/ptfe.log

  local proxy_ip="$1"
  local no_proxy="$2"
  local active_active="$3"
  local private_ip=""
  local arguments=()

  private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  arguments+=("fast-timeouts" "private-address=$private_ip" "public-address=$private_ip")

  if [[ $proxy_ip != "" ]]
  then
    arguments+=("http-proxy=$proxy_ip" "additional-no-proxy=$no_proxy")
  else
    arguments+=("no-proxy")
  fi

  if [[ $active_active != "" ]]
  then
    arguments+=("disable-replicated-ui")
  fi

  curl -o /tmp/install.sh https://get.replicated.com/docker/terraformenterprise/active-active
  chmod +x /tmp/install.sh
  /tmp/install.sh "$${arguments[@]}" | tee -a /var/log/ptfe.log
}

configure_tfe() {
  local replicated="$1"
  local settings="$2"

  echo "$replicated" | base64 -d > /etc/replicated.conf
  echo "$settings" | base64 -d > /etc/ptfe-settings.json
}

proxy_ip="${proxy_ip}"
no_proxy="${no_proxy}"
proxy_cert="${proxy_cert}"
s3_bucket_bootstrap="${s3_bucket_bootstrap}"
tfe_license="${tfe_license}"
replicated="${replicated}"
settings="${settings}"
active_active="${active_active}"

distribution=$(detect_distribution)
configure_tfe "$replicated" "$settings"
install_packages "$distribution"
install_awscli
retrieve_tfe_license "$s3_bucket_bootstrap" "$tfe_license"
if [[ $proxy_ip != "" ]]
then
  configure_proxy "$proxy_ip" "$no_proxy" "$proxy_cert" "$s3_bucket_bootstrap" "$distribution"
fi
install_tfe "$proxy_ip" "$no_proxy" "$active_active"
