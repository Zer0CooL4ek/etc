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

# Function for base installation
base_installation() {
    echo -e "${GREEN}Performing base installation...${NC}"
    
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

    # Add Neofetch to .bashrc for autostart
    echo -e "${GREEN}Adding Neofetch to .bashrc for autostart${NC}"
    if ! grep -q "neofetch" ~/.bashrc; then
        echo 'neofetch' >> ~/.bashrc
        echo -e "${CHECKMARK} Neofetch added to .bashrc for autostart"
    else
        echo -e "${CHECKMARK} Neofetch is already in .bashrc"
    fi

    # Check if a reboot is required after package updates
    if [ -f /var/run/reboot-required ]; then
        echo -e "${RED}Reboot is required, rebooting in 10 seconds...${NC}"
        sleep 10
        reboot
    else
        echo -e "${GREEN}No reboot required${NC}"
    fi
}

# Function for Docker installation
docker_installation() {
    echo -e "${GREEN}Performing Docker installation...${NC}"

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

# Selection logic
echo -e "${YELLOW}Select installation type:${NC}"
echo "1) Base installation"
echo "2) Base installation with Docker"
read -r choice < /dev/tty

case $choice in
    1)
        base_installation
        ;;
    2)
        base_installation
        docker_installation
        ;;
    *)
        echo -e "${RED}❌ Invalid choice. Exiting...${NC}"
        exit 1
        ;;
esac
