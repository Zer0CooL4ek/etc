#!/bin/bash

# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/cloudpanel_w_docker.sh | bash

# Update package list and upgrade installed packages
echo "Updating package list and upgrading installed packages"
apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y

# Install sudo and curl packages
echo "Installing sudo and curl packages"
apt-get install sudo curl -y

# Modify SSH configuration file to disable password authentication and restart SSH service
echo "Modifying SSH configuration file to disable password authentication"
if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo "PasswordAuthentication has been changed to no"
else
    echo "PasswordAuthentication is already set to no"
fi


# Add crontab jobs for daily updates of CloudPanel, system, and Docker Compose (in one command)
echo "Adding crontab jobs for daily updates of CloudPanel, system, and Docker Compose (in one command)"
sh -c 'if ! grep -q "clp-update" /etc/crontab; then printf "\n# Update CloudPanel every day at 4 AM\n0 4 * * * root clp-update\n\n# Update system every day at 4:10 AM\n10 4 * * * root apt-get update && apt-get upgrade -y && apt-get autoremove -y\n\n# Update Docker Compose every day at 4:30 AM\n30 4 * * * root curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose\n" >> /etc/crontab; fi'
