#!/usr/bin/python
#created by carson 
# this script used to generate new cad user  statistics in code server database

import commands
import time
import MySQLdb
import sys
import pycurl

TIMEFMT="%Y%m%d"
curdate=time.strftime(TIMEFMT,time.localtime())
aec_file="cad-aec-big-table-{DATE}.tar.gz".format(DATE=curdate)
dest_file="usercount_1_170331-{DATE}.data".format(DATE=curdate)

#a method that copy new cad-aec-big-table backup from backup server to code server
def copy_file():
	src="backup-company@backup.pcw365.com::backup-cad/database/fullbackup/cad-aec-big-table-{DATE}.tar.gz".format(DATE=curdate)
	result=commands.getstatusoutput("rsync -avpP --quiet --password-file=/root/shell/backup_server.pass  {SRC} /tmp".format(SRC=src))
	print result	

# uncompress backup file to /tmp 
def uncompress():
        commands.getoutput("cd /tmp && tar --transform s/aec_big_table// -xf {SRC} aec_big_table/{DEST} ".format(SRC=aec_file,DEST=dest_file))

# import backup data to code server's database
def import_stats(curfile,table):
        con=MySQLdb.connect(host='localhost',user='root',passwd='f5x/pdWUtDgAyz5R',db='stats',read_default_file='/etc/my.cnf')
        db_op=con.cursor()
        db_op.execute("truncate {TABLE} ;".format(TABLE=table))
        db_op.execute("load data infile '{FILE}' into table {TABLE} fields terminated by ',' ;" .format(FILE=curfile,TABLE=table))
        curtime=time.strftime("%Y%m%d-%H%M",time.localtime())
        logfile=open("/root/shell/import_stats_big_table.log","a")  #write log
        logfile.write(" {time} {filename} has been load\n".format(filename=curfile,time=curtime))
        logfile.close()
        db_op.close()

# remove backup file in /tmp 
def remove_file():
	result=commands.getstatusoutput("cd /tmp && rm -f cad-*.tar.gz usercoun*.data aec*.form")
	print result

# curl url to generate statistics
class generate_stats:

	def __init__(self):
		pass
	
	def increment(self):
		c= pycurl.Curl()
		c.setopt(c.URL, 'http://test.pcw365.com/disk/statistics/increment.php')
		c.setopt(c.POSTFIELDS,'validate=cadtest268')
		c.setopt(c.VERBOSE, True)
		c.perform()

	def total(self):
		c= pycurl.Curl()
		c.setopt(c.URL, 'http://test.pcw365.com/disk/statistics/total.php')
		c.setopt(c.POSTFIELDS,'validate=cadtest268')
		c.setopt(c.VERBOSE, True)
		c.perform()

if __name__ == '__main__':
	copy_file()
	uncompress()
	import_stats(curfile="/tmp/" + dest_file,table="usercount_1_170331")
	remove_file()
	stats=generate_stats()
	stats.increment()
	stats.total()
else :
	pass
