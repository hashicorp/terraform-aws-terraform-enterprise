#!/usr/bin/env bash
set -euo pipefail

${retry}
${get_base64_secrets}
${install_packages}
${install_monitoring_agents}

log_pathname="/var/log/ptfe.log"
tfe_settings_file="ptfe-settings.json"
tfe_settings_path="/etc/$tfe_settings_file"

# -----------------------------------------------------------------------------
# Patching GCP Yum repo configuration (if GCP environment)
# -----------------------------------------------------------------------------
%{ if cloud == "google" && distribution == "rhel" ~}
echo "[Terraform Enterprise] Patching GCP Yum repo configuration" | tee -a $log_pathname
# workaround for GCP RHEL 7 known issue
# https://cloud.google.com/compute/docs/troubleshooting/known-issues#keyexpired
sed -i 's/repo_gpgcheck=1/repo_gpgcheck=0/g' /etc/yum.repos.d/google-cloud.repo
%{ endif ~}

# -----------------------------------------------------------------------------
# Install jq and cloud specific packages (if not an airgapped environment)
# -----------------------------------------------------------------------------
%{ if (airgap_url == null && airgap_pathname == null) || (airgap_url != null && airgap_pathname != null) ~}
install_packages $log_pathname

echo "[$(date +"%FT%T")] [Terraform Enterprise] Install JQ" | tee -a $log_pathname
sudo curl --noproxy '*' -Lo /bin/jq https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-$(uname -m | grep -q "arm\|aarch" && echo "arm64" || echo "amd64")
sudo chmod +x /bin/jq

%{ endif ~}

# -----------------------------------------------------------------------------
# Create TFE & Replicated Settings Files
# -----------------------------------------------------------------------------
echo "[$(date +"%FT%T")] [Terraform Enterprise] Create configuration files" | tee -a $log_pathname
sudo echo "${settings}" | sudo base64 -d > $tfe_settings_path
echo "${replicated}" | base64 -d > /etc/replicated.conf

# -----------------------------------------------------------------------------
# Configure Docker (if GCP environment)
# -----------------------------------------------------------------------------
%{ if cloud == "google" ~}
docker_directory="/etc/docker"
echo "[Terraform Enterprise] Creating Docker directory at '$docker_directory'" | tee -a $log_pathname
mkdir -p $docker_directory
docker_daemon_pathname="$docker_directory/daemon.json"
echo "[Terraform Enterprise] Writing Docker daemon to '$docker_daemon_pathname'" | tee -a $log_pathname
echo "${docker_config}" | base64 --decode > $docker_daemon_pathname
%{ endif ~}

# -----------------------------------------------------------------------------
# Configure the proxy (if applicable)
# -----------------------------------------------------------------------------
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

