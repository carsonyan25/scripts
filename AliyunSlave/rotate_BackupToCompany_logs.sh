#!/bin/bash
#  remove  send logs manually  . send logs  which record what backup files to company status
# created by carson  21/09/2016

cd /root/shell/logs
rm -f  pcw_web.log pcw_db.log cad_db.log mobile_db.log stats_db.log  usa_db.log
touch pcw_web.log pcw_db.log cad_db.log mobile_db.log stats_db.log  usa_db.log


