#!/bin/bash
# this script use to sync this server web files(ecshop) to aliyun slave server every 10mins

# web files backup variables
SRC_WEB=/home/server/apache2/htdocs/ecshop
DST_WEB=web112
WEB_LOGFILE=/root/shell/logs/web_sync_to_slave.log

# rsync slave server and user
ALIYUN_SLAVE=10.25.37.142
USER=backup112
PASS=/root/shell/remote_backup/aliyun_slave_backup112.pass

		
web_sync(){
	echo "$$" > /root/shell/remote_backup/pid/web_sync_to_slave.pid  
	while   true
		do

			rsync  -avpP  --bwlimit=10240  --delete  --log-file=$WEB_LOGFILE --quiet --password-file=${PASS} $SRC_WEB  $USER@$ALIYUN_SLAVE::$DST_WEB
        
		sleep 30m

		done


}


case $1 in
        "sync")
                web_sync
                ;;
        "stop")
                kill -9 `cat  /root/shell/remote_backup/pid/web_sync_to_slave.pid`
                rm -f  /root/shell/remote_backup/pid/web_sync_to_slave.pid
                echo "web_sync_to_slave script has been stop"
                ;;
        *)
                echo "usage: sync , send web file to aliyun slave ; stop , stop this script"
                ;;
esac









