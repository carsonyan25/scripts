#!/bin/bash
#created by carson
# use to install zabbix_agentd on linux server



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
	sed -i   s:Server=.*:Server=10.25.37.142:g zabbix_agentd.conf
	sed -i   s:Hostname=.*:Hostname=127.0.0.1:g zabbix_agentd.conf
	sed -i   s:ListenIP=.*:ListenIP=10.47.26.2:g zabbix_agentd.conf
	sed -i   s:\#.*AllowRoot.*:AllowRoot=1:g zabbix_agentd.conf
}


	
install_zabbix
setting_zabbix
