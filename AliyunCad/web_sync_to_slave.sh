#!/bin/bash
#created by carson
#sync web files to slave everyday 


src=/home/web/webapps
dest=web199
logfile=/root/shell/logs/web_sync_to_slave.log
pass=/root/shell/remote_backup/aliyun_slave_backup199.pass
slave=10.25.37.142
user=backup199


rsync -avpP  --quiet --password-file=$pass --bwlimit=20480 --delete --ignore-errors --log-file=$logfile   $src $user@$slave::$dest
