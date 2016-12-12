#/bin/bash 
# this script uses to delete and copy files  automatically


# delete share files before 3days ago
find /home/web/webapps/ROOT/share -regextype 'posix-egrep' -regex  '.*(txt|dwg)$' -type f -mtime +3 -exec rm -f {} \;

#copy yesterday dwg and txt files to share 
\cp /home/web/webapps/ROOT/shareoneday/shareoneday/{*.dwg,*.txt}   /home/web/webapps/ROOT/share/

#delete up_load files 1 years ago
find /home/web/webapps/ROOT/pm/up_load/ -mtime +365 -type f -exec rm -f {} \;

