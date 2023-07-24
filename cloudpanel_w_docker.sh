#!/bin/bash
#
# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/cloudpanel_w_docker.sh | bash
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

# Add crontab jobs for daily updates of CloudPanel, system, and Docker Compose (in one command)
echo -e "${GREEN}Adding crontab jobs for daily updates of CloudPanel, system, and Docker Compose (in one command)${NC}"
progress &
PROGRESS_PID=$!
sh -c 'if ! grep -q "clp-update" /etc/crontab; then printf "\n# Update CloudPanel every day at 4 AM\n0 4 * * * root clp-update\n\n# Update system every day at 4:10 AM\n10 4 * * * root apt update && apt upgrade -y && apt autoremove -y\n\n# Update Docker Compose every day at 4:30 AM\n30 4 * * * root curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose\n" >> /etc/crontab; fi' > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Crontab jobs added" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to add crontab jobs"; exit 1; }
kill $PROGRESS_PID

# Clean cache and temporary files
echo -e "${GREEN}Cleaning cache and temporary files${NC}"
progress &
PROGRESS_PID=$!
apt clean > /dev/null 2>&1 && rm -rf /tmp/* > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Cache and temporary files cleaned" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to clean cache and temporary files"; exit 1; }
kill $PROGRESS_PID

echo -e "${YELLOW}-= Checking current SSH port and changing it to 2224 if necessary =-${NC}"
if ! grep -q "^Port 2224" /etc/ssh/sshd_config; then
    sed -i 's/^#\?Port [0-9]*/Port 2224/' /etc/ssh/sshd_config
    echo -e "${GREEN}SSH port has been changed to 2224${NC}"
else
    echo -e "${GREEN}SSH port is already set to 2224${NC}"
fi

# Modify SSH configuration file to disable password authentication and restart SSH service
echo -e "${YELLOW}Modifying SSH configuration file to disable password authentication${NC}"
if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo -e "${GREEN}PasswordAuthentication has been changed to no${NC}"
else
    echo -e "${GREEN}PasswordAuthentication is already set to no${NC}"
fi

# Restart SSH service
echo -e "${YELLOW}Restarting SSH service${NC}"
service ssh restart || { echo -e "${RED}Error: Failed to restart SSH service${NC}"; exit 1; }
