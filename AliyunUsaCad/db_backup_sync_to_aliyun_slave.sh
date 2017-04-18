#!/bin/bash
#created by carson
# this script use to create backups for table usercount_last and user_stat in Mysql(stats database) , then sync to aliyun slave server


mysql_bin=/app/mysql5/bin
db_backup=/app/usa_backup/database
curtime=`date +%Y%m%d-%H%M`
dest=UsaCad@tower.pcw365.com::UsaCad_data
pass=/root/shell/UsaCad.pass
speed=500
expire=3

	
create_backup(){

	cd $db_backup
	# backup cadstat and nationalPay databases
	product_db=`${mysql_bin}/mysql  -uroot -pxRFy+jnsae4Md33J -e "show databases;" | grep -ivE '(sys|information|performance|mysql|grep|Database)'  `
	${mysql_bin}/mysqldump  -uroot -pxRFy+jnsae4Md33J  --databases ${product_db}  > usa-cad-db-backup-${curtime}.sql

}

compress_sync(){
	
	cd /app/usa_backup
	tar -czf usa_cad_db_backup-${curtime}.tar.gz  database
	rsync -avpP  --quiet --bwlimit=$speed  --password-file=$pass usa_cad_db_backup-${curtime}.tar.gz  $dest  

}

remove_files(){

	cd /app/usa_backup
	#remove backup files older than  4 days
	find ./ -name "*.gz"  -mtime  +${expire} -exec rm -f '{}' \;
	# remove current temporary files
	rm -f  $db_backup/*.*
}

create_backup
compress_sync
remove_files
