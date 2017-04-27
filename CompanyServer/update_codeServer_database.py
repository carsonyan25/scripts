#!/usr/bin/python
# -*- coding: UTF-8 -*-
#created by carson
# this script  used to update vipapps and pcw database on code server

import threading
import time
import MySQLdb
import commands 
import re

# this class is copy database backup and unzip them to /tmp
class CopyUnzip:

	def __init__(self):
		self.curdate=time.strftime("%Y%m%d",time.localtime()) # get current date
		self.pcw_prefix='/backup/www_pcw365_com/databases/fullbackup/'
		self.cad_prefix='/backup/cad_pcw365_com/database/fullbackup/'
		pcw_file="{prefix}pcw-ecshop-{DATE}.sql.gz".format(prefix=self.pcw_prefix,DATE=self.curdate)
		cad_file="{prefix}cad-vipapps-{DATE}.sql.gz".format(prefix=self.cad_prefix,DATE=self.curdate)
		self.filelist=[pcw_file,cad_file]

	# this method is copy database backup to /tmp
	def copy_file(self):
		for afile in self.filelist:
			commands.getoutput(" cp -f {FILE}  /tmp/  ".format(FILE=afile))

	#this method is unzip backup file
	def unzip_file(self):

		newlist=[]
		for string1 in self.filelist:
			if re.search(self.pcw_prefix,string1):
				newstr=string1.replace(self.pcw_prefix,'')
			else :
				newstr=string1.replace(self.cad_prefix,'')
			newlist.append(newstr)

		for afile in newlist:
			commands.getoutput(" cd /tmp &&  pigz -f -d {FILE}".format(FILE=afile))


# this class is delete database file in /tmp            
class DelFile:

	def __init__(self,FILENAME):
		self.FILE=FILENAME
	
	def delete_file(self):
		commands.getoutput(" rm -f {filename}*".format(filename=self.FILE))


#create multi threads and run them parallel

class MultiThread (threading.Thread):   #inherited from threading.Thread ,overwrite method __init__ and run

	def __init__(self, threadID, name,FileName,DBlist): 
		threading.Thread.__init__(self)
		self.threadID = threadID
		self.name = name
		self.FILE=FileName
		self.DB=DBlist

	def run(self):  # call import_db method                
		self.import_db(self.FILE,self.DB)

	def import_db(self,FILE,DB):
		con=MySQLdb.connect(host='192.168.1.233',user='root',passwd='f5x/pdWUtDgAyz5R')
		db_op=con.cursor()
		for db in DB:
			db_op.execute("drop database if exists {dbname}".format(dbname=db))
		db_op.close()
		commands.getoutput("/app/mysql5/bin/mysql -h192.168.1.233 -uroot -pf5x/pdWUtDgAyz5R  < {FILENAME} ".format(FILENAME=FILE))
		curtime=time.strftime("%Y%m%d",time.localtime())
		log=open("/root/shell/update_codeServer_database.log","a")
		log.write("{CURTIME} {FILENAME} has been loaded \n ".format(CURTIME=curtime,FILENAME=FILE))
		log.close()
        content=commands.getoutput("tail /root/shell/update_codeServer_database.log")
        print(content)
		delfile=DelFile(FILE)
		delfile.delete_file()
 

if __name__ == '__main__' :

	job=CopyUnzip()
	job.copy_file()
	job.unzip_file()

	#initilize the variables , get current date ,backup file and databasename
	curdate=time.strftime("%Y%m%d",time.localtime())
	cad_file="/tmp/cad-vipapps-{CURDATE}.sql".format(CURDATE=curdate)
	cad_db=["vipapps"]
	pcw_file="/tmp/pcw-ecshop-{CURDATE}.sql".format(CURDATE=curdate)
	pcw_db=['pc','pcwcms','pcwb2bs','b2bsite','ecshop','budget','minimarket','minicmf']
	
	#create multi threads
	thread1 = MultiThread(1,"Thread-1",cad_file,cad_db)
	thread2 = MultiThread(1,"Thread-2",pcw_file,pcw_db)
	
	#start threads
	thread1.start()
	thread2.start()
	

