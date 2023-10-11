#!/bin/bash

echo -e "Updating OS and installing required packages...\n--------------------------------------------------------\n"
if [ -x "$(command -v yum)" ]; then
    # CentOS/RHEL
    sudo yum -y update
    sudo yum -y install nethogs golang
elif [ -x "$(command -v apt-get)" ]; then
    # Debian/Ubuntu
    sudo apt-get -y update
    sudo apt-get -y install nethogs golang
else
    echo "Unsupported distribution or package manager"
    exit 1
fi

sudo rm -rf ./hogs* && wget https://raw.githubusercontent.com/boopathi/nethogs-parser/master/hogs.go && sudo go build -o hogs hogs.go
sudo mkdir -p /var/log/ssh-panel

cron_job="*/10 * * * * sh $(pwd)/cron.sh"

if ! crontab -l | grep -Fq "$cron_job"; then
    (crontab -l ; echo -e "$cron_job") | crontab
fi

echo -e "\n--------------------------------------------------------\nInstallation completed.\nYou may run \`sh panel.sh\` to enter panel.\n"
