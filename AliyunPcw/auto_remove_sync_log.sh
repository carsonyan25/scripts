#!/bin/bash
# auto remove and create log file for sync script  (with aliyun slave)


cd /root/shell/logs

rm -f  web_sync_to_slave.log db_sync_to_slave.log

touch web_sync_to_slave.log db_sync_to_slave.log

