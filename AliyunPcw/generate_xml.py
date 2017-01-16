#!/usr/bin/python
#created by carson
#this script use to generate xml file on aliyunpcw server

import pycurl
import sys

class exec_api:

	def init(self):
		pass

	def budgetXML(self):	# generate xml file from database budget on www.pcw365.com
		c = pycurl.Curl()
		c.setopt(c.URL, 'http://www.pcw365.com/ecshop2/Payadmin/index.php?g=api&m=Budget&a=saveXmlDate') # use GET method to pass parameters
		#c.setopt(c.POSTFIELDS, 'g=api&m=Budget&a=saveXmlDate') # when use POST method to pass the arguments to url
		c.setopt(c.VERBOSE, True)
		c.perform()

	def ecshopXML(self): # generate xml file from database ecshop on www.pcw365.com
		c = pycurl.Curl()
		c.setopt(c.URL, 'http://www.pcw365.com/ecshop2/Payadmin/index.php?g=api&m=Budget&a=updateXml')
		c.setopt(c.VERBOSE, True)
		c.perform()

if __name__ == '__main__' :
	api=exec_api()
	if len(sys.argv)<2 :
		print "one argument should be needed"
	else :
		if sys.argv[1]=="budget" :
			api.budgetXML()
		elif sys.argv[1]=="ecshop" :
			api.ecshopXML()
		else :
		 print "first argument is wrong" 

