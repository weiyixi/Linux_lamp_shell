#!/bin/bash
# Version: 2.0.0
# Author: Json
# Date: 2016/7/5
# Description: LampDevelopEnvironment Install Script
# Linux-CentOS 6.0
# Apache-2.2.19
# MySQL-5.5.17
# PHP-5.3.6

tools_dir=$(cd `dirname $0`; pwd)

mkdir -p /lamp/wwwroot
mkdir -p /lamp/server/php
mkdir -p /lamp/server/mysql
mkdir -p /lamp/server/apache
mkdir -p /lamp/server/data
mkdir -p /lamp/server/log/install

cd $tools_dir
rpm  -ivh  ppl-0.10.2-11.el6.i686.rpm | tee /lamp/server/log/install/gcc_ppl.log
rpm  -ivh  cloog-ppl-0.15.7-1.2.el6.i686.rpm | tee /lamp/server/log/install/gcc_cloog-ppl.log
rpm  -ivh  mpfr-2.4.1-6.el6.i686.rpm | tee /lamp/server/log/install/gcc_mpfr.log
rpm  -ivh  cpp-4.4.7-3.el6.i686.rpm | tee /lamp/server/log/install/gcc_cpp.log
rpm  -ivh  kernel-headers-2.6.32-358.el6.i686.rpm | tee /lamp/server/log/install/gcc_kernel-headers.log
rpm  -ivh  glibc-headers-2.12-1.107.el6.i686.rpm | tee /lamp/server/log/install/gcc_glibc-headers.log
rpm  -ivh  glibc-devel-2.12-1.107.el6.i686.rpm | tee /lamp/server/log/install/gcc_glibc-devel.log
rpm  -ivh  gcc-4.4.7-3.el6.i686.rpm | tee /lamp/server/log/install/gcc_gcc.log
rpm  -ivh  libstdc++-devel-4.4.7-3.el6.i686.rpm | tee /lamp/server/log/install/gcc_libstdc++.log
rpm  -ivh  gcc-c++-4.4.7-3.el6.i686.rpm | tee /lamp/server/log/install/gcc_gcc-c++.log
clear
echo "
+------------------------------------------------+
|                Congratulations!                |
|                                                |
|              gcc install completed             |
|                                                |
|               next install MySQL               |
|                                                |
|                   auth:Json                    |
+------------------------------------------------+
"
sleep 3
sed '/22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT' -i /etc/sysconfig/iptables
sed '/80/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT' -i /etc/sysconfig/iptables
sed '/3306/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT' -i /etc/sysconfig/iptables
service iptables restart
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
/usr/sbin/setenforce 0

if [ -d "/lamp/server/mysql/bin" ]; then
    echo 'mysql has been installed'
    exit 1
fi



#------------------------------------------- install mysql---------------------------------------

cd $tools_dir
tar -zxf cmake-2.8.5.tar.gz | tee /lamp/server/log/install/mysql_cmake_tar.log
cd cmake-2.8.5
./bootstrap | tee /lamp/server/log/install/mysql_cmake_boots.log
make && make install | tee /lamp/server/log/install/mysql_cmake_install.log

cd $tools_dir
tar -zxf bison-2.7.tar.gz | tee /lamp/server/log/install/mysql_bison_tar.log
cd bison-2.7
./configure && make && make install | tee /lamp/server/log/install/mysql_bison_install.log

cd $tools_dir
rpm -ivh ncurses-devel-5.7-3.20090208.el6.i686.rpm | tee /lamp/server/log/install/mysql_ncurses-devel.log

cd $tools_dir
tar -zxf mysql-5.5.17.tar.gz | tee /lamp/server/log/install/mysql_mysql_tar.log
cd mysql-5.5.17
cmake \
-DCMAKE_INSTALL_PREFIX=/lamp/server/mysql \
-DMYSQL_DATADIR=/lamp/server/data \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci | tee /lamp/server/log/install/mysql_mysql_make.log
make && make install | tee /lamp/server/log/install/mysql_mysql_install.log

#------------------------------------------mysql conf---------------------------------------------
cd $tools_dir/mysql-5.5.17
\cp -f support-files/my-medium.cnf /etc/my.cnf
sed '/myisam_/a datadir=/lamp/server/data' -i  /etc/my.cnf
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql
chown -R mysql:mysql /lamp/server/data/
chown -R mysql:mysql /lamp/server/mysql/
/lamp/server/mysql/scripts/mysql_install_db \
--basedir=/lamp/server/mysql \
--datadir=/lamp/server/data \
--user=mysql
chown -R root /lamp/server/mysql
\cp -f /lamp/server/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
service mysqld start
/lamp/server/mysql/bin/mysqladmin -u root password 'admin'
/lamp/server/mysql/bin/mysql -uroot -padmin <<EOF
drop database test;
delete from mysql.user where user='';
update mysql.user set password=password('admin') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
clear
echo "
+------------------------------------------------+
|                Congratulations!                |
|                                                |
|             MySQL install completed            |
|                                                |
|               next install Apache              |
|                                                |
|            user:root   password:admin          |
|                                                |
|                   auth:Json                    |
+------------------------------------------------+
"
sleep 3

#---------------------------------------------- install apache-------------------------------------------

cd $tools_dir
tar -zxf zlib-1.2.5.tar.gz | tee /lamp/server/log/install/apache_zlib.log
cd zlib-1.2.5
./configure | tee /lamp/server/log/install/apache_zlib_configure.log
make && make install | tee /lamp/server/log/install/apache_zlib_install.log

