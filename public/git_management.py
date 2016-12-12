#!/usr/bin/python
#code:utf8
#created by carson

import commands
import sys

class git_management():
	
	def __init__(self):
		pass
	def pull(self,path):  # define git pull function
		result=commands.getoutput(" cd {directory} && git pull " .format(directory=path))
		return result
	def get_log(self,path): # define git log function
		result=commands.getoutput(" cd {directory} && git log " .format(directory=path))
		return result	    # define git reset --hard HEADnumber	
	def rollback(self,path,head):
		result=commands.getoutput(" cd {directory} && git reset --hard {headnumber} " .format(directory=path,headnumber=head))
		return result



# whate function does the user want to use ?
operation=str(sys.argv[1])
do_git=git_management()
output="no operation\n"
if operation=="pull":	
	output=do_git.pull(sys.argv[2])
elif operation=="get_log":
	output=do_git.get_log(sys.argv[2])
elif operation=="rollback":
	output=do_git.rollback(sys.argv[2],sys.argv[3])
else :
	pass
print output	
	 
