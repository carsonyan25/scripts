#!/usr/bin/python
#code:utf8
#created by carson

import commands
import sys

class nodejs():
	
	def __init__(self):
		pass
	def PullandGrunt(self,path):  # define git pull function
		result=commands.getoutput(" cd {directory} && git pull && grunt " .format(directory=path))
		return result



# whate function does the user want to use ?
operation=str(sys.argv[1])
job=nodejs()
output="no operation\n"
if operation=="PullandGrunt":	
	output=job.PullandGrunt(sys.argv[2])
else :
	pass
print output	
	 
