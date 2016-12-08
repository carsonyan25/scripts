#!/bin/bash
#support OS: centos-7.0
#created by carson 2016-8-24
#this souce lamp contains  apache 2.4.23 , php 5.4.3 and mysql.5.6.33
# download all source package from official website 
# all source package place in /app/software/package ,unzip to /app/software
# all source package  install to /app

prepare_install(){

yum install -y  libmcrypt libmcrypt-devel libtool  libtool-ltdl libtool-ltdl-devel libxml2-devel  openssl openssl-devel bzip2-devel  libcurl-devel enchant enchant-devel enchant-aspell  libXpm-devel gmp-devel uw-imap-devel libicu-devel  libtidy-devel  openldap-devel   unixODBC-devel libpqxx-devel php-pspell libedit-devel recode-devel net-snmp-devel net-snmp-libs net-snmp libxslt-devel  zlib  ncurses-devel bison make gcc gc++ cmake

lamp_result=""
#check if its apache ,mysql,php running
lamp_result= `ps aux | grep -E 'httpd|php|mysql'`
if $lamp_result != "" ;  then
     {
          echo "apache , mysql or php running or this system\n   stop the service and remove them manually!\n"
          exit 1;
     }   
fi

# remove all  package about apache(httpd),mysql,php install from yum
rpm -qa | grep -i -E "apache|httpd|mysql|php" | xargs yum remove   -y

# begin lamp install

#unzip source packages
cd /app/software/package
for src_pkg in `ls *.tar.gz `  ;
     do
          tar -xzf $src_pkg  -C ../
done
if  [ $? -ne 0 ] ; then
        {
                echo "unzip source packages  error\n"
                exit 1;
        }
fi

#install jpeg
cd /app/software/
pkg_name="jpeg"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir
cp -f /usr/share/libtool/config/config.sub .
cp -f  /usr/share/libtool/config/config.guess .
cp -f /usr/bin/libtool  .
./configure --prefix=/app/jpeg  --enable-shared --enable-static  && make 

if [  $?  -eq  0 ] ;  then {
                    mkdir -p /app/jpeg/bin
                    mkdir -p /app/jpeg/include
                    mkdir -p /app/jpeg/lib
                    mkdir -p /app/jpeg/man/man1
                    make install 
}
fi


#install freetype
cd /app/software/
pkg_name="freetype"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir
./configure --prefix=/app/freetype && make && make install


#install libxml2
cd /app/software/
pkg_name="libxml2"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir
./configure   --with-iconv   --prefix=/app/libxml2 && make &&　make install 

#install pcre
cd /app/software/
pkg_name="pcre"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir
./configure    --prefix=/app/pcre &&　make && make install 


# add libs to system path
echo "/app/jpeg/lib" > /etc/ld.so.conf.d/jpeg.conf
echo "/app/freetype/lib" > /etc/ld.so.conf.d/freetype.conf
echo "/app/libxml2/lib" > /etc/ld.so.conf.d/libxml2.conf
ldconfig


}

install_mysql(){

#create mysql user
useradd -U -c "MySQL Server user" -M -s /sbin/nologin mysql

#configure and install mysql
#use cmake . -LAH( show all options and help)

cd mysql-5.6.33
cmake . -DCMAKE_INSTALL_PREFIX=/app/mysql5 -DMYSQL_DATADIR=/app/mysql5/data -DWITH_BOOST=/app/software/mysql-5.6.33/boost -DSYSCONFDIR=/etc -DENABLE_GPROF=1 -DWITH_EXTRA_CHARSETS=all -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DWITH_LIBEVENT=bundled   -DWITH_INNODB_MEMCACHED=1  

if [ $? -ne 0 ]  ;  then
     {
          echo " configure mysql error,  check configure opitons ,delete CMakeCache.txt and run cmake again. \n" 
          exit 1;
     }
else 
     {
          make VERBOSE=1
          if  [ $?  -ne 0 ] ; then
               {
                    echo "mysql  make VERBOSE=1 error \n "
                    exit 1;
               }
          else
               {
                    make      
                     if  [ $?  -ne 0 ] ; then
                    {
                         echo "mysql make error \n "
                         exit 1;
                    }
                    else
                         make install 
                   fi
               }
          fi
     }
fi



# mysql Post Installation Procedures
#Adding MySQL Server executables to system PATH
# Create a file mysql.sh in /etc/profile.d/ directory with the below content.
echo "if ! echo \${PATH} | /bin/grep -q /app/mysql5/bin ; then" > /etc/profile.d/mysql.sh
echo "PATH=\${PATH}:/app/mysql5/bin" >> /etc/profile.d/mysql.sh
echo "export PATH" >> /etc/profile.d/mysql.sh
echo "fi"  >> /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh

#Adding MySQL Server libraries to the shared library cache
echo "/app/mysql5/lib" > /etc/ld.so.conf.d/mysql.conf
ldconfig

#Adding MySQL to service
mkdir /app/mysql5/data
chown -R mysql:mysql  /app/mysql5
cp /app/mysql5/support-files/mysql.server  /etc/init.d/mysqld
sed -i s:basedir=\s*$:basedir=/app/mysql5:g    /etc/init.d/mysqld
sed -i s:datadir=\s*$:datadir=/app/mysql5/data:g    /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on

return 0
}