export http_proxy="${proxy_ip}:${proxy_port}"
export https_proxy="${proxy_ip}:${proxy_port}"
export no_proxy="${no_proxy}"
%{ else ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Skipping proxy configuration" | tee -a $log_pathname
%{ endif ~}

# -----------------------------------------------------------------------------
# Configure TLS (if not an airgapped environment)
# -----------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Configure CA Certificate (if not an airgapped environment)
#------------------------------------------------------------------------------
ca_certificate_directory="/dev/null"

%{ if distribution == "rhel" || distribution == "amazon-linux-2023" ~}
ca_certificate_directory=/usr/share/pki/ca-trust-source/anchors
%{ else ~}
ca_certificate_directory=/usr/local/share/ca-certificates/extra
%{ endif ~}
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
	%{ if distribution == "rhel" || distribution == "amazon-linux-2023" ~}
	update-ca-trust

	%{ else ~}
	update-ca-certificates
	%{ endif ~}

	jq ". + { ca_certs: { value: \"$(/bin/cat $ca_cert_filepath)\" } }" -- $tfe_settings_path > $tfe_settings_file.updated
	cp ./$tfe_settings_file.updated $tfe_settings_path
fi

# -----------------------------------------------------------------------------
# Resize RHEL logical volume (if Azure environment)
# -----------------------------------------------------------------------------
%{ if cloud == "azurerm" && distribution == "rhel" ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Resize RHEL logical volume" | tee -a $log_pathname

terminal_partition=$(parted --script /dev/disk/cloud/azure_root u s p | tail -2 | head -n 1)
terminal_partition_number=$(echo $${terminal_partition:0:3} | xargs)
terminal_partition_link=/dev/disk/cloud/azure_root-part$terminal_partition_number
# Because Microsoft is publishing only LVM-partitioned images, it is necessary to partition it to the specs that TFE requires.
# First, extend the partition to fill available space
growpart /dev/disk/cloud/azure_root $terminal_partition_number
# Resize the physical volume
pvresize $terminal_partition_link
# Then resize the logical volumes to meet TFE specs
lvresize -r -L 10G /dev/mapper/rootvg-rootlv
lvresize -r -L 40G /dev/mapper/rootvg-varlv
%{ endif ~}

# -----------------------------------------------------------------------------
# Configure Mounted Disk Installation
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Install Monitoring Agents
# -----------------------------------------------------------------------------
%{ if enable_monitoring ~}
install_monitoring_agents $log_pathname
%{ endif ~}

# -----------------------------------------------------------------------------
# Retrieve TFE license (if not an airgapped environment)
# -----------------------------------------------------------------------------
%{ if tfe_license_secret_id != null ~}
echo "[$(date +"%FT%T")] [Terraform Enterprise] Retrieve TFE license" | tee -a $log_pathname
license=$(get_base64_secrets ${tfe_license_secret_id})
echo $license | base64 -d > ${tfe_license_file_location}
%{ endif ~}

# -----------------------------------------------------------------------------
# Download Replicated
# -----------------------------------------------------------------------------
replicated_directory="/etc/replicated"

%{ if airgap_url != null && airgap_pathname != null ~}
# Bootstrap airgapped environment with prerequisites (for dev/test environments)
echo "[Terraform Enterprise] Installing Docker Engine from Repository for Bootstrapping an Airgapped Installation" | tee -a $log_pathname

	%{ if distribution == "rhel" ~}
	yum install --assumeyes yum-utils
	yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
	yum install --assumeyes docker-ce docker-ce-cli containerd.io
	%{ else ~}
	apt-get --assume-yes update
	apt-get --assume-yes install \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
	curl --noproxy '*' --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg \
		| gpg --dearmor --output /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
		https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable" \
		| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get --assume-yes update
	apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
	apt-get --assume-yes autoremove
	%{ endif ~}

replicated_filename="replicated.tar.gz"
replicated_url="https://s3.amazonaws.com/replicated-airgap-work/$replicated_filename"
replicated_pathname="$replicated_directory/$replicated_filename"

echo "[Terraform Enterprise] Downloading Replicated from '$replicated_url' to '$replicated_pathname'" | tee -a $log_pathname
curl --noproxy '*' --create-dirs --output "$replicated_pathname" "$replicated_url"
echo "[Terraform Enterprise] Extracting Replicated in '$replicated_directory'" | tee -a $log_pathname
tar --directory "$replicated_directory" --extract --file "$replicated_pathname"

echo "[Terraform Enterprise] Copying airgap package '${airgap_url}' to '${airgap_pathname}'" | tee -a $log_pathname
curl --noproxy '*' --create-dirs --output "${airgap_pathname}" "${airgap_url}"
%{ else ~}
echo "[Terraform Enterprise] Skipping Airgapped Replicated download" | tee -a $log_pathname
%{ endif ~}

# -----------------------------------------------------------------------------
# Install Terraform Enterprise
# -----------------------------------------------------------------------------
echo "[$(date +"%FT%T")] [Terraform Enterprise] Install TFE" | tee -a $log_pathname

%{ if cloud == "azurerm" ~}
instance_ip=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq '.network.interface[0].ipv4.ipAddress[0].privateIpAddress' -r)
%{ else ~}
instance_ip=$(hostname -i)
%{ endif ~}

install_pathname="$replicated_directory/install.sh"

%{ if airgap_pathname == null ~}
curl --noproxy '*' --create-dirs --output $install_pathname https://get.replicated.com/docker/terraformenterprise/active-active
%{ endif ~}

chmod +x $install_pathname
cd $replicated_directory
$install_pathname \
	fast-timeouts \
	bypass-firewalld-warning \
	%{ if proxy_ip != null ~}
	http-proxy="${proxy_ip}:${proxy_port}" \
	additional-no-proxy="${no_proxy}" \
	%{ else ~}
	no-proxy \
	%{ endif ~}
	%{if active_active ~}
	disable-replicated-ui \
	%{ endif ~}
	private-address="$instance_ip" \
	public-address="$instance_ip" \
	%{ if airgap_pathname != null ~}
	airgap \
	%{ endif ~}
	%{ if distribution == "amazon-linux-2023" ~}
	no-docker \
	%{ endif ~}
	| tee -a $log_pathname

# -----------------------------------------------------------------------------
# Add docker0 to firewalld (for Red Hat instances only)
# -----------------------------------------------------------------------------
%{ if distribution == "amazon-linux-2023" || distribution == "rhel" && cloud != "google" ~}
os_release=$(cat /etc/os-release | grep VERSION_ID | sed "s/VERSION_ID=\"\(.*\)\"/\1/g")
if (( $(echo "$os_release < 8.0" | bc -l ) )); then
  echo "[$(date +"%FT%T")] [Terraform Enterprise] Disable SELinux (temporary)" | tee -a $log_pathname
  setenforce 0
  echo "[$(date +"%FT%T")] [Terraform Enterprise] Add docker0 to firewalld" | tee -a $log_pathname
  firewall-cmd --permanent --zone=trusted --change-interface=docker0
  firewall-cmd --reload
  echo "[$(date +"%FT%T")] [Terraform Enterprise] Enable SELinux" | tee -a $log_pathname
  setenforce 1
fi
%{ endif ~}

# -----------------------------------------------------------------------------
# Pulling custom worker image (currently for GCP environments only)
# -----------------------------------------------------------------------------
%{ if custom_image_tag != null && cloud == "google" ~}
%{ if length(regexall("^.+-docker\\.pkg\\.dev|^.*\\.?gcr\\.io", custom_image_tag)) > 0 ~}
echo "[Terraform Enterprise] Registering gcloud as a Docker credential helper" | tee -a
gcloud auth configure-docker --quiet ${split("/", custom_image_tag)[0]}

%{ endif ~}
echo "[Terraform Enterprise] Pulling custom worker image '${custom_image_tag}'" | tee -a
docker pull ${custom_image_tag}
%{ endif ~}
