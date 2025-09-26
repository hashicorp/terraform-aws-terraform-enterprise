#!/usr/bin/env bash
set -eu pipefail

${get_base64_secrets}
${install_packages}
%{ if enable_monitoring ~}
${install_monitoring_agents}
%{ endif ~}
${install_jq}

log_pathname="/var/log/startup.log"

%{ if distribution == "rhel" ~}
echo "[Terraform Enterprise] Patching GCP Yum repo configuration" | tee -a $log_pathname
# workaround for GCP RHEL 7 known issue
# https://cloud.google.com/compute/docs/troubleshooting/known-issues#keyexpired
sed -i 's/repo_gpgcheck=1/repo_gpgcheck=0/g' /etc/yum.repos.d/google-cloud.repo
%{ endif ~}

install_packages $log_pathname
install_jq $log_pathname

docker_directory="/etc/docker"
echo "[Terraform Enterprise] Creating Docker directory at '$docker_directory'" | tee -a $log_pathname
mkdir -p $docker_directory
docker_daemon_pathname="$docker_directory/daemon.json"
echo "[Terraform Enterprise] Writing Docker daemon to '$docker_daemon_pathname'" | tee -a $log_pathname
echo "${docker_config}" | base64 --decode > $docker_daemon_pathname

%{ if proxy_ip != null ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Configure proxy" | tee -a $log_pathname
proxy_ip="${proxy_ip}"
proxy_port="${proxy_port}"
/bin/cat <<EOF >>/etc/environment
http_proxy="${proxy_ip}:${proxy_port}"
https_proxy="${proxy_ip}:${proxy_port}"
no_proxy="${no_proxy}"
EOF

/bin/cat <<EOF >/etc/profile.d/proxy.sh
http_proxy="${proxy_ip}:${proxy_port}"
https_proxy="${proxy_ip}:${proxy_port}"
no_proxy="${no_proxy}"
EOF

/bin/cat <<EOF >/etc/apt/apt.conf
Acquire::http::Proxy "http://${proxy_ip}:${proxy_port}";
Acquire::https::Proxy "http://${proxy_ip}:${proxy_port}";
EOF

export http_proxy="${proxy_ip}:${proxy_port}"
export https_proxy="${proxy_ip}:${proxy_port}"
export no_proxy="${no_proxy}"
%{ else ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Skipping proxy configuration" | tee -a $log_pathname
%{ endif ~}

%{ if certificate_secret_id != null ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Configure TlsBootstrapCert" | tee -a $log_pathname
certificate_data_b64=$(get_base64_secrets ${certificate_secret_id})
mkdir -p $(dirname ${tls_bootstrap_cert_pathname})
echo $certificate_data_b64 | base64 --decode > ${tls_bootstrap_cert_pathname}
%{ else ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Skipping TlsBootstrapCert configuration" | tee -a $log_pathname
%{ endif ~}

%{ if key_secret_id != null ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Configure TlsBootstrapKey" | tee -a $log_pathname
key_data_b64=$(get_base64_secrets ${key_secret_id})
mkdir -p $(dirname ${tls_bootstrap_key_pathname})
echo $key_data_b64 | base64 --decode > ${tls_bootstrap_key_pathname}
chmod 0600 ${tls_bootstrap_key_pathname}
%{ else ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Skipping TlsBootstrapKey configuration" | tee -a $log_pathname
%{ endif ~}
ca_certificate_directory="/dev/null"
ca_certificate_directory=/usr/local/share/ca-certificates/extra
ca_cert_filepath="$ca_certificate_directory/tfe-ca-certificate.crt"
%{ if ca_certificate_secret_id != null ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Configure CA cert" | tee -a $log_pathname
ca_certificate_data_b64=$(get_base64_secrets ${ca_certificate_secret_id})
mkdir -p $ca_certificate_directory
echo $ca_certificate_data_b64 | base64 --decode > $ca_cert_filepath
%{ else ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Skipping CA certificate configuration" | tee -a $log_pathname
%{ endif ~}

if [ -f "$ca_cert_filepath" ]
then
  update-ca-certificates
  system_ca_certificate_file="/etc/ssl/certs/ca-certificates.crt"
  cp $ca_cert_filepath ${tls_bootstrap_ca_pathname}
  tr -d "\\r" < "$ca_cert_filepath" >> "$system_ca_certificate_file"
fi

%{ if disk_path != null ~}
device="/dev/${disk_device_name}"
echo "[Terraform Enterprise] Checking disk at '$device' for EXT4 filesystem" | tee -a $log_pathname
if lsblk --fs $device | grep ext4
then
  echo "[Terraform Enterprise] EXT4 filesystem detected on disk at '$device'" | tee -a $log_pathname
else
  echo "[Terraform Enterprise] Creating EXT4 filesystem on disk at '$device'" | tee -a $log_pathname
  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard $device -F
fi
echo "[Terraform Enterprise] Creating mounted disk directory at '${disk_path}'" | tee -a $log_pathname
mkdir --parents ${disk_path}
echo "[Terraform Enterprise] Mounting disk '$device' to directory at '${disk_path}'" | tee -a $log_pathname
mount --options discard,defaults $device ${disk_path}
chmod og+rw ${disk_path}
echo "[Terraform Enterprise] Configuring automatic mounting of '$device' to directory at '${disk_path}' on reboot" | tee -a $log_pathname
echo "UUID=$(lsblk --noheadings --output uuid $device) ${disk_path} ext4 discard,defaults 0 2" >> /etc/fstab
%{ endif ~}

%{ if enable_monitoring ~}
install_monitoring_agents $log_pathname
%{ endif ~}

echo "[$(date +"%FT%T")] [Terraform Enterprise] Installing Docker Engine from Repository" | tee -a $log_pathname
curl --noproxy '*' --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg \
	| gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
	https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable" \
	| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get --assume-yes update
apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
apt-get --assume-yes autoremove


echo "[$(date +"%FT%T")] [Terraform Enterprise] Installing TFE FDO" | tee -a $log_pathname
hostname > /var/log/tfe-fdo.log
docker login -u="${registry_username}" -p="${registry_password}" ${registry}

export HOST_IP=$(hostname -i)

tfe_dir="/etc/tfe"
mkdir -p $tfe_dir

echo ${docker_compose} | base64 -d > $tfe_dir/compose.yaml

docker compose -f /etc/tfe/compose.yaml up -d


%{ if custom_image_tag != null ~}
%{ if length(regexall("^.+-docker\\.pkg\\.dev|^.*\\.?gcr\\.io", custom_image_tag)) > 0 ~}
echo "[Terraform Enterprise] Registering gcloud as a Docker credential helper" | tee -a
gcloud auth configure-docker --quiet ${split("/", custom_image_tag)[0]}

%{ endif ~}
echo "[Terraform Enterprise] Pulling custom worker image '${custom_image_tag}'" | tee -a
docker pull ${custom_image_tag}
%{ endif ~}
