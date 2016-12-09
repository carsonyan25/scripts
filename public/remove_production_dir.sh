#!/bin/bash
#created by carson on 12/8/2016
# use to remove a production directory on server by playbook 

dir=$1 


# the directory(path)  exists or not ?
if [ ! -d "$dir" ] ; then
	echo "$dir isn't exists"
else
	rm -fr $dir
	echo "$dir has been removed"
fi
 
		

