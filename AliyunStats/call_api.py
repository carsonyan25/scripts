#!/usr/bin/python
#created by carson 
# this script call api in stats.pcw365.com server

import commands
import pycurl
import sys

# curl url to generate statistics
class API:

	def __init__(self):
		pass
	
	#Runing statistics for cad series software everyday
	def stats(self):
		c= pycurl.Curl()
		c.setopt(c.URL, 'http://stats.pcw365.com?validate=cadtest268')
		c.setopt(c.VERBOSE, True)
		c.perform()


if __name__ == '__main__':
	
	if sys.argv[1] == 'stats' :
		opt=API()
		opt.stats()
	else:
		pass
