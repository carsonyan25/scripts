#!/usr/bin/python
#coding:utf8
#created by carson
#this scripts use to return sync backup log to client , using by ansible tower playbook


import os
import sys

class log_handle:
	def __init__(self,logfile):
		self.logfile=logfile
	def view(self):
		flag="False"
		flag=os.path.exists(self.logfile)
		if str(flag)=="True" :
			with open(self.logfile,"r") as openlog:
				content=openlog.readlines()
			for line in content:
				print line.rstrip()
		else:
			print "{logfile} isn't exists".format(logfile=self.logfile) 


if __name__=='__main__' :
	if str(sys.argv[1])!="" :
		logfile=sys.argv[1]
		loghandle=log_handle(logfile)
		loghandle.view()
	else:
		print "please specified a logfile" 


		
		
		

