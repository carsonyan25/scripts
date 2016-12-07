#!/bin/bash
# created by carson
# used to delete expired log

expired=20


apache_log_dir=/home/server/apache2/logs

cd $apache_log_dir
find ./ -name "201*log"  -mtime  +${expired}   -exec rm -f '{}' \;
echo "finished clear"  >> clear_pcw.log

