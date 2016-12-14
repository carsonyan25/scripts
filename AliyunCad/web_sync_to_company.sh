#!/bin/bash
# this script use to sync this server web files(ecshop) to company( public ip 140.206.131.250 ,private ip 192.168.1.232) server every day

# web files backup variables
SRC_WEB=/home/web
DST_WEB=backup-cad
WEB_LOGFILE=/root/shell/logs/web_sync_to_company.log

# rsync slave server and user
COMPANY_SERVER=140.206.131.250
USER=backup-company
PASS=/root/shell/remote_backup/backup2company.pass
		
web_sync(){
	echo "$$" > /root/shell/remote_backup/pid/web_sync_to_company.pid
	rsync  -avpP  --bwlimit=2000  --delete  --log-file=$WEB_LOGFILE --quiet --password-file=${PASS} $SRC_WEB  $USER@$COMPANY_SERVER::$DST_WEB
}


case $1 in
	"sync")
		web_sync
		;;
	"stop")
		kill -9 `cat  /root/shell/remote_backup/pid/web_sync_to_company.pid` 
		rm -f  /root/shell/remote_backup/pid/web_sync_to_company.pid
		echo "web_sync_to_company script has been stop"
		;;
	*)
		echo "usage: sync , send web file to company ; stop , stop this script"
		;;
esac






