#!/bin/bash
#created by carson
# use to sync gitlab backup to aliyun slave server from aliyun test server 


gitlab_src=/var/opt/gilab/backups
aliyunslave=aliyuntest@139.224.26.247::aliyuntest_data
company=backup-company@files.pcw365.com::backup-aliyuntest
passfile=/root/shell/aliyuntest.pass
logfile=/root/shell/rsync_gitlab_backup_to_aliyunslave_and_company.log
curdate=`date +%Y%m%d`
gitlab_setting_file=/tmp/gitlab-${curdate}.tar.gz

make_backups(){
	cd /etc/
	tar -czf ${gitlab_setting_file}  gitlab
	/usr/bin/gitlab-rake gitlab:backup/create
	
}

rsync_backups(){
	cd /etc/
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${passfile}	${gitlab_setting_file} $aliyunslave
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${passfile}	${gitlab_setting_file} $company
	rm -f /tmp/gitlab*.gz
	cd $gitlab_src 
	gitlab_new_backup=`ls -r | head -n 1`-${curdate}
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${passfile}	${gitlab_new_backup} $aliyunslave
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${passfile}	${gitlab_new_backup} $company
	rm -f $gitlab_new_backup
}

make_backups
rsync_backups