install_apache(){
# build and install apache (2.4.23)
#install dependencies
# download package apr and apr-util from apache.org
cd /app/software/package
tar --transform s/apr-util-1.5.4/apr-util/ -C ../httpd-2.4.23/srclib/ -zxf apr-util-1.5.4.tar.gz
tar --transform s/apr-1.5.2/apr/ -C ../httpd-2.4.23/srclib/ -zxf apr-1.5.2.tar.gz


#configure and install apache
cd /app/software/httpd-2.4.23
./configure --prefix=/app/apache2 --sysconfdir=/app/apache2/conf --disable-userdir --with-mpm=worker --enable-mods-shared=most --enable-modules=most --enable-v4-mapped --with-included-apr --enable-so --enable-deflate=shared --enable-expires=shared --enable-rewrite=shared --enable-static-support --with-ssl=/usr  --with-libdir=/usr/lib64 --enable-option-checking 

if  [ $? -ne 0 ]  ;  then 
     {
          echo " configure apache error " ;
          exit 1;
     }

else
     { 
          make ;
          if  [ $? -ne 0] ; then
               {
                     echo "compile apache error(make)" ;
                     exit 1;
               }
           else
                    make install ;    
           fi   
     } 
fi

#create apache user and set $PATH
useradd -M -r -U -s /sbin/nologin apache

#create apache.sh in /etc/profile.d/, content like below:
echo "if ! echo \${PATH} | /bin/grep -q /app/apache2/bin ; then" > /etc/profile.d/apache.sh
echo "PATH=\${PATH}:/app/apache2/bin" >>  /etc/profile.d/apache.sh
echo "fi" >> /etc/profile.d/apache.sh
source /etc/profile.d/apache.sh
chown -R apache:apache  /app/apache2/htdocs
return 0
}



#build and install php

install_php(){



cd /app/software/php-5.4.3/
./configure --prefix=/app/php5.4.3 --with-config-file-path=/app/php5.4.3/etc --cache-file=./config.cache --with-zlib --with-libdir=lib64 --with-openssl=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-apxs2=/app/apache2/bin/apxs --with-libxml-dir=/app/libxml2 --with-jpeg-dir=/app/jpeg --with-freetype-dir=/app/freetype --with-gd --with-curl --with-mcrypt --enable-zip  --enable-xml --enable-mbstring --enable-sockets --enable-bcmath --enable-xmlwriter --enable-xmlreader --enable-fpm  --enable-maintainer-zts  --enable-option-checking

if  [ $? -ne 0 ]  ;  then 
     {
          echo " configure php-5.4.3 error " ;
          exit 1;
     }

else
     { 
          make ;
          if  [ $? -ne 0 ] ; then
               {
                     echo "compile php-5.4.3 error(make)" ;
                     exit 1 ;
               }
           else
                    make install ;    
           fi   
     } 
fi

return 0
}


install_lamp(){
    prepare_install
    install_mysql
    install_apache
    install_php
    if [ $? -eq 0 ] ; then 
        echo "install LAMP successfully! \n" 
        echo "source package LAMP(apache-2.4.23 ,mysql-boost-5.6.33 and php-5.4.3) has been installed to /app \n"
		echo "you need to initialize mysql manully ! \n"
    else 
        echo "install lamp error"

    fi

}


case $1 in 

    lamp) 
        install_lamp
        ;;
    mysql)
        install_mysql
        ;;
    apache)
        install_apache
        ;;
    php)
        install_php
        ;;
    *)
        echo "usage :: lamp | mysql | apache | php \n " 
        ;;
esac


