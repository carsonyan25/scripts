#!/bin/bash
#created by carson
# use to sync gitlab backup to aliyun slave server from aliyun test server 


gitlab_src=/var/opt/gitlab/backups
aliyunslave=aliyuntest@139.224.26.247::aliyuntest_data
company=backup-company@files.pcw365.com::backup-aliyuntest
aliyuntest_pass=/root/shell/aliyuntest.pass
company_pass=/root/shell/backup-company.pass
logfile=/root/shell/logs/rsync_gitlab_backup_to_aliyunslave_and_company.log
curdate=`date +%Y%m%d`
gitlab_setting_file=/tmp/gitlab-setting-${curdate}.tar.gz
log_days=6
keepdays=2

check_logfile(){
	find $logfile -mtime +${log_days} -exec rm -f '{}' \;
	touch $logfile
}

make_backups(){
	cd /etc/
	tar -czf ${gitlab_setting_file}  gitlab
	/usr/bin/gitlab-rake gitlab:backup:create
	cd $gitlab_src
	gitlab_new_backup=`ls -r *.tar |head -n 1`
}

rsync_backups(){
	cd /etc/
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${aliyuntest_pass}	${gitlab_setting_file} $aliyunslave
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${company_pass}	${gitlab_setting_file} $company
	rm -f /tmp/gitlab*.gz
	cd $gitlab_src
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${aliyuntest_pass}	${gitlab_new_backup} $aliyunslave
	rsync -avpP --quiet --bwlimit=5000 --log-file=${logfile} --password-file=${company_pass}	${gitlab_new_backup} $company
	find ./ -name "*.tar" -mtime +${keepdays}  -exec rm -f '{}' \; 
}

check_logfile
make_backups
rsync_backups
