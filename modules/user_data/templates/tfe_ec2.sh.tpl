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
  %{ if ca_certificate_secret != null ~}
  echo "[$(date +"%FT%T")] [Terraform Enterprise] Configuring CA certificate" | tee -a /var/log/ptfe.log

  local distribution="$1"
  local ca_certificate_directory="/dev/null"
  local update_ca_certificates="/dev/null"

  if [[ $distribution == "ubuntu" ]]
  then
    ca_certificate_directory="/usr/local/share/ca-certificates/extra"
    update_ca_certificates="update-ca-certificates"
  elif [[ $distribution == "rhel" ]]
  then
    ca_certificate_directory="/usr/share/pki/ca-trust-source/anchors"
    update_ca_certificates="update-ca-trust"
  fi

  mkdir --parents $ca_certificate_directory
  ca_certificate_data_b64=$(\
    aws secretsmanager get-secret-value --secret-id ${ca_certificate_secret} \
    | jq --raw-output '.SecretBinary,.SecretString | select(. != null)')
  echo $ca_certificate_data_b64 | base64 --decode > $ca_certificate_directory/tfe-ca-certificate.crt
  eval $update_ca_certificates
  jq ". + { ca_certs: { value: \"$(echo $ca_certificate_data_b64 | base64 --decode)\" } }" -- ${import_settings_from} > ${import_settings_from}.updated
  cp ${import_settings_from}.updated ${import_settings_from}
  %{ else ~}
  echo "[$(date +"%FT%T")] [Terraform Enterprise] Skipping CA certificate configuration" | tee -a /var/log/ptfe.log
  %{ endif ~}
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
    aws secretsmanager get-secret-value --secret-id ${tfe_license_secret} \
    | jq --raw-output '.SecretBinary,.SecretString | select(. != null)')
  echo $license_data_b64 | base64 --decode > ${license_file_location}
}

install_tfe() {
  echo "[Terraform Enterprise] Setting up" | tee -a /var/log/ptfe.log

  local proxy_ip="$1"
  local no_proxy="$2"
  local active_active="$3"
  local private_ip=""
  local arguments=()
  %{ if disk_path != null ~}
  echo "[Terraform Enterprise] Creating mounted disk directory at '${disk_path}'" | tee -a $log_pathname
  mkdir --parents ${disk_path}
  chmod og+rw ${disk_path}
  %{ endif ~}

  private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  arguments+=("fast-timeouts" "private-address=$private_ip" "public-address=$private_ip")

  if [[ $proxy_ip != "" ]]
  then
    arguments+=("http-proxy=$proxy_ip" "additional-no-proxy=$no_proxy")
  else
    arguments+=("no-proxy")
  fi

  %{if active_active ~}
  arguments+=("disable-replicated-ui")
  %{ endif ~}

  replicated_directory="/tmp/replicated"
  install_pathname="$replicated_directory/install.sh"

  %{ if airgap_url != null ~}
  arguments+=("airgap")
  echo "[Terraform Enterprise] Installing Docker Engine from Repository" | tee -a $log_pathname

  if [[ $distribution == "ubuntu" ]]
   then
   apt-get --assume-yes update
   apt-get --assume-yes install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release
   curl --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg \
     | gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
     https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable" \
     | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   apt-get --assume-yes update
   apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
   apt-get --assume-yes autoremove

  elif [[ $distribution == "rhel" ]]
   then
   yum install --assumeyes yum-utils
   yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
   yum install --assumeyes docker-ce docker-ce-cli containerd.io
  fi

  replicated_filename="replicated.tar.gz"
  replicated_url="https://s3.amazonaws.com/replicated-airgap-work/$replicated_filename"
  replicated_pathname="$replicated_directory/$replicated_filename"
  echo "[Terraform Enterprise] Downloading Replicated from '$replicated_url' to '$replicated_pathname'" | tee -a $log_pathname
  curl --create-dirs --output "$replicated_pathname" "$replicated_url"
  echo "[Terraform Enterprise] Extracting Replicated in '$replicated_directory'" | tee -a $log_pathname
  tar --directory "$replicated_directory" --extract --file "$replicated_pathname"
  echo "[Terraform Enterprise] Copying airgap package '${airgap_url}' to '${airgap_pathname}'" | tee -a $log_pathname
  curl --create-dirs --output "${airgap_pathname}" "${airgap_url}"
  %{ else ~}
  install_url="https://get.replicated.com/docker/terraformenterprise/active-active"
  echo "[Terraform Enterprise] Downloading Replicated installation script from '$install_url' to '$install_pathname'" | tee -a $log_pathname
  curl --create-dirs --output $install_pathname $install_url
  %{ endif ~}
  chmod +x $install_pathname
  cd $replicated_directory
  $install_pathname "$${arguments[@]}" | tee -a $log_pathname
}

configure_tfe() {
  local replicated="$1"
  local settings="$2"

  echo "$replicated" | base64 -d > /etc/replicated.conf
  echo "$settings" | base64 -d > ${import_settings_from}
}

proxy_ip="${proxy_ip}"
no_proxy="${no_proxy}"
replicated="${replicated}"
settings="${settings}"
active_active="${active_active}"

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