#!/bin/bash
#created by carson on 12/8/2016

dir=$1


# the directory(path)  exists or not ?
if [ ! -d "$dir" ] ; then
		mkdir -p $dir
		echo " $dir has been created and it's directory structure is"
		tree $dir

else
	echo "$dir is exists !"

fi
 
		

