#!/bin/bash
# this script use to backup this server databases to aliyun slave server

# databases  backup variables
SRC_DB_FULL=/home/pcw_db_backup/fullbackup/ 
SRC_DB_DIFFERENT=/home/pcw_db_backup/different_backup 
DB_BINLOG_DIR=/home/server/mysql5/data/ 
DST_DB_FULL=db_full_112 
DST_DB_DIFFERENT=db_different_112 
DB_LOGFILE=/root/shell/logs/db_sync_to_slave.log
FULL_KEEP=30  		# days for full backup keeps
DIFFERENT_KEEP=7 	# days for different backup keeps
BINLOG_DAYS=1			# binlog files is compressed as  gz files  from now to BINLOG_DAYS
SYNC_DEFFERENT_INTERVAL=10m	# metric minute , how long do we have a different backup ?
# rsync slave server and user
ALIYUN_SLAVE=10.25.37.142
USER=backup112
PASS=/root/shell/remote_backup/aliyun_slave_backup112.pass
# enviroment variables
PATH=/usr/bin:/usr/sbin/:/bin:/home/server/mysql5/bin
export PATH


# function for creating db fullbackup and send to aliyun slave. 
db_full_backup()
	{	
		local	CUR_DATE=`date +%Y%m%d`
		#delete db full backup files before 21days  
		find $SRC_DB_FULL -name "pcw-ecshop-*" -type f -mtime +$FULL_KEEP -exec rm -f '{}' \;
		mysqldump  -uroot -paecsqlyou  --master-data=2 --flush-logs -x --add-drop-database --databases budget ecshop pcwcms pc pcwb2bs b2bsite minicmf minimarket > ${SRC_DB_FULL}/pcw-ecshop-${CUR_DATE}.sql
		db_full_sync  # call function  ,send full db to aliyun slave
	}

# function for creating db incremental as gz file and send to aliyun slave.
db_different_backup()
	{
		echo "$$" >  /root/shell/remote_backup/pid/db_different_backup_pid
#		while true
#		do
		CUR_DATE=`date +%Y%m%d`
		local	CUR_TIME=`date +%Y%m%d_%H%M`
								#delete db different files  before 7days
		find $SRC_DB_DIFFERENT -name "pcw_binlog_bak_*" -type f -mtime +$DIFFERENT_KEEP -exec rm -f '{}' \;	
		cd $DB_BINLOG_DIR  
								#compress db binlog files within today
		find ./ -name "mysql-bin*" -type f -mtime -$BINLOG_DAYS | xargs tar -czf $SRC_DB_DIFFERENT/pcw_binlog_bak_${CUR_TIME}.tar.gz 
		db_different_sync 				 # call function ,send binlog to aliyun slave 
#		sleep ${SYNC_DEFFERENT_INTERVAL}		# run db different task every 10 mins
#		done
	}

# this function use to copy db_full_backup file to aliyun slave
db_full_sync() 
	{

		local	CUR_DATE=`date +%Y%m%d`
		# just copy today full backup 
          	CURRENT_DB_FULL="pcw-ecshop-${CUR_DATE}.sql"  
		cd $SRC_DB_FULL && gzip --rsyncable  -c  ${CURRENT_DB_FULL} > ${CURRENT_DB_FULL}.gz
		rsync  -avpP  --bwlimit=10240  --log-file=${DB_LOGFILE}  --quiet --password-file=${PASS}  ${CURRENT_DB_FULL}.gz  $USER@$ALIYUN_SLAVE::$DST_DB_FULL
		if [ $? -eq 0 ] ; then
			cd $SRC_DB_FULL
			rm -f  ${CURRENT_DB_FULL}.gz  
		fi

	}

# this function use to copy db_incremental_backup files to aliyun slave 
db_different_sync()
	{	
		CUR_DATE=`date +%Y%m%d`
		local	CUR_TIME=`date +%Y%m%d_%H%M`
		# copy  different backup files which compressed just now
          	CURRENT_DB_DIFFERENT=`find $SRC_DB_DIFFERENT -type f  -mmin -2  -name "pcw_binlog_bak*.tar.gz" `
		/usr/bin/rsync  -avpP  --bwlimit=10240 --log-file=${DB_LOGFILE}   --quiet --password-file=${PASS}  $CURRENT_DB_DIFFERENT  $USER@$ALIYUN_SLAVE::$DST_DB_DIFFERENT
   
	}


			

case $1 in 
	
	full)  # full means we run  db fullbackup task daemon  (send to aliyun slave)
		db_full_backup
		;;
	different) #  incremental  means we run db incrementalbackup daemon (send to aliyun_save )
		db_different_backup
		;;
	
	stop)
		case $2 in 
			full)
				kill -9	`cat /root/shell/remote_backup/pid/db_full_backup_pid`
				rm -f /root/shell/remote_backup/pid/db_full_backup_pid
				echo "db full sync has been stop"
				;;
			different)
				kill -9 `cat /root/shell/remote_backup/pid/db_different_backup_pid`
				rm -f /root/shell/remote_backup/pid/db_different_backup_pid 
				echo "db different sync has been stop"
				;;
			
			*)
				echo "second parameter must be full | different"
			;;
		esac
		;;
	*)
		echo "first parameter must be full , different,stop"
		;;
esac

			
