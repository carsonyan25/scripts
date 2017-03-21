#!/bin/bash
#created by carson
# make svn backup on code server and sent to backup server

curdate=`date +%Y%m%d`
backup="cad-svn-${curdate}.dump"

backup_and_compress(){ 

	cd /tmp

	/app/subversion/bin/svnadmin   dump /app/code/svn/ProjectSource  -M 512  > ${backup}  2&> /root/shell/log/svn-backup.log

	pigz  -p 5  ${backup}
}

#sync_to_backup_server(){

#cd /tmp
#rsync -avpP --quiet --bwlimit=60000 --password-file=${passfile}  ${backup}  ${dest}
#}

backup_and_compress


