#!/bin/bash
#created by carson
# this script use to create backups for table usercount_last and user_stat in Mysql(stats database) , then sync to aliyun slave server


mysql_bin=/home/server/mysql5/bin
db_backup=/home/stats_db_backup/stats
curdate=`date +%Y%m%d`
dest=stats@tower.pcw365.com::stats_data
pass=/root/shell/stats.pass
speed=20000
expire=6

	
create_backup(){

	cd $db_backup
	# backup table form usercount_last and user_stat
	${mysql_bin}/mysqldump  -uroot -pSO/ljb1PWa14lHqF  -d stats usercount_last user_stats > stats-usercount_last_and_user_stat-${curdate}.form
	# backup table  usercount_last data
	${mysql_bin}/mysql  -uroot -pSO/ljb1PWa14lHqF  -e "use stats; select *  into outfile '$db_backup/stats.usercount_last-${curdate}.data' from usercount_last fields terminated by ','; "
	# backup table user_stat data
	${mysql_bin}/mysql  -uroot -pSO/ljb1PWa14lHqF  -e "use stats; select *  into outfile '$db_backup/stats.user_stat-${curdate}.data' from user_stat fields terminated by ','; "

}

compress_sync(){
	
	cd /home/stats_db_backup
	tar -czf stats_db_backup-${curdate}.tar.gz  stats
	rsync -avpP  --quiet --bwlimit=$speed  --password-file=$pass stats_db_backup-${curdate}.tar.gz  $dest  

}

remove_files(){

	cd /home/stats_db_backup
	#remove backup files older than  7 days
	find ./ -name "*.gz"  -mtime  +${expire} -exec rm -f '{}' \;
	# remove current temporary files
	rm -f  $db_backup/*.*
}

create_backup
compress_sync
remove_files