cd $tools_dir
tar  -jxf  httpd-2.2.19.tar.bz2 | tee /lamp/server/log/install/apache_apache_tar.log
cd httpd-2.2.19
./configure --prefix=/lamp/server/apache \
--enable-modules=all \
--enable-mods-shared=all \
--enable-so | tee /lamp/server/log/install/apache_apache_configure.log
make && make install | tee /lamp/server/log/install/apache_apache_install.log
sed '/www.example.com:80/a ServerName localhost:80' -i  /lamp/server/apache/conf/httpd.conf

\cp -f /lamp/server/apache/bin/apachectl /etc/init.d/httpd
sed -i "2s/#/#chkconfig: 2345 10 90/" /etc/init.d/httpd
sed '/#chkconfig: 2345 10 90/a #description: Activates/Deactivates Apache Web Server' -i /etc/init.d/httpd
chmod 755 /etc/init.d/httpd
chkconfig --add httpd
chkconfig --level 345 httpd on
clear
echo "
+------------------------------------------------+
|                Congratulations!                |
|                                                |
|            Apache install completed            |
|                                                |
|               next install PHP 5.3             |
|                                                |
|                   auth:Json                    |
+------------------------------------------------+
"
sleep 3

#--------------------------------------------install php-------------------------------------------------

cd $tools_dir
tar -zxf libxml2-2.7.2.tar.gz | tee /lamp/server/log/install/php_libxm.log
cd libxml2-2.7.2
./configure --prefix=/lamp/server/libxml2  \
--without-zlib | tee /lamp/server/log/install/php_libxm_configure.log
make && make install | tee /lamp/server/log/install/php_libxm_install.log

cd $tools_dir
tar -zxf jpegsrc.v8b.tar.gz | tee /lamp/server/log/install/php_jpegsrc.log
cd jpeg-8b
./configure --prefix=/lamp/server/jpeg \
--enable-shared --enable-static | tee /lamp/server/log/install/php_jpegsrc_configure.log
make && make install | tee /lamp/server/log/install/php_jpegsrc_install.log

cd $tools_dir
tar zxf libpng-1.4.3.tar.gz | tee /lamp/server/log/install/php_libpng.log
cd libpng-1.4.3
./configure | tee /lamp/server/log/install/php_libpng_configure.log
make && make install | tee /lamp/server/log/install/php_libpng_install.log

cd $tools_dir
tar zxf freetype-2.4.1.tar.gz | tee /lamp/server/log/install/php_freetype.log
cd freetype-2.4.1
./configure --prefix=/lamp/server/freetype | tee /lamp/server/log/install/php_freetype_configure.log
make && make install | tee /lamp/server/log/install/php_freetype_install.log

cd $tools_dir
tar -zvxf gd-2.0.35.tar.gz | tee /lamp/server/log/install/php_gd2.log
mkdir -p /lamp/server/gd
cd gd-2.0.35
./configure --prefix=/lamp/server/gd  \
--with-jpeg=/lamp/server/jpeg/ \
--with-png --with-zlib \
--with-freetype=/lamp/server/freetype | tee /lamp/server/log/install/php_gd2_configure.log
make && make install | tee /lamp/server/log/install/php_gd2_install.log

cd $tools_dir
tar -jxf php-5.3.6.tar.bz2 | tee /lamp/server/log/install/php_php_tar.log
cd php-5.3.6
./configure --prefix=/lamp/server/php \
--with-apxs2=/lamp/server/apache/bin/apxs \
--with-mysql=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-freetype-dir=/lamp/server/freetype \
--with-gd=/lamp/server/gd \
--with-zlib --with-libxml-dir=/lamp/server/libxml2 \
--with-jpeg-dir=/lamp/server/jpeg \
--with-png-dir \
--enable-mbstring=all \
--enable-mbregex \
--enable-shared | tee /lamp/server/log/install/php_php_configure.log
make && make install | tee /lamp/server/log/install/php_php_install.log
cd $tools_dir/php-5.3.6
\cp -f php.ini-development /lamp/server/php/lib/php.ini

#----------------------------------------------------php config-------------------------------------------

sed -i "s/disable_functions =/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,escapeshellcmd,escapeshellarg,shell_exec,proc_get_status,ini_alter,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,leak,popepassthru,stream_socket_server,popen/" /lamp/server/php/lib/php.ini
sed '/;date.time/a date.timezone=PRC' -i  /lamp/server/php/lib/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /lamp/server/php/lib/php.ini
sed -i 's/;extension=php_mysql.dll/extension=php_mysql.dll/g' /lamp/server/php/lib/php.ini
sed -i 's/;extension=php_mysqli.dll/extension=php_mysqli.dll/g' /lamp/server/php/lib/php.ini
echo '<?php echo phpinfo();?>' > /lamp/server/apache/htdocs/index.php

#-------------------------------------------------httpd config------------------------------------------

mkdir -p /lamp/server/apache/conf.d/
sed -i "s/ServerTokens OS/ServerTokens ProductOnly/" /etc/httpd/conf/httpd.conf
sed -i "s/ServerSignature On/ServerSignature Off/" /etc/httpd/conf/httpd.conf
echo "Include conf.d/*.conf" >> /lamp/server/apache/conf/httpd.conf
sed -i "s/Deny from all/Allow from all/" /lamp/server/apache/conf/httpd.conf 
sed -i "s/AllowOverride None/AllowOverride All/" /lamp/server/apache/conf/httpd.conf
sed '/libphp5.so/a AddType application/x-httpd-php .php .asp .aspx' -i  /lamp/server/apache/conf/httpd.conf
sed '/x-httpd-php/a PHPIniDir /lamp/server/php/lib/php.ini' -i  /lamp/server/apache/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' /lamp/server/apache/conf/httpd.conf
clear
echo "
+------------------------------------------------+
|                Congratulations!!!              |
|                                                |
|             LAMP install completed             |
|                                                |
|                   auth:Json                    |
+------------------------------------------------+
"
service httpd start
sleep 3