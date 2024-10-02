#!/bin/bash

#
# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/def3.sh | bash
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

# Function for base setup
base_setup() {
    # Update package list and upgrade installed packages
    echo -e "${GREEN}Updating package list and upgrading installed packages${NC}"
    progress &
    PROGRESS_PID=$!
    apt update > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt autoremove -y > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Package list updated and installed packages upgraded" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to update and upgrade packages"; exit 1; }
    kill $PROGRESS_PID

    # Install sudo, curl, htop, and neofetch packages
    echo -e "${GREEN}Installing sudo, curl, htop, and neofetch packages${NC}"
    progress &
    PROGRESS_PID=$!
    apt install sudo curl htop neofetch -y > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Sudo, curl, htop, and neofetch packages installed" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to install packages"; exit 1; }
    kill $PROGRESS_PID

    # Clean cache and temporary files
    echo -e "${GREEN}Cleaning cache and temporary files${NC}"
    progress &
    PROGRESS_PID=$!
    apt clean > /dev/null 2>&1 && rm -rf /tmp/* > /dev/null 2>&1 && echo -e "\r${CHECKMARK} Cache and temporary files cleaned" || { kill $PROGRESS_PID; echo -e "\r${CROSS} Error: Failed to clean cache and temporary files"; exit 1; }
    kill $PROGRESS_PID

    # SSH configuration (не изменяется)
    echo -e "${GREEN}Checking current SSH port and changing it to 2224 if necessary${NC}"
    if ! grep -q "^Port 2224" /etc/ssh/sshd_config; then
        sed -i 's/^#\?Port [0-9]*/Port 2224/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} SSH port has been changed to 2224"
    else
        echo -e "\r${CHECKMARK} SSH port is already set to 2224"
    fi

    echo -e "${GREEN}Modifying SSH configuration file to disable password authentication${NC}"
    if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        echo -e "\r${CHECKMARK} PasswordAuthentication is already set to no"
    else
        sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} PasswordAuthentication has been changed to no"
    fi

    echo -e "${GREEN}Setting PermitEmptyPasswords to no${NC}"
    if grep -q "^PermitEmptyPasswords no" /etc/ssh/sshd_config; then
        echo -e "\r${CHECKMARK} PermitEmptyPasswords is already set to no"
    else
        sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} PermitEmptyPasswords has been set to no"
    fi

    echo -e "${GREEN}Setting MaxAuthTries to 3${NC}"
    if grep -q "^MaxAuthTries 3" /etc/ssh/sshd_config; then
        echo -e "\r${CHECKMARK} MaxAuthTries is already set to 3"
    else
        sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} MaxAuthTries has been set to 3"
    fi

    echo -e "${GREEN}Setting MaxSessions to 2${NC}"
    if grep -q "^MaxSessions 2" /etc/ssh/sshd_config; then
        echo -e "\r${CHECKMARK} MaxSessions is already set to 2"
    else
        sed -i 's/^#\?MaxSessions .*/MaxSessions 2/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} MaxSessions has been set to 2"
    fi

    echo -e "${GREEN}Setting ClientAliveInterval to 300${NC}"
    if grep -q "^ClientAliveInterval 300" /etc/ssh/sshd_config; then
        echo -e "\r${CHECKMARK} ClientAliveInterval is already set to 300"
    else
        sed -i 's/^#\?ClientAliveInterval .*/ClientAliveInterval 300/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} ClientAliveInterval has been set to 300"
    fi

    echo -e "${GREEN}Setting ClientAliveCountMax to 0${NC}"
    if grep -q "^ClientAliveCountMax 0" /etc/ssh/sshd_config; then
        echo -e "\r${CHECKMARK} ClientAliveCountMax is already set to 0"
    else
        sed -i 's/^#\?ClientAliveCountMax .*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
        echo -e "\r${CHECKMARK} ClientAliveCountMax has been set to 0"
    fi

    echo -e "${GREEN}Restarting SSH service${NC}"
    service ssh restart > /dev/null 2>&1 && echo -e "\r${CHECKMARK} SSH service restarted" || { echo -e "\r${CROSS} Error: Failed to restart SSH service"; exit 1; }

    echo -e "${GREEN}Adding Neofetch to .bashrc for autostart${NC}"
    if ! grep -q "neofetch" ~/.bashrc; then
        echo 'neofetch' >> ~/.bashrc
        echo -e "${CHECKMARK} Neofetch added to .bashrc for autostart"
    else
        echo -e "${CHECKMARK} Neofetch is already in .bashrc"
    fi
}

# Function to install Docker
docker_setup() {
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
}

# Main script
echo -e "${YELLOW}Choose the setup option:${NC}"
echo -e "1) Base"
echo -e "2) Base with Docker"

# Automatically assign choice without waiting for Enter
choice=2  # Выберите 1 или 2 по умолчанию

case "$choice" in
    1)
        echo -e "${GREEN}You have selected base setup${NC}"
        base_setup
        ;;
    2)
        echo -e "${GREEN}You have selected base with Docker setup${NC}"
        base_setup
        docker_setup
        ;;
    *)
        echo -e "${RED}Invalid choice, exiting...${NC}"
        exit 1
        ;;
esac

# Check if a reboot is required after package updates
if [ -f /var/run/reboot-required ]; then
    echo -e "${RED}Reboot is required, rebooting in 10 seconds...${NC}"
    sleep 10
    reboot
else
    echo -e "${GREEN}No reboot required${NC}"
fi
