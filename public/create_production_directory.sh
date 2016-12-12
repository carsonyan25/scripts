#!/bin/bash
#created by carson on 12/8/2016

dir=$1
mode=$2 


# the directory(path)  exists or not ?
if [ ! -d "$dir" ] ; then
	if [ $mode -ne ""  ] ; then 
		mkdir  -m $mode -p $dir
		echo " $dir has been created and it's directory structure is \n "
	else
		mkdir -p $dir

	echo " $dir has been created and it's directory structure is \n "
	tree $dir

else
	echo "$dir is exists !"

fi
 
		

