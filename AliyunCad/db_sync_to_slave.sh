#!/bin/bash
# this script use to backup this server databases to aliyun slave server

# databases  backup variables
SRC_DB_FULL=/home/cad_db_backup/fullbackup/ 
SRC_DB_AEC=/home/cad_db_backup/fullbackup/aec
SRC_DB_DIFFERENT=/home/cad_db_backup/different_backup 
DB_BINLOG_DIR=/home/database/data/ 
DST_DB_FULL=db_full_199 
DST_DB_DIFFERENT=db_different_199 
DB_LOGFILE=/root/shell/logs/db_sync_to_slave.log
OTHER_KEEP=3  		# days for full backup keeps
DIFFERENT_KEEP=3 	# days for different backup keeps
vipapps_keep=14         # days for vipapps backup keeps
BINLOG_DAYS=1			# binlog files is compressed as  gz files  from now to BINLOG_DAYS
SYNC_DEFFERENT_INTERVAL=10m	# metric minute , how long do we have a different backup ?
OTHER_DB_INTERVAL=2
# rsync slave server and user
ALIYUN_SLAVE=10.25.37.142
USER=backup199
PASS=/root/shell/remote_backup/aliyun_slave_backup199.pass
# enviroment variables
PATH=/usr/bin:/usr/sbin/:/bin:/home/server/mysql5/bin
export PATH


# function for creating db fullbackup files and send to aliyun slave 

db_full_backup(){
	echo "$$" >  /root/shell/remote_backup/pid/db_full_backup_pid
	CUR_DATE=`date +%Y%m%d` 	
	db_vipapps_full_backup	# do vipapps full backup
	db_other_full_backup	# do other database full backup
	db_full_sync  # call function  ,send full db to aliyun slave
}


# function do vipapps backup
db_vipapps_full_backup(){	
		#delete vipapps full backup files before 21days  
	find $SRC_DB_FULL -name "cad-vipapps-*" -type f -mtime +$vipapps_keep  -exec rm -f '{}' \;
	mysqldump  -uroot -pIAGo1oy-881Nt2K\\  --master-data=2 --flush-logs -x --add-drop-database  --databases vipapps  > ${SRC_DB_FULL}/cad-vipapps-${CUR_DATE}.sql
}

#function do other database backup
db_other_full_backup(){
	
	#delete other database backup files 2 days ago	
	find $SRC_DB_FULL -name "cad-other-*" -type f -mtime +$OTHER_KEEP  -exec rm -f '{}' \;
	#delete aec database backup 2 days ago
	find $SRC_DB_AEC -name "cad-aec-big-table-*"  -type f -mtime +$OTHER_KEEP  -exec rm -f '{}'  \;
#		# table which size more than 1GB in database aec
	aec_big_table=(usercount_1_150824 usercount_1_170118 usercount_1_160926 usercount_1 usercount_1_device usercount usercount_last)
	exclude_table=(aec.usercount_1_150824 aec.usercount_1_170118  aec.usercount_1_160926  aec.usercount_1  aec.usercount_1_device aec.usercount aec.usercount_last)
	ignore_big_table=""
	for table in ${exclude_table[*]} ;
		do
			ignore_big_table="${ignore_big_table}--ignore-table=${table}  "
		done
		
	# export other databases ,without vipapps and aec big table data,mysql,informations_schema 
	other_db=(MiniCADPrice  ad  adplan  aec  aecpro  authen  bak_test  cad  hc_data  home_design  homecost  iptocity  logs  mycode  new  selling  shejie  softwares  steel  test  test3  xietong  xietong_test  xietong_test2)
	mysql -uroot -pIAGo1oy-881Nt2K\\  -e "show databases;" | grep -Ev "Database|information_schema|mysql|vipapps" | xargs mysqldump -uroot -pIAGo1oy-881Nt2K\\ --add-drop-database  -F -l ${ignore_big_table}  --databases    ${other_db[*]}  > $SRC_DB_FULL/cad-other-without-big-table-${CUR_DATE}.sql
	
#	 export aec big tables form
	mysqldump -uroot -pIAGo1oy-881Nt2K\\  -d aec ${aec_big_table[*]}  >  $SRC_DB_AEC/aec_big_table-${CUR_DATE}.form   
	
#	export aec big tables data
	for table in ${aec_big_table[*]};
		do
			mysql -uroot -pIAGo1oy-881Nt2K\\ -e " use aec; lock tables ${table} read ; select * from ${table} into outfile '$SRC_DB_AEC/${table}-${CUR_DATE}.data' fields terminated by ',' ; unlock tables; "
		done

}


