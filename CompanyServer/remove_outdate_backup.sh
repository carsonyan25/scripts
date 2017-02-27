#!/bin/bash
#created by carson
# this script used to remove outdate backup ( pcw and cad server) and compress pcw webfiles to gz file.

PCW_WEB_DIR=/backup/www_pcw365_com/webfiles
PCW_DB_DIR=/backup/www_pcw365_com/databases
CAD_DB_DIR=/backup/cad_pcw365_com/database
MOBILE_DB_DIR=/backup/m_pcw365_com
STATS_DIR=/backup/code_pcw365_com
WEB_EXPIRE=4
PCW_DB_EXPIRE=30
CAD_DB_EXPIRE=7
CAD_VIPAPPS_EXPIRE=30
MOBILE_DB_EXPIRE=30
STATS_EXPIRE=4

remove_pcw_backup()
        {
                curdate=`date +%Y%m%d`
                cd $PCW_DB_DIR
                find ./  -name "*.gz"  -mtime +${PCW_DB_EXPIRE}  -exec  rm -f '{}' \;
                cd $PCW_WEB_DIR
                find ./  -name "*.gz"  -mtime +${WEB_EXPIRE}  -exec  rm -f '{}' \;
                tar -czf  pcw-web-${curdate}.tar.gz ecshop
        }


remove_cad_backup()
        {

                cd $CAD_DB_DIR
                find ./  -name "cad-aec-big-table*.gz"  -mtime +${CAD_DB_EXPIRE}  -exec  rm -f '{}' \;
                find ./  -name "cad-other-without-big-table*.gz"  -mtime +${CAD_DB_EXPIRE}  -exec  rm -f '{}' \;
                find ./  -name "cad_binlog*.gz"  -mtime +${CAD_DB_EXPIRE}  -exec  rm -f '{}' \;
                find ./  -name "cad-vipapps*.gz"  -mtime +${CAD_VIPAPPS_EXPIRE}  -exec  rm -f '{}' \;

        }

remove_mobile_backup()
	{
		cd $MOBILE_DB_DIR
		find ./ -name "*.gz"	-mtime +${MOBILE_DB_EXPIRE} -exec rm -f '{}' \;
	}


remove_stats_backup()
	{
		cd $STATS_DIR
		find ./ -name "*.gz"	-mtime +${STATS_EXPIRE} -exec rm -f '{}' \;
	}


remove_pcw_backup
remove_cad_backup
remove_mobile_backup
remove_stats_backup
