#!/bin/bash

#
# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/def7.sh | bash
#

# ---------------------
# Configuration section
# ---------------------
readonly SSH_PORT=2224
readonly OLD_SSH_PORT=22
readonly PACKAGES=(sudo ca-certificates ufw curl htop neofetch)
readonly SPEEDTEST_URL="https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh"
readonly DOCKER_SCRIPT_URL="https://get.docker.com"
readonly DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"

# ---------------------
# Color and symbols
# ---------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
CHECKMARK="${GREEN}V${NC}"
CROSS="${RED}X${NC}"

# ---------------------
# Utility functions
# ---------------------
progress() {
    echo -n " "
    while true; do
        echo -n "."
        sleep 0.5
    done
}

run_step() {
    local description="$1"
    shift
    echo -n "$description..."
    "$@" >/dev/null 2>&1
    local status=$?
    if [ $status -eq 0 ]; then
        echo -e " ${CHECKMARK}"
    else
        echo -e " ${CROSS}"
        exit $status
    fi
}

# ---------------------
# Installation functions
# ---------------------
update_system() {
    progress &
    PROGRESS_PID=$!
    run_step "Updating system" apt update && apt upgrade -y && apt autoremove -y
    kill $PROGRESS_PID 2>/dev/null
}

install_packages() {
    progress &
    PROGRESS_PID=$!
    run_step "Installing packages: ${PACKAGES[*]}" apt install -y "${PACKAGES[@]}"
    kill $PROGRESS_PID 2>/dev/null
}

install_speedtest() {
    progress &
    PROGRESS_PID=$!
    run_step "Installing speedtest-cli" bash -c "curl -s $SPEEDTEST_URL | sudo bash && apt install speedtest -y"
    kill $PROGRESS_PID 2>/dev/null
}

clean_system() {
    progress &
    PROGRESS_PID=$!
    run_step "Cleaning cache and temporary files" bash -c "apt clean && rm -rf /tmp/*"
    kill $PROGRESS_PID 2>/dev/null
}

# ---------------------
# UFW configuration
# ---------------------
configure_ufw() {
    echo "Configuring UFW..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ${SSH_PORT}/tcp comment "Allow new SSH port"

    if ! ufw status | grep -q "active"; then
        ufw --force enable
    fi

    if ufw status | grep -q "${OLD_SSH_PORT}/tcp"; then
        ufw delete allow ${OLD_SSH_PORT}/tcp
    fi

    ufw reload
    echo -e "${CHECKMARK} UFW configured (SSH ${SSH_PORT} enabled, ${OLD_SSH_PORT} removed)"
}

# ---------------------
# SSH hardening
# ---------------------
setup_ssh() {
    # Change SSH port
    if ! grep -q "^Port ${SSH_PORT}" /etc/ssh/sshd_config; then
        sed -i "s/^#\?Port [0-9]*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
        echo -e "${CHECKMARK} SSH port set to ${SSH_PORT}"
    fi

    # Disable password authentication
    sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

    # PermitEmptyPasswords no
    sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords no/' /etc/ssh/sshd_config

    # MaxAuthTries 3
    sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/' /etc/ssh/sshd_config

    # MaxSessions 2
    sed -i 's/^#\?MaxSessions .*/MaxSessions 2/' /etc/ssh/sshd_config

    # ClientAliveInterval 300
    sed -i 's/^#\?ClientAliveInterval .*/ClientAliveInterval 300/' /etc/ssh/sshd_config

    # ClientAliveCountMax 0
    sed -i 's/^#\?ClientAliveCountMax .*/ClientAliveCountMax 0/' /etc/ssh/sshd_config

    # Restart SSH service
    run_step "Restarting SSH service" service ssh restart
}

# ---------------------
# Neofetch autostart
# ---------------------
add_neofetch() {
    if ! grep -q "neofetch" ~/.bashrc; then
        echo '[ -z "$PS1" ] || neofetch' >> ~/.bashrc
        echo -e "${CHECKMARK} Neofetch added to .bashrc"
    fi
}

# ---------------------
# Docker installation
# ---------------------
docker_install() {
    run_step "Installing Docker" bash -c "curl -fsSL $DOCKER_SCRIPT_URL -o get-docker.sh && sudo sh get-docker.sh"
    run_step "Adding user to docker group" usermod -aG docker "$USER"
    run_step "Installing Docker Compose" bash -c "curl -L $DOCKER_COMPOSE_URL -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose"
}

# ---------------------
# Main menu
# ---------------------
main() {
    echo -e "${GREEN}Please choose installation type:${NC}"
    echo "1) Base installation only"
    echo "2) Base installation with Docker"

    # <--- use /dev/tty to force interactive input even in pipe
    read -rp "Enter your choice (1 or 2): " choice < /dev/tty

    update_system
    install_packages
    configure_ufw
    setup_ssh
    install_speedtest
    clean_system
    add_neofetch

    case $choice in
        2) docker_install ;;
        1) ;;
        *) echo -e "${RED}Invalid choice. Exiting.${NC}"; exit 1 ;;
    esac

    if [ -f /var/run/reboot-required ]; then
        echo -e "${RED}Reboot is required, rebooting in 10 seconds...${NC}"
        sleep 10
        reboot
    else
        echo -e "${GREEN}No reboot required${NC}"
    fi
}

main
