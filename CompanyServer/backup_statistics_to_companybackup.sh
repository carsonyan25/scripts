#!/bin/bash
#created by carson in 02/27 2017
#this script used to bakcup statistics(mysql table data) to companybackup server


user=root
pass=f5x/pdWUtDgAyz5R
host=code.pcw365.com
MYSQLDUMP=/app/mysql5/bin/mysqldump
curdate=`date +%Y%m%d`
dest=/backup/code_pcw365_com

backup(){

        cd $mysql_path
        $MYSQLDUMP -u$user -p$pass -h$host --databases stats --tables user_stat >$dest/user_stat-${curdate}.sql
        $MYSQLDUMP -u$user -p$pass -h$host --databases stats --tables usercount_last >$dest/usercount_last-${curdate}.sql

}

compress(){
        cd $dest
        find ./ -name "*${curdate}*" | xargs tar -czf stats-${curdate}.tar.gz \;
        rm -f *.sql
}

backup
compress

