#!/bin/bash

#
# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/docker.sh | bash
#

# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define symbol variables
CHECKMARK="${GREEN}V${NC}"
CROSS="${RED}X${NC}"
MINUS="${YELLOW}-${NC}"

# Function to display progress animation
progress() {
    echo -n " "
    while true; do
        echo -n "."
        sleep 0.5
    done
}

# Update package list and upgrade installed packages
echo -e "${GREEN}Updating package list and upgrading installed packages${NC}"
progress &
PROGRESS_PID=$!
apt update > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt autoremove -y > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Package list updated and installed packages upgraded" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to update and upgrade packages"; exit 1; }
kill $PROGRESS_PID

# Install sudo and curl packages
echo -e "${GREEN}Installing sudo and curl packages${NC}"
progress &
PROGRESS_PID=$!
apt install sudo curl -y > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Sudo and curl packages installed" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to install sudo and curl"; exit 1; }
kill $PROGRESS_PID

# Download Docker installation script and execute it
echo -e "${GREEN}Downloading Docker installation script and executing it${NC}"
progress &
PROGRESS_PID=$!
curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1 && sudo sh get-docker.sh > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Docker installation script downloaded and executed" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to download and execute Docker installation script"; exit 1; }
kill $PROGRESS_PID

# Add current user to docker group
echo -e "${GREEN}Adding current user to docker group${NC}"
progress &
PROGRESS_PID=$!
usermod -aG docker $USER > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Current user added to docker group" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to add current user to docker group"; exit 1; }
kill $PROGRESS_PID

# Download latest version of Docker Compose
echo -e "${GREEN}Downloading latest version of Docker Compose${NC}"
progress &
PROGRESS_PID=$!
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Latest version of Docker Compose downloaded" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to download latest version of Docker Compose"; exit 1; }
kill $PROGRESS_PID

# Change permissions of Docker Compose file to make it executable
echo -e "${GREEN}Changing permissions of Docker Compose file to make it executable${NC}"
progress &
PROGRESS_PID=$!
chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Permissions of Docker Compose file changed" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to change permissions of Docker Compose file"; exit 1; }
kill $PROGRESS_PID

# Clean cache and temporary files
echo -e "${GREEN}Cleaning cache and temporary files${NC}"
progress &
PROGRESS_PID=$!
apt clean > /dev/null 2>&1 && rm -rf /tmp/* > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Cache and temporary files cleaned" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to clean cache and temporary files"; exit 1; }
kill $PROGRESS_PID

# Check current SSH port and changing it to 2224 if necessary
echo -e "${GREEN}Checking current SSH port and changing it to 2224 if necessary${NC}"
if ! grep -q "^Port 2224" /etc/ssh/sshd_config; then
    sed -i 's/^#\?Port [0-9]*/Port 2224/' /etc/ssh/sshd_config
    echo -e "\r${CHECKMARK} SSH port has been changed to 2224"
else
    echo -e "\r${CHECKMARK} SSH port is already set to 2224"
fi

# Modify SSH configuration file to disable password authentication and restart SSH service
echo -e "${GREEN}Modifying SSH configuration file to disable password authentication${NC}"
if grep -q "^#\?PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo -e "\r${CHECKMARK} PasswordAuthentication has been changed to no"
else
    echo -e "\r${CHECKMARK} PasswordAuthentication is already set to no"
fi


# Restart SSH service
echo -e "${GREEN}Restarting SSH service${NC}"
service ssh restart > /dev/null 2>&1 && echo -e "\r${CHECKMARK} SSH service restarted" || { echo -e "\r${CROSS} Error: Failed to restart SSH service"; exit 1; }
