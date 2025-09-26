#!/usr/bin/env bash
set -eu pipefail

${get_base64_secrets}
${install_packages}
%{ if enable_monitoring ~}
${install_monitoring_agents}
%{ endif ~}
%{ if database_azure_msi_auth_enabled ~}
${azurerm_database_init}
%{ endif ~}
${install_jq}

log_pathname="/var/log/startup.log"

install_packages $log_pathname
install_jq $log_pathname

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
ca_certificate_directory=/usr/share/pki/ca-trust-source/anchors
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
update-ca-trust
system_ca_certificate_file="/etc/pki/tls/certs/ca-bundle.crt"
cp $ca_cert_filepath ${tls_bootstrap_ca_pathname}
tr -d "\\r" < "$ca_cert_filepath" >> "$system_ca_certificate_file"
fi

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

%{ if database_azure_msi_auth_enabled ~}
azurerm_database_init $log_pathname
%{ endif ~}

echo "[$(date +"%FT%T")] [Terraform Enterprise] Installing Docker Engine from Repository" | tee -a $log_pathname

/bin/cat <<EOF > /etc/yum/pluginconf.d/subscription-manager.conf
[main]
enabled=0
EOF
yum install --assumeyes yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
os_release=$(cat /etc/os-release | grep VERSION_ID | sed "s/VERSION_ID=\"\(.*\)\"/\1/g")
if (( $(echo "$os_release < 8.0" | bc -l ) )); then
/bin/cat <<EOF >>/etc/yum.repos.d/docker-ce.repo
[centos-extras]
name=Centos extras - \$basearch
baseurl=http://mirror.centos.org/centos/7/extras/x86_64
enabled=1
gpgcheck=1
gpgkey=http://centos.org/keys/RPM-GPG-KEY-CentOS-7
EOF
fi
yum install --assumeyes docker-ce-${docker_version} docker-ce-cli-${docker_version} containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker


echo "[$(date +"%FT%T")] [Terraform Enterprise] Installing TFE FDO" | tee -a $log_pathname
hostname > /var/log/tfe-fdo.log
docker login -u="${registry_username}" -p="${registry_password}" ${registry}

export HOST_IP=$(hostname -i)

tfe_dir="/etc/tfe"
mkdir -p $tfe_dir

echo ${docker_compose} | base64 -d > $tfe_dir/compose.yaml

docker compose -f /etc/tfe/compose.yaml up -d
