#!/usr/bin/env  python
#create by carson


import MySQLdb

def  exec_sql():
	conn=MySQLdb.connect(host="139.224.26.199",user="root",passwd="IAGo1oy-881Nt2K\\",db="aec")
	dbcursor=conn.cursor()
	dbcursor.execute("repair  no_write_to_binlog table  usercount_1_160926 ;")
	result=dbcursor.fetchall()
	#result=dbcursor.fetchmany(size=3)
	for row in result:
		for col in row:
			print col
	dbcursor.close()


exec_sql()



