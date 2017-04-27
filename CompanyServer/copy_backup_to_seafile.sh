#!/bin/bash
#created by carson
# use to copy cad ,pcw and  mobile server's database backup to seafile



PCW_DB_DIR=/backup/www_pcw365_com/databases/fullbackup
CAD_DB_DIR=/backup/cad_pcw365_com/database/fullbackup
MOBILE_DB_DIR=/backup/m_pcw365_com/database/
ALIYUNTEST_DIR=/backup/aliyun_test/gitlab_data_backup/
SEAFILE_DIR=/backup/backup_to_seafile
curdate=`date +%Y%m%d`

cd ${SEAFILE_DIR}
find ./  -regextype 'posix-egrep' -iregex '(.*gz$|.*gitlab.*)'    -exec rm -f '{}' \;
find ${PCW_DB_DIR} -name "*.gz" -mtime 0 -exec  cp '{}' ${SEAFILE_DIR} \; 
find ${CAD_DB_DIR} -name "*.gz" -mtime 0 -exec  cp '{}' ${SEAFILE_DIR} \;
find ${MOBILE_DB_DIR} -name "*.gz" -mtime 0 -exec cp '{}'  ${SEAFILE_DIR} \;
find ${ALIYUNTEST_DIR} -name "*.tar*" -mtime 0 -exec cp '{}'  ${SEAFILE_DIR} \;



