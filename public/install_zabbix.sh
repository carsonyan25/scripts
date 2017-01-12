#!/bin/bash
#created by carson
# use to install zabbix_agentd on linux server



install_zabbix()
{
	cd /opt/package
	zabbix_pkg=`ls zabbix-*.gz`
	zabbix_dir=` echo ${zabbix_pkg} | cut -d '.' -f1-3 `
	tar -zxf ${zabbix_pkg}
	cd /opt/package/${zabbix_dir}
	./configure --prefix=/opt/software/zabbix_agentd  --enable-agent && make && make install 
	if [ $? -ne 0 ] ; then
		exit 0
	fi

}

setting_zabbix()
{
	cd /opt/software/zabbix_agentd/etc/
	sed -i   s:Server=.*:Server=10.25.37.142:g zabbix_agentd.conf
	sed -i   s:Hostname=.*:Hostname=mobile-team:g zabbix_agentd.conf
	sed -i   s:ListenIP=.*:ListenIP=10.47.26.2:g zabbix_agentd.conf
	sed -i   s:\#.*User=zabbix:User=zabbix:g zabbix_agentd.conf
}

start_zabbix()
{
	 useradd -U -M -c "zabbix_agentd user"  -s /sbin/nologin zabbix
	 cd /opt/software/zabbix_agentd/sbin/
	 ./zabbix_agentd	

}

	
#install_zabbix
#setting_zabbix
start_zabbix