# function for creating db different as gz file .
db_different_backup()
	{
		echo "$$" >  /root/shell/remote_backup/pid/db_different_backup_pid
		#while true
#		do
		CUR_DATE=`date +%Y%m%d`
		local	CUR_TIME=`date +%Y%m%d_%H%M`
								#delete db different files  before 4days
		find $SRC_DB_DIFFERENT -name "cad_binlog_bak*" -type f -mtime +$DIFFERENT_KEEP -exec rm -f {} \;	
		cd $DB_BINLOG_DIR  
								#compress db binlog files within today
		find ./ -name "mysql-bin*" -type f -mtime -$BINLOG_DAYS | xargs tar -czf $SRC_DB_DIFFERENT/cad_binlog_bak${CUR_TIME}.tar.gz 
		db_different_sync 				 # call function ,send binlog to aliyun slave 
#		sleep ${SYNC_DEFFERENT_INTERVAL}		# run db different task every 10 mins
#		done
	}

# this function use to copy db_full_backup file to aliyun slave
db_full_sync() 
	{
		
		
		# just copy today full backup 
          	CUR_vipapps_FULL="cad-vipapps-${CUR_DATE}.sql" 
		CUR_OTHER_FULL="cad-other-without-big-table-${CUR_DATE}.sql" 
		cd $SRC_DB_FULL 
			
		#compress vipapps and other database
		 pigz --rsyncable -c ${CUR_vipapps_FULL}  > ${CUR_vipapps_FULL}.gz  
		 pigz --rsyncable -c  ${CUR_OTHER_FULL} > ${CUR_OTHER_FULL}.gz
		
		#compress aec big table form and data
		cd $SRC_DB_AEC
		find ./   -name "*${CUR_DATE}*" -type f  | xargs tar -zcf cad-aec-big-table-${CUR_DATE}.tar.gz 
		
 		local backup_db=(${CUR_vipapps_FULL}.gz ${CUR_OTHER_FULL}.gz  cad-aec-big-table-${CUR_DATE}.tar.gz)
		
		cd $SRC_DB_FULL	
		for item in  ${backup_db[*]};   # send cad db full backup files one by one
			do
			 	if [ "${item}" = "cad-aec-big-table-${CUR_DATE}.tar.gz" ] ; then
					cd $SRC_DB_AEC
				fi
			rsync  -avpP  --bwlimit=20480   --quiet --log-file=${DB_LOGFILE}  --password-file=${PASS}  ${item}  $USER@$ALIYUN_SLAVE::$DST_DB_FULL
			done
		cd $SRC_DB_AEC && rm -f *.data *.form 
		cd $SRC_DB_FULL && rm -f *.sql 


	}



# this function use to copy db_different_backup files to aliyun slave 
db_different_sync()
	{	
		local	CUR_TIME=`date +%Y%m%d_%H%M`
		# copy  different backup files which compressed just now
          	local CURRENT_DB_DIFFERENT=`find $SRC_DB_DIFFERENT -type f  -mmin -2  -name "cad_binlog_bak*.tar.gz" `
		/usr/bin/rsync  -avpP  --bwlimit=5120   --quiet --log-file=$DB_LOGFILE --password-file=${PASS}  $CURRENT_DB_DIFFERENT  $USER@$ALIYUN_SLAVE::$DST_DB_DIFFERENT
		
	}


			

case $1 in 
	
	full)  # full means we run as  db fullbackup task daemon  (send to aliyun slave)
		db_full_backup
		;;
	different) #  incremental  means we run as  db incrementalbackup daemon (send to aliyun_save )
		db_different_backup
		;;
	
	stop)
		case $2 in 
			full)
				kill -9	`cat /root/shell/remote_backup/pid/db_full_backup_pid`
				rm -f /root/shell/remote_backup/pid/db_full_backup_pid
				echo "db_full_backup has been stop"
				;;
			different)
				kill -9 `cat /root/shell/remote_backup/pid/db_different_backup_pid`
				rm -f /root/shell/remote_backup/pid/db_different_backup_pid 
				echo "db_different_backup has been stop"
				;;
			
			*)
				echo "second parameter must be full | different"
			;;
		esac
		;;
	--help)
		echo 	"use full | different do backup , or use stop full | stop different to kill script"
		;;
	*)
		echo "first parameter must be full or different"
		;;
esac

			
