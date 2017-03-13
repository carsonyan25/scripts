#!/usr/bin/python
#code:utf8
#created by carson

import commands
import sys

class nodejs():
	
	def __init__(self):
		self.BINPATH="/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/root/.nvm/versions/node/v6.5.0/bin"
		pass
	def PullandGrunt(self,path):  # define git pull function
		result=commands.getoutput(" cd {directory} && git pull && export PATH={BINPATH} && grunt " .format(directory=path,BINPATH=self.BINPATH))
		return result



# what function does the user want to use ?
if  __name__ == '__main__'  :
	operation=str(sys.argv[1])
	job=nodejs()
	output="no operation\n"
	if operation=="PullandGrunt":	
		output=job.PullandGrunt(sys.argv[2])
	else :
		pass
		print output	
else :
	pass
			
