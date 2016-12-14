#!/bin/bash
# auto remove backup log file which created by  sync script  (web_sync_to_slave.sh and db_sync_to_slave.sh)


cd /root/shell/logs

rm -f  web_sync_to_slave.log db_sync_to_slave.log

touch web_sync_to_slave.log db_sync_to_slave.log

