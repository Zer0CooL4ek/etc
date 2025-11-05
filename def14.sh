#!/bin/bash

#
# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/def14.sh | bash
#

# ---------------------
# Configuration section
# ---------------------
readonly SSH_PORT=2224
readonly OLD_SSH_PORT=22
readonly PACKAGES=(sudo ca-certificates ufw curl cron htop neofetch)
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
CHECKMARK="${GREEN}✔${NC}"
CROSS="${RED}✖${NC}"

# ---------------------
# Spinner functions
# ---------------------
spinner() {
    local pid=$1
    local desc="$2"
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r[%c] %s" "${spinstr:$i:1}" "$desc"
            sleep $delay
        done
    done
    printf "\r"
}

run_step() {
    local description="$1"
    shift
    printf "%-60s" "$description..."
    "$@" >/dev/null 2>&1 &
    local cmd_pid=$!
    spinner $cmd_pid "$description"
    wait $cmd_pid
    local status=$?
    if [ $status -eq 0 ]; then
        echo -e "\r$description...${CHECKMARK}"
    else
        echo -e "\r$description...${CROSS}"
        exit $status
    fi
}

# ---------------------
# Installation functions
# ---------------------
update_system() {
    run_step "Updating system (apt update & upgrade)" bash -c "apt update && apt upgrade -y && apt autoremove -y"
}

install_packages() {
    run_step "Installing packages: ${PACKAGES[*]}" bash -c "apt install -y ${PACKAGES[*]}"
}

install_speedtest() {
    run_step "Installing speedtest-cli" bash -c "curl -s $SPEEDTEST_URL | sudo bash && apt install -y speedtest"
}

clean_system() {
    run_step "Cleaning cache and temporary files" bash -c "apt clean && rm -rf /tmp/*"
}

# ---------------------
# UFW configuration
# ---------------------
configure_ufw() {
    run_step "Configuring UFW" bash -c "
        ufw default deny incoming >/dev/null 2>&1
        ufw default allow outgoing >/dev/null 2>&1
        ufw allow ${SSH_PORT}/tcp comment 'Allow new SSH port' >/dev/null 2>&1
        ufw --force enable >/dev/null 2>&1
        if ufw status | grep -q '${OLD_SSH_PORT}/tcp'; then
            ufw delete allow ${OLD_SSH_PORT}/tcp >/dev/null 2>&1
        fi
        ufw reload >/dev/null 2>&1
    "
}

# ---------------------
# SSH hardening
# ---------------------
setup_ssh() {
    run_step "Setting SSH port to ${SSH_PORT}" sed -i "s/^#\?Port [0-9]*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
    run_step "Disabling password authentication" sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    run_step "Disabling empty passwords" sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    run_step "Setting MaxAuthTries=3" sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/' /etc/ssh/sshd_config
    run_step "Setting MaxSessions=2" sed -i 's/^#\?MaxSessions .*/MaxSessions 2/' /etc/ssh/sshd_config
    run_step "Setting ClientAliveInterval=300" sed -i 's/^#\?ClientAliveInterval .*/ClientAliveInterval 300/' /etc/ssh/sshd_config
    run_step "Setting ClientAliveCountMax=0" sed -i 's/^#\?ClientAliveCountMax .*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
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

    # Silent finish, no UFW status output
    if [ -f /var/run/reboot-required ]; then
        echo -e "${RED}Reboot is required, rebooting in 10 seconds...${NC}"
        sleep 10
        reboot
    else
        echo -e "${GREEN}All done! No reboot required${NC}"
    fi
}

main
