#!/bin/bash
#created by carson
# make svn backup on code server and sent to backup server

curdate=`date +%Y%m%d`
backup="cad-svn-${curdate}.dump"
dest="backup-company@files.pcw365.com::svn_backup"
passfile=/root/shell/backup_server.pass

backup_and_compress(){ 

	cd /tmp
	/app/subversion/bin/svnadmin   dump /app/code/svn/ProjectSource   > ${backup} 
	pigz  -p 5  ${backup}
}

sync_to_backup_server(){

cd /tmp
rsync -avpP --quiet --bwlimit=60000 --password-file=${passfile}  ${backup}  ${dest}

}

backup_and_compress
sync_to_backup_server


