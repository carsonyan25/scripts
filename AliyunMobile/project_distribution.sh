#!/bin/bash
#created by carson
#this script use to distribute docker project on aliyun mobile server


PROJECT_DIR=/data/projects/${1}


pull_code(){
	cd $PROJECT_DIR 
	sudo -u mobile git pull 
}

update_docker_setting(){
	/usr/bin/docker -ti --rm -v  $PROJECT_DIR/:/home pwww.pcw365.com:5000/nodejs sh -c 'cd /home && npm install' 
}

delete_pod(){
	/usr/bin/kubectl get pods -n project | grep ${1} |awk '{print $1}'|xargs  kubectl delete pods  -n project
}

pull_code
update_docker_setting
delete_pod


