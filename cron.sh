#!/bin/bash

timestamp=`date +%Y-%m-%d-%H-%M`
output=/var/log/ssh-panel/$timestamp.log

nethogs_pid=$(pgrep nethogs)
if [ -n "$nethogs_pid" ]; then
    kill "$nethogs_pid"
fi

nohup /usr/sbin/nethogs -t | grep 'sshd:' 2>&1 | /usr/bin/tee "$output" >/dev/null &
