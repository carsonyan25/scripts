#!/bin/bash
#created by carson
# use to copy all server's database new backup to rtx.pcw365.com(f:\rtx_share\All_Backup) 



PCW_DB_DIR=/backup/www_pcw365_com/databases/fullbackup
CAD_DB_DIR=/backup/cad_pcw365_com/database/fullbackup
MOBILE_DB_DIR=/backup/m_pcw365_com/database/
ALIYUNTEST_DIR=/backup/aliyun_test/gitlab_data_backup/
RTX_DIR=/rtx_share/All_Backup
STATS_DB_DIR=/backup/stats.pcw365.com/stats.pcw365.com_backup
USA_CAD_DB_DIR=/backup/usa.pcw365.com/usa.pcw365.com_backup

# RTX_DIR is locate in rtx.pcw365.com(f:\rtx_share\All_Backup) 
RTX_DIR=/rtx_share/All_Backup
curdate=`date +%Y%m%d`
speed=30000

#delete old backup file in RTX_DIR
rm -f  $RTX_DIR/*.* 

find ${PCW_DB_DIR} -name "*.gz" -mtime 0 -exec rsync -avpP --bwlimit=${speed} '{}' ${RTX_DIR} \; 
find ${CAD_DB_DIR} -name "*.gz" -mtime 0 -exec  rsync -avpP --bwlimit=${speed} '{}' ${RTX_DIR} \;
find ${MOBILE_DB_DIR} -name "*.gz" -mtime 0 -exec rsync -avpP --bwlimit=${speed} '{}'  ${RTX_DIR} \;
find ${ALIYUNTEST_DIR} -name "*.tar*" -mtime 0 -exec rsync -avpP --bwlimit=${speed} '{}'  ${RTX_DIR} \;
find ${STATS_DB_DIR} -name "*.gz" -mtime 0 -exec rsync -avpP --bwlimit=${speed} '{}' ${RTX_DIR} \; 
find ${USA_CAD_DB_DIR} -name "*.gz" -mtime 0 -exec rsync -avpP --bwlimit=${speed} '{}' ${RTX_DIR} \; 




