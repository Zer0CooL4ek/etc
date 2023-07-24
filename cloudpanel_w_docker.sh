#!/bin/bash

# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/cloudpanel_w_docker.sh | bash
# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Update package list and upgrade installed packages
echo -e "${GREEN}Updating package list and upgrading installed packages${NC}"
apt update > /dev/null 2>&1 && sudo apt upgrade -y > /dev/null 2>&1 && sudo apt autoremove -y > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to update and upgrade packages${NC}"; exit 1; }

# Install sudo and curl packages
echo -e "${GREEN}Installing sudo and curl packages${NC}"
apt install sudo curl -y > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to install sudo and curl${NC}"; exit 1; }

# Download Docker installation script and execute it
echo -e "${GREEN}Downloading Docker installation script and executing it${NC}"
curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1 && sudo sh get-docker.sh > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to download and execute Docker installation script${NC}"; exit 1; }

# Add current user to docker group
echo -e "${GREEN}Adding current user to docker group${NC}"
usermod -aG docker $USER > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to add current user to docker group${NC}"; exit 1; }

# Download latest version of Docker Compose
echo -e "${GREEN}Downloading latest version of Docker Compose${NC}"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to download latest version of Docker Compose${NC}"; exit 1; }

# Change permissions of Docker Compose file to make it executable
echo -e "${GREEN}Changing permissions of Docker Compose file to make it executable${NC}"
chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to change permissions of Docker Compose file${NC}"; exit 1; }

# Download CloudPanel installation script, verify its checksum, and execute it with specified DB_ENGINE
echo -e "${GREEN}Downloading CloudPanel installation script, verifying its checksum, and executing it with specified DB_ENGINE${NC}"
curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh > /dev/null 2>&1; \
echo "3c30168958264ced81ca9b58dbc55b4d28585d9066b9da085f2b130ae91c50f6 install.sh" | \
sha256sum -c > /dev/null 2>&1 && sudo DB_ENGINE=MARIADB_10.11 bash install.sh > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to download, verify, and execute CloudPanel installation script${NC}"; exit 1; }

# Add crontab jobs for daily updates of CloudPanel, system, and Docker Compose (in one command)
echo -e "${GREEN}Adding crontab jobs for daily updates of CloudPanel, system, and Docker Compose (in one command)${NC}"
sh -c 'if ! grep -q "clp-update" /etc/crontab; then printf "\n# Update CloudPanel every day at 4 AM\n0 4 * * * root clp-update\n\n# Update system every day at 4:10 AM\n10 4 * * * root apt update && apt upgrade -y && apt autoremove -y\n\n# Update Docker Compose every day at 4:30 AM\n30 4 * * * root curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose\n" >> /etc/crontab; fi' > /dev/null 2>&1

# Clean cache and temporary files
echo -e "${GREEN}Cleaning cache and temporary files${NC}"
apt clean > /dev/null 2>&1 && rm -rf /tmp/* > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to clean cache and temporary files${NC}"; exit 1; }

echo "-= Checking current SSH port and changing it to 2224 if necessary =-"
if ! grep -q "^Port 2224" /etc/ssh/sshd_config; then
    sed -i 's/^#\?Port [0-9]*/Port 2224/' /etc/ssh/sshd_config > /dev/null 2>&1
    echo "SSH port has been changed to 2224"
else
    echo "SSH port is already set to 2224"
fi

# Modify SSH configuration file to disable password authentication and restart SSH service
echo "Modifying SSH configuration file to disable password authentication"
if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config > /dev/null 2>&1
    echo "PasswordAuthentication has been changed to no"
else
    echo "PasswordAuthentication is already set to no"
fi

# Restart SSH service
echo "Restarting SSH service"
service ssh restart > /dev/null 2>&1 || { echo -e "${RED}Error: Failed to restart SSH service${NC}"; exit 1; }

