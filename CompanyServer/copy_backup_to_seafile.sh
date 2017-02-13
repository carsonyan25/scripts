#!/bin/bash
#created by carson
# use to copy cad ,pcw and  mobile server's database backup to seafile



PCW_DB_DIR=/backup/www_pcw365_com/databases/fullbackup
CAD_DB_DIR=/backup/cad_pcw365_com/database/fullbackup
MOBILE_DB_DIR=/backup/m_pcw365_com/database/
SEAFILE_DIR=/backup/backup_to_seafile
curdate=`date +%Y%m%d`

cd ${SEAFILE_DIR}
find ./ -name "*.gz"  -exec rm -f '{}' \;
find ${PCW_DB_DIR} -name "*.gz" -mtime 0 -exec  cp '{}' ${SEAFILE_DIR} \; 
find ${CAD_DB_DIR} -name "*.gz" -mtime 0 -exec  cp '{}' ${SEAFILE_DIR} \;
find ${MOBILE_DB_DIR} -name "*.gz" -mtime 0 -exec cp '{}'  ${SEAFILE_DIR} \;


