#!/usr/bin/env python
# code:utf8
# created by carson
# update all database in code server


import commands
import MySQLdb
import sys
import time
import re

# this class is copy database backup and unzip them to /tmp
class CopyUnzip: 

	def __init__(self):
		self.curdate=time.strftime("%Y%m%d",time.localtime()) # get current date
		self.pcw_prefix='/backup/www_pcw365_com/databases/fullbackup/'
		self.cad_prefix='/backup/cad_pcw365_com/database/fullbackup/'
		pcw_file="{prefix}pcw-ecshop-{DATE}.sql.gz".format(prefix=self.pcw_prefix,DATE=self.curdate)
		vipapps_file="{prefix}cad-vipapps-{DATE}.sql.gz".format(prefix=self.cad_prefix,DATE=self.curdate)
		other_file="{prefix}cad-other-without-big-table-{DATE}.sql.gz".format(prefix=self.cad_prefix,DATE=self.curdate)
		aec_big_file="{prefix}cad-aec-big-table-{DATE}.tar.gz".format(prefix=self.cad_prefix,DATE=self.curdate)
		#self.filelist=[pcw_file,vipapps_file,other_file,aec_big_file]
		self.filelist=[pcw_file,vipapps_file]

	# this method is copy database backup to /tmp
	def copy_file(self):
		for afile in self.filelist:
			commands.getoutput(" cp {FILE}  /tmp/  ".format(FILE=afile))
	
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
			if re.search("aec-big-table",afile) :
				commands.getoutput(" cd /tmp; tar -xf {FILE}".format(FILE=afile))
			else :
				commands.getoutput(" cd /tmp; gzip -d {FILE}".format(FILE=afile))

# this class is delete database file in /tmp		
class DelFile:
	
	def __init__(self):
		self.curdate=time.strftime("%Y%m%d",time.localtime())
	def delete_file(self):
		commands.getoutput(" rm -f /tmp/*{DATE}.sql".format(DATE=self.curdate))
		commands.getoutput(" rm -f /tmp/*{DATE}.data ".format(DATE=self.curdate))
		commands.getoutput(" rm -f /tmp/*{DATE}.form ".format(DATE=self.curdate))
		commands.getoutput(" rm -f /tmp/*{DATE}.tar.gz ".format(DATE=self.curdate))
		commands.getoutput(" rm -f /tmp/*{DATE}.sql.gz ".format(DATE=self.curdate))


#this class is to update all database with backup file
class 	UpdateDB:
        def __init__(self):
		self.curdate=time.strftime("%Y%m%d",time.localtime())
	#method to import pcw database backup into target host		
	def import_pcw(self):
		pcw_bak="/tmp/pcw-ecshop-{DATE}.sql".format(DATE=self.curdate)
		pcw_db=["ecshop","pcwcms","pc","budget","b2bsite","pcwb2bs"]
		con=MySQLdb.connect(host='192.168.1.233',user='root',passwd='f5x/pdWUtDgAyz5R')
		db_op=con.cursor()
		for db in pcw_db:
			db_op.execute("drop database if exists {DB}".format(DB=db))
		db_op.close()
		commands.getoutput("mysql -h192.168.1.233 -uroot -pf5x/pdWUtDgAyz5R < {bak}".format(bak=pcw_bak))	
                logfile=open("/root/shell/update_all_database.log","a")
		curtime=time.strftime("%Y%m%d-%H%M",time.localtime())
                logfile.write("{time} {filename} has been load\n".format(filename=pcw_bak,time=curtime))
                logfile.close()

	
	#method to import vipapps database backup into target host		
	def import_vipapps(self):
		vipapps_bak="/tmp/cad-vipapps-{DATE}.sql".format(DATE=self.curdate)
		con=MySQLdb.connect(host='192.168.1.233',user='root',passwd='f5x/pdWUtDgAyz5R')
		db_op=con.cursor()
		db_op.execute("drop database if exists vipapps;")
		db_op.close()
		commands.getoutput("mysql -h192.168.1.233 -uroot -pf5x/pdWUtDgAyz5R < {bak}".format(bak=vipapps_bak))	
                logfile=open("/root/shell/update_all_database.log","a")
		curtime=time.strftime("%Y%m%d-%H%M",time.localtime())
                logfile.write("{time} {filename} has been load\n".format(filename=vipapps_bak,time=curtime))
                logfile.close()
                db_op.close()

	#method to import other database backup into target host		
	def import_other(self):
		other_db=[ "MiniCADPrice" , "ad" , "adplan" , "aec" , "aecpro" , "authen" , "bak_test" , "cad" , "hc_data" , "home_design" , "homecost" , "iptocity" , "logs" , "mycode" , "new" , "selling" , "shejie" , "softwares" , "steel" , "test" , "test3" , "xietong" , "xietong_test" , "xietong_test2"]
		other_bak="/tmp/cad-other-without-big-table-{DATE}.sql".format(DATE=self.curdate)
		con=MySQLdb.connect(host='192.168.1.233',user='root',passwd='f5x/pdWUtDgAyz5R')
		db_op=con.cursor()
		for db in other_db:
			db_op.execute("drop database if exists {DB} ;".format(DB=db))
		db_op.close()
		commands.getoutput("mysql -h192.168.1.233 -uroot -pf5x/pdWUtDgAyz5R < {bak}".format(bak=other_bak))	
                logfile=open("/root/shell/update_all_database.log","a")
		curtime=time.strftime("%Y%m%d-%H%M",time.localtime())
                logfile.write("{time} {filename} has been load\n".format(filename=other_bak,time=curtime))
                logfile.close()

	#method to create aec big table and import backup data on target host		
	def aec_big_table(self):
		FORM=["usercount_1_150824","usercount_1_170118","usercount_1","usercount_1_device","usercount","usercount_last"]
		sql="/tmp/aec_big_table-{DATE}.form".format(DATE=self.curdate)
		commands.getoutput("mysql -h192.168.1.233 -uroot -pf5x/pdWUtDgAyz5R  aec < {SQL}".format(SQL=sql))	#create aec big tables
		con=MySQLdb.connect(host='192.168.1.233',user='root',passwd='f5x/pdWUtDgAyz5R',db='aec')
		db_op=con.cursor()
		for form in FORM:
			curfile=form + "-{DATE}.data".format(DATE=self.curdate)
			db_op.execute("load data infile '{FILE}' into table {TABLE} fields terminated by ',' ;" .format(FILE=curfile,TABLE=form))		
			logfile=open("/root/shell/update_all_database.log","a")
			curtime=time.strftime("%Y%m%d-%H%M",time.localtime())
                	logfile.write("{time} {filename} has been load\n".format(filename=curfile,time=curtime))
                	logfile.close()
		db_op.close()
	



if __name__=='__main__':

#copy and unzip database backup file to /tmp for temporary use

	job=CopyUnzip()
	job.copy_file()
	job.unzip_file()

#import backup to code server database
	job=UpdateDB()
	job.import_pcw()
	job.import_vipapps()
#	job.import_other()
#	job.aec_big_table()

#delete all backup file in /tmp
#	job=DelFile()
#	job.delete_file()



