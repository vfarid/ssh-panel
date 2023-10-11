#!/bin/bash

TIMEOUT=600
TIMESTAMP=`date +%Y-%m-%d-%H-%M`
OUTPUT=/var/log/ssh-panel/$TIMESTAMP.log

sh -ic "{ /usr/sbin/nethogs -t | grep 'sshd:' &> $OUTPUT; kill 0; } | { sleep $TIMEOUT; kill 0; }" 3>&1 2>/dev/null
