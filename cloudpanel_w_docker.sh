#!/bin/bash

# wget -qO- https://raw.githubusercontent.com/Zer0CooL4ek/etc/main/cloudpanel_w_docker.sh | bash

# Обновление списка пакетов и обновление установленных пакетов
echo "Обновление списка пакетов и обновление установленных пакетов"
apt-get update > /dev/null && sudo apt-get upgrade -y > /dev/null && sudo apt-get autoremove -y > /dev/null

# Установка пакетов sudo и curl
echo "Установка пакетов sudo и curl"
apt-get install sudo curl -y > /dev/null

# Изменение файла конфигурации SSH для отключения аутентификации по паролю и перезапуск службы SSH
echo "Изменение файла конфигурации SSH для отключения аутентификации по паролю"
if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo "PasswordAuthentication изменено на no"
else
    echo "PasswordAuthentication уже установлено на no"
fi

# Загрузка скрипта установки Docker и его выполнение
echo "Загрузка скрипта установки Docker и его выполнение"
curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null && sudo sh get-docker.sh > /dev/null

# Добавление текущего пользователя в группу docker
echo "Добавление текущего пользователя в группу docker"
usermod -aG docker $USER > /dev/null

# Загрузка последней версии Docker Compose
echo "Загрузка последней версии Docker Compose"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null

# Изменение разрешений файла Docker Compose, чтобы сделать его исполняемым
echo "Изменение разрешений файла Docker Compose, чтобы сделать его исполняемым"
chmod +x /usr/local/bin/docker-compose > /dev/null

# Загрузка скрипта установки CloudPanel, проверка его контрольной суммы и выполнение с указанным DB_ENGINE
echo "Загрузка скрипта установки CloudPanel, проверка его контрольной суммы и выполнение с указанным DB_ENGINE"
curl -sS https://installer.cloudpanel.io/ce/v2/install.sh -o install.sh > /dev/null; \
echo "3c30168958264ced81ca9b58dbc55b4d28585d9066b9da085f2b130ae91c50f6 install.sh" | \
sha256sum -c && sudo DB_ENGINE=MARIADB_10.11 bash install.sh > /dev/null

# Добавление заданий crontab для ежедневного обновления CloudPanel, системы и Docker Compose (в одной команде)
echo "Добавление заданий crontab для ежедневного обновления CloudPanel, системы и Docker Compose (в одной команде)"
sh -c 'if ! grep -q "clp-update" /etc/crontab; then printf "\n# Обновление CloudPanel каждый день в 4 часа утра\n0 4 * * * root clp-update\n\n# Обновление системы каждый день в 4:10 утра\n10 4 * * * root apt-get update && apt-get upgrade -y && apt-get autoremove -y\n\n# Обновление Docker Compose каждый день в 4:30 утра\n30 4 * * * root curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose\n" >> /etc/crontab; fi' > /dev/null
