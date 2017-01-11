#!/usr/bin/python
#created by carson
# use to create mysql user and grant privileges
import MySQLdb
import sys


class mysql_operation:
        def __init__(self,arglist):
		self.Host=arglist[0]
		self.User=arglist[1]
		self.Passwd=arglist[2]
		self.NewUser=arglist[3]
		self.NewPass=arglist[4]
                pass
        def create_user(self):
                self.con=MySQLdb.connect(host=self.Host,user=self.User,passwd=self.Passwd)
                db_op=self.con.cursor()
                db_op.execute("create user {username} identified by '{userpass}' ; ".format(username=self.NewUser,userpass=self.NewPass))
                db_op.execute("flush privileges;")
                db_op.close()
        def grant_privileges(self):
                self.con=MySQLdb.connect(host=self.Host,user=self.User,passwd=self.Passwd)
                db_op=self.con.cursor()
                self.grant_db=["ecshop","pc","pcwcms","pcwb2bs","b2bsite"]
                for db in self.grant_db:
                        db_op.execute("grant select,delete,update,create ,insert ,trigger,create temporary tables,index on {dbname}.*   to {username} ;".format(dbname=db,username=self.NewUser))
                db_op.execute("flush privileges;")
                db_op.close()
		print "User {username} has been created and grant privileges".format(username=self.NewUser)

if __name__ == '__main__' :
	alist=[sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5]]
	op1=mysql_operation(arglist=alist)
	op1.create_user()
	op1.grant_privileges()

