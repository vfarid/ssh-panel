#!/bin/bash

echo -e "Updating OS and installing required packages...\n--------------------------------------------------------\n"
if [ -x "$(command -v yum)" ]; then
    # CentOS/RHEL
    sudo yum -y update
    sudo yum -y install nethogs golang dialog bc coreutils
elif [ -x "$(command -v apt-get)" ]; then
    # Debian/Ubuntu
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
    sudo apt-get -y install nethogs golang dialog bc coreutils
    sudo DEBIAN_FRONTEND=interactive
else
    echo "Unsupported distribution or package manager"
    exit 1
fi

chmod +x nethogs.sh

sudo rm -rf ./hogs* && wget https://raw.githubusercontent.com/boopathi/nethogs-parser/master/hogs.go && sudo go build -o hogs hogs.go
sudo mkdir -p /var/log/ssh-panel

cron_job="*/5 * * * * sh $(pwd)/cron.sh"

if ! crontab -l 2>/dev/null | grep -Fq "$cron_job"; then
    (crontab -l ; echo "$cron_job") | crontab
fi

echo -e "\n--------------------------------------------------------\nInstallation completed.\nYou may run \`sh panel.sh\` to enter panel.\n"
