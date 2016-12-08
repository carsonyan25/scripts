#!/bin/bash
# created by carson 12/8/2016
# this script use to install lnmp(nginx ,mysql,php5 ) automatically  for all version 

install_dependencies(){

yum install -y  libmcrypt libmcrypt-devel libtool  libtool-ltdl libtool-ltdl-devel libxml2-devel  openssl openssl-devel bzip2-devel  libcurl-devel enchant enchant-devel enchant-aspell  libXpm-devel gmp-devel uw-imap-devel libicu-devel  libtidy-devel  openldap-devel   unixODBC-devel libpqxx-devel php-pspell libedit-devel recode-devel net-snmp-devel net-snmp-libs net-snmp libxslt-devel  zlib  ncurses-devel bison make gcc gc++ cmake

lnmp_result=""
#check if its nginx ,mysql,php running
lnmp_result= `ps aux | grep -E 'httpd|php|mysql'`
if $lnmp_result != "" ;  then
     {
          echo "nginx , mysql or php running or this system\n   stop the service and remove them manually!\n"
          exit 1;
     }   
fi

# remove all  package about nginx(httpd),mysql,php install from yum
rpm -qa | grep -i -E "nginx|httpd|mysql|php" | xargs yum remove   -y

# begin lnmp install

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

install_nginx(){

useradd  -U -c "nginx server user" -M  -s /sbin/nologin  nginx

cd /app/software/
pkg_name="nginx"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir

./configure --prefix=/app/nginx --sbin-path=/usr/sbin/nginx --conf-path=/app/nginx/etc/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_v2_module --with-ipv6    && make && make install
}


install_php(){
cd /app/software/
pkg_name="php"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir

./configure --prefix=/app/php  --with-config-file-path=/app/php/etc --cache-file=./config.cache --with-zlib --with-libdir=lib64 --with-openssl=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd  --with-libxml-dir=/app/libxml2 --with-jpeg-dir=/app/jpeg --with-freetype-dir=/app/freetype --with-gd --with-curl --with-mcrypt --enable-zip --enable-xml --enable-mbstring --enable-sockets --enable-bcmath --enable-xmlwriter --enable-xmlreader --enable-fpm --enable-maintainer-zts --enable-option-checking  && make && make install

# set php-fpm running as service
cd $src_dir
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
chkconfig --add php-fpm
cp /app/php/sbin/php-fpm /usr/sbin/
}

install_mysql(){

#create mysql user
useradd -U -c "MySQL Server user" -M -s /sbin/nologin mysql

#configure and install mysql
#use cmake . -LAH( show all options and help)
cd /app/software/
pkg_name="mysql"
src_dir=`ls -d ${pkg_name}*`
cd $src_dir

cmake . -DCMAKE_INSTALL_PREFIX=/app/mysql5 -DMYSQL_DATADIR=/app/mysql5/data -DWITH_BOOST=${src_dir}/boost -DSYSCONFDIR=/etc -DENABLE_GPROF=1 -DWITH_EXTRA_CHARSETS=all -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DWITH_LIBEVENT=bundled   -DWITH_INNODB_MEMCACHED=1

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

show_setting(){
cd /app/software/package
cat nginx_php_configuration.txt
}

install_lnmp(){

install_nginx
install_php
install_mysql
show_setting
}


case $1 in

    lnmp)
        install_lnmp
        ;;
    mysql)
        install_mysql
        ;;
    nginx)
        install_nginx
        ;;
    php)
        install_php
        ;;
    *)
        echo "usage :: lnmp | mysql | nginx | php \n "
        ;;
esac
