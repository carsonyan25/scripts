#!/bin/bash
#created by carson in 02/27 2017
#this script used to bakcup statistics(mysql table data) to companybackup server


user=root
pass=f5x/pdWUtDgAyz5R
host=code.pcw365.com
mysql_path=/app/mysql5/bin/
curdate=`date %Y%m%d`
dest=/backup/code_pcw365_com


backup(){

	cd $mysql_path
	mysqldump -u$user -p$pass -h$host --databases stats -d  > /backup/code_pcw365_com/stats_${curdate}.form
	mysql -u$user -p$pass -h$host -e "select * into outfile '$dest/user_stat-${curdate}.sql' fields terminated by ',' from stats.user_stat"
	mysql -u$user -p$pass -h$host -e "select * into outfile '$dest/usercount_last-${curdate}.sql' fields terminated by ',' from stats.usercount_last" 

}

compress(){
	cd $dest
	find ./ -name "*${curdate}*" -exec tar -czf stats-${curdate}.tar.gz '{ }' \;
}

backup
compress

