#!/bin/bash

#variables
SERVER_DIR="$(cat config_ts3update.txt | cut -s -d":" -f2 | head -1)"

SCRIPT_DIR="$(cat config_ts3update.txt | cut -s -d":" -f2 | tail -1)"

#date
TIMESTAMP=$(date +'%Y-%m-%d-%H-%M')
#start update
${SCRIPT_DIR}/ts3update.sh

#save log files
mkdir ${SERVER_DIR}/ts3updater/ts3update_logs/ &> /dev/null
mv ${SERVER_DIR}/ts3updater/ts3update_logs/ts3update.log ${SERVER_DIR}/ts3updater/ts3update_logs/ts3update_${TIMESTAMP}.log

#purge logs older than 2 months
find ${SERVER_DIR}/ts3updater/ts3update_logs/ -name "*.log" -type f -mtime +60 -exec rm -f {} \;