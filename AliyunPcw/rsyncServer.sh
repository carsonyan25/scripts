#!/bin/bash
datasrc=/home/server/apache2/htdocs/ecshop
testsrc=/root/soft/rsync/rsynctest
des=backup
despath=/rmanbackup1/bakup111/data/
host="115.182.53.115"
/usr/local/bin/inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f' -e modify,delete,create,attrib $datasrc | while read files
do
for hostip in $host
do
rsync -vzrtopg --delete --progress $datasrc root@$hostip:$despath
done
echo "${files} was rsynced" >>/tmp/rsync.log 2>&1
done
