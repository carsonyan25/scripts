#!/bin/bash
#created by carson on 12/8/2016

dir=$1 


# the directory(path)  exists or not ?
if [ ! -d "$dir" ] ; then
	mkdir -p $dir
else
	echo "$dir is exists ! \n"

fi
 
		

