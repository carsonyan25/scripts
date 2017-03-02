#!/usr/bin/python
#created by carson 
# used to copy aec database backup to code server from backup server

import commands
import time

def copy_file():
	TIMEFMT="%Y%m%d"
	curdate=time.stftime(TIMEFMT,time.localtime())
	src="/backup/cad_pcw365_com/database/fullbackup/cad-aec-big-table-{NOW}.tar.gz".format(NOW=curdate)
	result=commands.getstatusoutput("rsync -avpP --quiet --password-file=/root/shell/codeserver.pass  {SRC}  code-company@code.pcw365.com::tmp".format(SRC=src))
	print result	


copy_file()
