#!/bin/bash

# Update package list and upgrade installed packages
apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y

# Install sudo and curl packages
apt-get install sudo curl -y

# Modify SSH configuration file to disable password authentication and restart SSH service
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo service ssh restart

# Download Docker installation script and execute it
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# Add current user to docker group
usermod -aG docker $USER

# Download latest version of Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Change permissions of Docker Compose file to make it executable
chmod +x /usr/local/bin/docker-compose

# Download CloudPanel installation script, verify its checksum, and execute it with specified DB_ENGINE
curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh; \
echo "3c30168958264ced81ca9b58dbc55b4d28585d9066b9da085f2b130ae91c50f6 install.sh" | \
sha256sum -c && sudo DB_ENGINE=MARIADB_10.11 bash install.sh

# Add crontab jobs for daily updates of CloudPanel, system, and Docker Compose (in one command)
sh -c 'printf "\n# Update CloudPanel every day at 4 AM\n0 4 * * * root clp-update\n\n# Update system every day at 4:10 AM\n10 4 * * * root apt-get update && apt-get upgrade -y && apt-get autoremove -y\n\n# Update Docker Compose every day at 4:30 AM\n30 4 * * * root curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose\n" >> /etc/crontab'
