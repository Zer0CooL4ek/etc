#!/bin/bash

#
# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/def2.sh | bash
#

# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define symbol variables
CHECKMARK="${GREEN}✔️${NC}"
CROSS="${RED}❌${NC}"
MINUS="${YELLOW}➖${NC}"

# Function to display progress animation
progress() {
    echo -n " "
    while true; do
        echo -n "."
        sleep 0.5
    done
}

# Base installation process
base_install() {
    echo -e "${GREEN}Updating package list and upgrading installed packages...${NC}"
    progress & 
    PROGRESS_PID=$!
    apt update > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt autoremove -y > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Package list updated and installed packages upgraded" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to update and upgrade packages"; exit 1; }
    kill $PROGRESS_PID

    echo -e "${GREEN}Installing sudo, curl, htop, and neofetch packages...${NC}"
    progress &
    PROGRESS_PID=$!
    apt install sudo curl htop neofetch -y > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Sudo, curl, htop, and neofetch packages installed" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to install packages"; exit 1; }
    kill $PROGRESS_PID

    echo -e "${GREEN}Cleaning cache and temporary files...${NC}"
    progress &
    PROGRESS_PID=$!
    apt clean > /dev/null 2>&1 && rm -rf /tmp/* > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Cache and temporary files cleaned" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to clean cache and temporary files"; exit 1; }
    kill $PROGRESS_PID

    # Check and modify SSH settings
    echo -e "${GREEN}Checking current SSH port and changing it to 2224 if necessary...${NC}"
    if ! grep -q "^Port 2224" /etc/ssh/sshd_config; then
        sed -i 's/^#\?Port [0-9]*/Port 2224/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} SSH port has been changed to 2224"
    else
        echo -e "\r${CHECKMARK} SSH port is already set to 2224"
    fi

    echo -e "${GREEN}Modifying SSH configuration file to disable password authentication...${NC}"
    if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        echo -e "\r${CHECKMARK} PasswordAuthentication is already set to no"
    else
        sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} PasswordAuthentication has been changed to no"
    fi

    # Additional SSH settings
    echo -e "${GREEN}Setting PermitEmptyPasswords to no...${NC}"
    sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    echo -e "\r${CHECKMARK} PermitEmptyPasswords has been set to no"

    echo -e "${GREEN}Setting MaxAuthTries to 3...${NC}"
    sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/' /etc/ssh/sshd_config
    echo -e "\r${CHECKMARK} MaxAuthTries has been set to 3"

    echo -e "${GREEN}Setting MaxSessions to 2...${NC}"
    sed -i 's/^#\?MaxSessions .*/MaxSessions 2/' /etc/ssh/sshd_config
    echo -e "\r${CHECKMARK} MaxSessions has been set to 2"

    echo -e "${GREEN}Setting ClientAliveInterval to 300...${NC}"
    sed -i 's/^#\?ClientAliveInterval .*/ClientAliveInterval 300/' /etc/ssh/sshd_config
    echo -e "\r${CHECKMARK} ClientAliveInterval has been set to 300"

    echo -e "${GREEN}Setting ClientAliveCountMax to 0...${NC}"
    sed -i 's/^#\?ClientAliveCountMax .*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
    echo -e "\r${CHECKMARK} ClientAliveCountMax has been set to 0"

    echo -e "${GREEN}Restarting SSH service...${NC}"
    service ssh restart > /dev/null 2>&1 && echo -e "\r${CHECKMARK} SSH service restarted" || { echo -e "\r${CROSS} Error: Failed to restart SSH service"; exit 1; }

    echo -e "${GREEN}Adding Neofetch to .bashrc for autostart...${NC}"
    if ! grep -q "neofetch" ~/.bashrc; then
        echo 'neofetch' >> ~/.bashrc
        echo -e "${CHECKMARK} Neofetch added to .bashrc for autostart"
    else
        echo -e "${CHECKMARK} Neofetch is already in .bashrc"
    fi
}

# Docker installation process
docker_install() {
    echo -e "${GREEN}Downloading Docker installation script and executing it...${NC}"
    progress & 
    PROGRESS_PID=$!
    curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1 && sudo sh get-docker.sh > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Docker installation script downloaded and executed" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to download and execute Docker installation script"; exit 1; }
    kill $PROGRESS_PID

    echo -e "${GREEN}Adding current user to docker group...${NC}"
    progress &
    PROGRESS_PID=$!
    usermod -aG docker $USER > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Current user added to docker group" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to add current user to docker group"; exit 1; }
    kill $PROGRESS_PID

    echo -e "${GREEN}Downloading latest version of Docker Compose...${NC}"
    progress &
    PROGRESS_PID=$!
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Latest version of Docker Compose downloaded" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to download latest version of Docker Compose"; exit 1; }
    kill $PROGRESS_PID

    echo -e "${GREEN}Changing permissions of Docker Compose file to make it executable...${NC}"
    progress &
    PROGRESS_PID=$!
    chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Permissions of Docker Compose file changed" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to change permissions of Docker Compose file"; exit 1; }
    kill $PROGRESS_PID
}

# Function to check if a reboot is required
check_reboot() {
    if [ -f /var/run/reboot-required ]; then
        echo -e "${RED}Reboot is required, rebooting in 10 seconds...${NC}"
        sleep 10
        reboot
    else
        echo -e "${GREEN}No reboot required${NC}"
    fi
}

# Main script execution
echo -e "${YELLOW}Select installation type:${NC}"
echo "1) Base installation"
echo "2) Base installation with Docker"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        base_install
        check_reboot
        ;;
    2)
        base_install
        docker_install
        check_reboot
        ;;
    *)
        echo -e "${CROSS} Invalid choice. Exiting...${NC}"
        exit 1
        ;;
esac
