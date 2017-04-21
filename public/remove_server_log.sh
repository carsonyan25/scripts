#!/bin/bash
# created by carson
# used to delete expired log

expired=30


apache_log_dir=/home/server/apache2/logs

cd $apache_log_dir
find ./ -name "20*log"  -mtime  +${expired}   -exec rm -f '{}' \;


