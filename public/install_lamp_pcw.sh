#!/bin/bash
#support OS: centos-7.0
#created by carson 2016-8-24
# just for pcw server install 
#this souce lamp contains  apache 2.2.25 , php 5.4.3 and mysql-5.1.73
# download all source package from official website 
# all source package place in /app/software/package ,unzip to /app/software
# all source package  install to /home/server

prepare_install(){

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
rpm -qa | grep -i -E "apache|httpd|mysql|php|httpd-tools" | xargs yum remove   -y 


# install dependencies
yum install -y  autoconf libz libxml2-devel  openssl openssl-devel bzip2-devel  libcurl-devel enchant enchant-devel enchant-aspell  libXpm-devel gmp-devel uw-imap-devel libicu-devel  libtidy-devel  openldap-devel   unixODBC-devel libpqxx-devel php-pspell libedit-devel recode-devel net-snmp-devel net-snmp-libs net-snmp libxslt-devel  zlib  ncurses-devel bison make gcc gcc-c++ cmake libjpeg-turbo libjpeg-turbo-devel libpng-devel libpng  freetype freetype-devel libmcrypt libmcrypt-devel

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
./configure --prefix=/home/server/jpeg  --enable-shared --enable-static  
if [ $? -ne 0 ]  ;  then 
     {
          echo " configure jpeg error " ;
          exit 1;
     }

else
     { 
          make ;
          if  [ $? -ne 0 ] ; then
               {
                     echo "compile jpeg error(make)" ;
                     exit 1;
               }
           else
               { 
                    mkdir -p /home/server/jpeg/bin
                    mkdir -p /home/server/jpeg/include
                    mkdir -p /home/server/jpeg/lib
                    mkdir -p /home/server/jpeg/man/man1
                    make install ;
               }   
           fi   
     } 
fi


#install freetype
cd /app/software/
pkg_name="freetype"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir
./configure --prefix=/home/server/freetype
if  [ $? -ne 0 ]  ;  then 
     {
          echo " configure freetype error " ;
          exit 1;
     }

else
     { 
          make ;
          if  [ $? -ne 0] ; then
               {
                     echo "compile freetype error(make)" ;
                     exit 1;
               }
           else
                    make install ;    
           fi   
     } 
fi

#install libxml2
cd /app/software/
pkg_name="libxml2"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir
./configure   --with-iconv   --prefix=/home/server/libxml2
if  [ $? -ne 0 ]  ;  then 
     {
          echo " configure libxml2 error " ;
          exit 1;
     }

else
     { 
          make ;
          if  [ $? -ne 0] ; then
               {
                     echo "compile libxml2 error(make)" ;
                     exit 1;
               }
           else
                    make install ;    
           fi   
     } 
fi

#install pcre
cd /app/software/
pkg_name="pcre"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir
./configure    --prefix=/home/server/pcre
if  [ $? -ne 0 ]  ;  then 
     {
          echo " configure pcre-8.39 error " ;
          exit 1;
     }

else
     { 
          make ;
          if  [ $? -ne 0] ; then
               {
                     echo "compile pcre-8.39 error(make)" ;
                     exit 1;
               }
           else
                    make install ;    
           fi   
     } 
fi

# add libs to system path
echo "/home/server/jpeg/lib" > /etc/ld.so.conf.d/jpeg.conf
echo "/home/server/freetypelib" > /etc/ld.so.conf.d/freetype.conf
echo "/home/server/libxml2/lib" > /etc/ld.so.conf.d/libxml2.conf
ldconfig
}

install_mysql(){

#create mysql user
useradd -U -c "MySQL Server user" -M -s /sbin/nologin mysql

cd /app/software/mysql-5.1.73
./configure --prefix=/home/server/mysql5 --with-extra-charsets=all --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-big-tables --with-ssl --enable-local-infile --with-plugins=innobase,myisam,partition,heap,blackhole,csv,archive,ndbcluster --with-embedded-server --with-charset=utf8 -with-collation=utf8_general_ci

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
echo "if ! echo \${PATH} | /bin/grep -q /home/server/mysql5/bin ; then" > /etc/profile.d/mysql.sh
echo "PATH=\${PATH}:/home/server/mysql5/bin" >> /etc/profile.d/mysql.sh
echo "export PATH" >> /etc/profile.d/mysql.sh
echo "fi"  >> /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh

#Adding MySQL Server libraries to the shared library cache
echo "/home/server/mysql5/lib" > /etc/ld.so.conf.d/mysql.conf
ldconfig

#Adding MySQL to service
mkdir /home/server/mysql5/data
chown -R mysql:mysql  /home/server/mysql5
cp /home/server/mysql5/support-files/mysql.server  /etc/init.d/mysqld
sed -i s:basedir=\s*$:basedir=/home/server/mysql5:g    /etc/init.d/mysqld
sed -i s:datadir=\s*$:datadir=/home/server/mysql5/data:g    /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on

return 0
}




install_apache(){
# build and install apache (2.2.25)
#install dependencies
# download package apr and apr-util from apache.org
cd /app/software/package
tar --transform s/apr-util-1.5.4/apr-util/ -C ../httpd-2.2.25/srclib/ -zxf apr-util-1.5.4.tar.gz
tar --transform s/apr-1.5.2/apr/ -C ../httpd-2.2.25/srclib/ -zxf apr-1.5.2.tar.gz


#configure and install apache
cd /app/software/httpd-2.2.25
./configure --prefix=/home/server/apache2 --sysconfdir=/home/server/apache2/conf --disable-userdir --with-mpm=worker --enable-mods-shared=most --enable-modules=most --enable-v4-mapped --with-included-apr --enable-so --enable-deflate=shared --enable-expires=shared --enable-rewrite=shared --enable-static-support --with-ssl=/usr  --with-libdir=/usr/lib64 --enable-option-checking 

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
echo "if ! echo \${PATH} | /bin/grep -q /home/server/apache2/bin ; then" > /etc/profile.d/apache.sh
echo "PATH=\${PATH}:/home/server/apache2/bin" >>  /etc/profile.d/apache.sh
echo "fi" >> /etc/profile.d/apache.sh
source /etc/profile.d/apache.sh
chown -R apache:apache  /home/server/apache2/htdocs
return 0
}



#build and install php

install_php(){



cd /app/software/php-5.4.3/
./configure --prefix=/home/server/php5.4.3 --with-config-file-path=/home/server/php5.4.3/etc --cache-file=./config.cache --with-zlib --with-libdir=lib64 --with-openssl=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-apxs2=/home/server/apache2/bin/apxs --with-libxml-dir=/home/server/libxml2 --with-jpeg-dir=/home/server/jpeg --with-freetype-dir=/home/server/freetype --with-gd --with-curl --with-mcrypt --enable-zip  --enable-xml --enable-mbstring --enable-sockets --enable-bcmath --enable-xmlwriter --enable-xmlreader --enable-fpm  --enable-maintainer-zts  --enable-option-checking

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
	mentions
}

mentions()
{
	echo "source package LAMP(apache-2.2.25 ,mysql-5.1.73 and php-5.4.3) has been installed to /home/server "
	echo "you need to initialize mysql manully ! \n"
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
    prepare)
       prepare_install
       ;;
	mention)
		mentions
		;;
    *)
        echo "usage :: lamp | mysql | apache | php | mention \n " 
        ;;
esac
