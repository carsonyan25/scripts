#!/bin/bash
#created by carson
# use to install zabbix_agentd on linux server

func=$1
listenip=$2
serverip=$3

config_pkg=zabbix_agentd_configuration_files.tar.gz
config_dir=/app/zabbix_agentd/etc/zabbix_agentd.conf.d

install_zabbix()
{
	cd /app/software/package
	zabbix_pkg=`ls zabbix-*.gz`
	zabbix_dir=` echo ${zabbix_pkg} | cut -d '.' -f1-3 `
	tar -xf ${zabbix_pkg}  -C ../
	cd /app/software/${zabbix_dir}
	./configure --prefix=/app/zabbix_agentd  --enable-agent && make && make install 
	if [ $? -ne 0 ] ; then
		exit 0
	fi

}

setting_zabbix()
{
	cd /app/zabbix_agentd/etc/
	sed -i   s:^Server=.*:Server=${serverip}: zabbix_agentd.conf
	sed -i   s:^Hostname=.*:Hostname=127.0.0.1: zabbix_agentd.conf
	sed -i   s:.*ListenIP=.*:ListenIP=${listenip}: zabbix_agentd.conf
	sed -i   s:\#.*AllowRoot=.*:AllowRoot=1: zabbix_agentd.conf
    echo "Include=/app/zabbix_agentd/etc/zabbix_agentd.conf.d/*.conf"  >> zabbix_agentd.conf
}

post_install()
{

	cd  ${config_dir} 
	tar -xf ${config_pkg} 
	mkdir -p /var/lib/zabbix
	mv .my.cnf  /var/lib/zabbix/.my.cnf
	mv partition_low_discovery.sh  /app/zabbix_agentd/bin/
	rm -f  ${config_pkg}
	if [ $? == 0 ] ; then 
		echo "post installation is ok"
	fi
}

mentions()
{
	echo "zabbix-3.0.4 install to /app/zabbix_agentd"
	echo "you should modify zabbix_agentd.conf ,userparameter_xx.conf and /var/lib/zabbix/.my.cnf before start zabbix_agentd "
}
	
case ${func} in 

	install_set) 
			install_zabbix
			setting_zabbix
			;;
	post_install)
			post_install
			;;
	mention)
			mentions
			;;
		*)
			echo "usage: scriptnanme func [listenip] [install_prefix]" 
			;;
esac
