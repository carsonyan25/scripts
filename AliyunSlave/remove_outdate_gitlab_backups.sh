#!/bin/bash
# created by carson
# remove outdate gitlab backups on aliyun slave server

gitlab_backup_dir=/backup/aliyuntest_backup
keepdays=5

remove_backups(){
	cd $gitlab_backup_dir
	find ./ -name "*tar*" -mtime +$keepdays -exec rm -f '{}' \;
}



remove_backups
