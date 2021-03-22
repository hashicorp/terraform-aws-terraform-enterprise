#!/usr/bin/env bash

apt_packages() {
	sudo apt update -y
	sudo apt install unzip -y
}

dnf_packages() {
	sudo dnf update -y
	sudo dnf install unzip -y
}

yum_packages() {
	sudo yum update -y
	sudo yum install unzip -y
}

detect_distro() {
    DISTRO_NAME=$(grep "^NAME=" /etc/os-release | cut -d"\"" -f2)
    MAJOR_VERSION=$(grep "^VERSION=" /etc/os-release | cut -d"\"" -f2 | cut -b1)
    
    case "$DISTRO_NAME" in
    	"Red Hat"*)
    		if [[ "$MAJOR_VERSION" == "7" ]]; then
    			yum_packages
    		fi
    		if [[ "$MAJOR_VERSION" == "8" ]]; then
    			dnf_packages
    		fi
                BASTION_USER="ec2-user"
    		;;
    	"Ubuntu"*)
    		apt_packages
                BASTION_USER="ubuntu"
    		;;
    esac
}

detect_distro

echo "${tfe_bastion_private_key}" > /home/$BASTION_USER/.ssh/tfe
sudo chown $BASTION_USER:$BASTION_USER /home/$BASTION_USER/.ssh/tfe
sudo chown $BASTION_USER:$BASTION_USER /home/$BASTION_USER/.ssh
sudo chmod 600 /home/$BASTION_USER/.ssh/tfe
sudo chmod 600 /home/$BASTION_USER/.ssh/authorized_keys