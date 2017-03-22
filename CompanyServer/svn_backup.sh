#!/bin/bash
#created by carson
# make svn backup on code server and sent to backup server

curdate=`date +%Y%m%d`
backup="cad-svn-${curdate}.dump"
dest="backup-company@files.pcw365.com::svn_backup"
passfile=/root/shell/backup_server.pass

backup_and_compress(){ 

	cd /app/backup
	/app/subversion/bin/svnadmin   dump /app/code/svn/ProjectSource   > ${backup} 
	pigz  -p 5  ${backup}
}

sync_to_backup_server(){

cd /app/backup
rsync -avpP --quiet --bwlimit=60000 --password-file=${passfile}  ${backup}.gz  ${dest}
rm -f ${backup}.gz

}

backup_and_compress
sync_to_backup_server


