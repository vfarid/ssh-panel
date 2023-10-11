#!/bin/bash

if crontab -l | grep -Fq "ssh-panel-one-time-job"; then
    crontab -l > mycron
    sed -i "/ssh-panel-one-time-job/d" mycron
    crontab mycron
    rm mycron
fi

TIMEOUT=3600
TIMESTAMP=`date +%Y-%m-%d-%H-%M`
OUTPUT=/var/log/ssh-panel/$TIMESTAMP.log

sh -ic "{ /usr/sbin/nethogs -t | grep 'sshd:' &> $OUTPUT; kill 0; } | { sleep $TIMEOUT; kill 0; }" 3>&1 2>/dev/null
