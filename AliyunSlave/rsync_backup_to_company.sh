#/bin/bash
# this script use to send www.pcw365.com(139.196.237.112) and cad.pcw365.com(139.224.26.247) databases and web backup to company

PCW_WEB_DIR=/backup/www_pcw365_backup/webfiles
PCW_DB_DIR=/backup/www_pcw365_backup/databases
CAD_DB_DIR=/backup/cad_pcw365_backup/database
MOBILE_DB_DIR=/backup/m_pcw365_backup/database
WEB_EXPIRE=5			#pcw web backups keep days
FULL_DB_EXPIRE=7		#full db backups keep days
DIFFERENT_DB_EXPIRE=7		#db different backups keep days
PCW_WEB_LOGFILE=/root/shell/logs/pcw_web.log
PCW_DB_LOGFILE=/root/shell/logs/pcw_db.log
CAD_DB_LOGFILE=/root/shell/logs/cad_db.log
MOBILE_DB_LOGFILE=/root/shell/logs/MOBILE_DB.log
PASS=/backup/passfile/backup2company.pass
USER=backup-company
COMPANY_SERVER=27.115.112.238
PCW_DST=backup-pcw
CAD_DST=backup-cad
MOBILE_DST=backup-mobile
SPEED=5000


sync_pcw_web(){

	echo "$$" >  /root/shell/pid/sync_pcw_web_pid   # save  running pid to  file which is use for stop script
	# delete pcw web backup created 3days  ago
	find  ${PCW_WEB_DIR}  -name "pcw-web*.gz" -mtime  +${WEB_EXPIRE} -exec rm -f '{}' \;
	CUR_DATE=`date +%Y%m%d`
	if [ ! -f ${PCW_WEB_DIR}/pcw-web-${CUR_DATE}.tar.gz ] ; then
		compress_pcw_web_files  # compress pcw web files
	fi
	rsync -avpP --quiet --bwlimit=${SPEED}  --delete  --log-file=$PCW_WEB_LOGFILE --exclude=pcw-web*.gz --password-file=${PASS} $PCW_WEB_DIR  $USER@$COMPANY_SERVER::$PCW_DST

}



sync_pcw_db()
	{

echo "$$" >  /root/shell/pid/sync_pcw_db_pid
		#delete pcw full and different db backup created 7days ago
		find ${PCW_DB_DIR}/fullbackup  -name "*.gz" -mtime +${FULL_DB_EXPIRE} -exec rm -f {} \;
		find ${PCW_DB_DIR}/different_backup  -name "*.gz" -mtime +${DIFFERENT_DB_EXPIRE} -exec  rm -f {} \;
		rsync -avpP --quiet --bwlimit=${SPEED} --log-file=$PCW_DB_LOGFILE --password-file=${PASS} $PCW_DB_DIR  $USER@$COMPANY_SERVER::$PCW_DST
	}


sync_cad_db()
	{

echo "$$" >  /root/shell/pid/sync_cad_db_pid
		#delete cad full and different  db backup created 7days ago
		find ${CAD_DB_DIR}/fullbackup  -name "*.gz" -mtime +${FULL_DB_EXPIRE} -exec rm -f {} \;
		find ${CAD_DB_DIR}/different_backup  -name "*.gz" -mtime +${DIFFERENT_DB_EXPIRE} -exec  rm -f {} \;
		rsync -avpP --quiet --bwlimit=${SPEED}  --exclude=.* --exclude=oracle --log-file=$CAD_DB_LOGFILE --password-file=${PASS} $CAD_DB_DIR  $USER@$COMPANY_SERVER::$CAD_DST
	}


sync_mobile_db()
	{
	
	echo "$$" > /root/shell/pid/sync_mobile_pid
	find ${MOBILE_DB_DIR} -name "*.gz" -mtime +${FULL_DB_EXPIRE} -exec rm -f {} \;
	curtime=`date +%Y%m%d-%H%m`
	cd ${MOBILE_DB_DIR} 
	tar -zcf mongodb-${curtime}.tar.gz  ../mongodb
	rsync -avpP --quiet --bwlimit=${SPEED} --log-file=$MOBILE_DB_LOGFILE --password-file=${PASS}  --include=*.gz  $MOBILE_DB_DIR  $USER@$COMPANY_SERVER::$MOBILE_DST
}

compress_pcw_web_files(){

        cd $PCW_WEB_DIR
        tar -zcf  pcw-web-${CUR_DATE}.tar.gz  ecshop

}



stop_task(){

        local srcipt_name='sync_pcw_backup_to_company.sh'
        if [ "$para_2" = "pcw" ] ; then
                if [ "$para_3"  = "web" ] ; then
                	kill -9 `cat /root/shell/pid/sync_pcw_web_pid`
				if [ $? -eq 0 ] ; then
					rm -f  /root/shell/pid/sync_pcw_web_pid
					echo "sync to company pcw_web_files have been stop"
				fi					 
		elif [ "$para_3" = "db" ] ; then
                	kill -9 `cat /root/shell/pid/sync_pcw_db_pid`
                        	if [ $? -eq 0 ] ; then
                                	rm -f  /root/shell/pid/sync_pcw_db_pid
					echo "sync to company pcw_db_files have been stop"
				fi
		else    echo "third parameter is error" 
               	fi 
        
	elif [ "$para_2" = "cad" ] ; then
                if [ "$para_3" = "db" ] ; then
                	kill -9 `cat /root/shell/pid/sync_cad_db_pid`
                                if [ $? -eq 0 ] ; then
                                        rm -f  /root/shell/pid/sync_cad_db_pid
					echo "sync to company cad_db_files have been stop"
                                fi
		else    echo "third parameter is error"
                fi
        fi
}



case $1 in 
	"pcw")

		case $2 in
			"web")
				sync_pcw_web
				;;
			"db")
				sync_pcw_db
				;;
			*)
				echo "second parameter should be web|db"
				;;
		esac
	;;

        "cad")

                case $2 in
                        "db")
                                sync_cad_db
                                ;;
                        *)
                                echo "second parameter should be db"
                                ;;
                esac
        ;;

	 "mobile")

                case $2 in
                        "db")
                                sync_mobile_db
                                ;;
                        *)
                                echo "second parameter should be db"
                                ;;
                esac
        ;;


	"stop")
		para_2=$2; para_3=$3;  
		export para_2  para_3  # export $2 $3 as global variables which could be access in function
		stop_task
		;;	
		
	*)
		echo "how to use ?"
		echo "run backup use parameter  pcw|cad  , db|web,   such as pcw db "
		echo "stop backup use parameter stop cad db ."	
		;;

esac


