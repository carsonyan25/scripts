#!/usr/bin/python
#code:utf8

import commands
import sys

class git_management(self.op):
	
	def __init__(self):
		pass
	def pull(self,path):  # define git pull function
		result=commands.getoutput(" cd {directory} && git pull " .format(directory=path))
		return result
	def get_log(self,path): # define git log function
		result=commands.getoutput(" cd {directory} && git log " .format(directory=path))
		return result	    # define git reset --hard HEADnumber	
	def rollback(self,path,head):
		result=commands.getoutput(" cd {directory} && git reset --hard {headname} " .format(directory=path,headname=head))
		return result



# whate function does the user want to use ?
operation=sys.argv[1]
do_git=git_management()
if operation=="pull":	
	output=do_git.pull(sys.argv[2])
elif operation=="get_log":
	output=do_git.pull(sys.argv[2])
elif operation=="rollback":
	output=do_git.rollbackup(sys.argv[2],sys.argv[3])
else :
	pass
print output
	
	 
