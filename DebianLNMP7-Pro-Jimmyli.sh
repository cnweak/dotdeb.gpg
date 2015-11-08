#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cur_dir=$(pwd)
source_dir=$cur_dir/debian-lnmp
echo "$source_dir"
echo -e "\033[47;30m Compiled by Jimmy Li http://jimmyli.blog.51cto.com \033[0m"
servername="www.jimmyli.com"
echo -e "\033[41;37m Please enter the server domain name, the default is: $servername  < \033[0m"
echo -e "\033[41;37m Example: www.jimmyli.com \033[0m"
read -p " --Enter: " hostname
if [ "$hostname" = "" ]; then
	hostname="$servername"
fi

echo ""
echo -e "\033[41;37m Server domain name: $hostname \033[0m"
echo ""

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo ""
echo -e "\033[47;30m * Press any key to start installing DebianLNMP-Jimmyli ... \033[0m"
echo -e "\033[47;30m * Or press Ctrl + C to cancel the installation and exit \033[0m"
char=`get_char`
echo ""

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi
apt-get install -y gcc g++ make wget
wget -c http://sourceforge.net/projects/debian-lnmp/files/DebianLNMP/conf.tar.gz
if [ -s conf.tar.gz ]; then
  echo "conf.tar.gz [found]"
  else
  echo "Error: conf.tar.gz not found!!!download now......"
  wget -c http://sourceforge.net/projects/debian-lnmp/files/DebianLNMP/conf.tar.gz
  exit 1
fi
tar zxvf conf.tar.gz

if [ -s /etc/selinux/config ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

dpkg -l |grep mysql | awk -F " " '{print $2}' | xargs dpkg -P
dpkg -P libmysqlclient15off libmysqlclient15-dev mysql-common 
dpkg -l |grep apache | awk -F " " '{print $2}' | xargs dpkg -P
dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
dpkg -l |grep php5 | awk -F " " '{print $2}' | xargs dpkg -P

apt-get clean
apt-get autoclean
rm /var/lib/apt/lists/* -vf
apt-get check
apt-get upgrade
apt-get update
apt-get autoremove -y
apt-get -fy install
dpkg -P mysql-server mysql-client
dpkg -P nginx php5-fpm php5-gd php5-mysql
apt-get remove -y apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common
apt-get update
apt-get -y install unzip
wget -N -t 0 http://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg

if [ -s /etc/apt/sources.list.jimmylibak ]; then
rm /etc/apt/sources.list -f
mv /etc/apt/sources.list.jimmylibak /etc/apt/sources.list
fi
mv /etc/apt/sources.list /etc/apt/sources.list.jimmylibak
cat >> /etc/apt/sources.list<<EOF
deb http://mirrors.163.com/debian/ wheezy main
deb-src http://mirrors.163.com/debian/ wheezy main
deb http://security.debian.org/ wheezy/updates main
deb-src http://security.debian.org/ wheezy/updates main
deb http://packages.dotdeb.org stable all
deb-src http://packages.dotdeb.org stable all
deb http://mirrors.163.com/debian/ wheezy-updates main
deb-src http://mirrors.163.com/debian/ wheezy-updates main
EOF
apt-get update
apt-get autoremove -y
apt-get -fy install

apt-get install -y mysql-server mysql-client
apt-get install -y nginx php5-fpm php5-gd php5-mysql 
apt-get install -y php5-curl php5-imagick php5-memcache php5-memcached php5-xcache php5-mcrypt php5-odbc
sed -i "s#;cgi.fix_pathinfo=1#cgi.fix_pathinfo=0#g" /etc/php5/fpm/php.ini
sed -i "s#disable_functions =#disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,#g" /etc/php5/fpm/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php5/fpm/php.ini
sed -i "s#;open_basedir =#open_basedir = /tmp/:/home/www/:/proc/#g" /etc/php5/fpm/php.ini
rm -rf /etc/php5/fpm/pool.d/www.conf
mv www.conf /etc/php5/fpm/pool.d/www.conf

rm -rf /home/wwwlogs
rm -rf /home/wwwroot
rm -rf /home/www
mkdir /home/wwwlogs
mkdir /home/wwwroot
mkdir /home/www
mkdir /var/run/php5
mkdir /etc/nginx
mkdir /etc/nginx/host
rm -rf /etc/nginx/sites-enabled/*
rm -rf /etc/nginx/nginx.conf
rm -rf /etc/nginx/fastcgi_params
mv nginx.conf /etc/nginx/nginx.conf
mv fastcgi_params /etc/nginx/fastcgi_params
rm /etc/apt/sources.list -f && mv /etc/apt/sources.list.jimmylibak /etc/apt/sources.list
sed -i "s,lnmp.jimmyli.com,$hostname,g" /etc/nginx/nginx.conf

mv discuz.conf /etc/nginx
mv discuzx.conf /etc/nginx
mv sablog.conf /etc/nginx
mv wordpress.conf /etc/nginx
mv wp2.conf /etc/nginx
mv none.conf /etc/nginx
mv phpwind.conf /etc/nginx
mv supesite.conf /etc/nginx
mv typecho.conf /etc/nginx
mv uchome.conf /etc/nginx
mv dabr.conf /etc/nginx

mv index.html /home/www/index.html
mv nginx_small.png /home/www/nginx_small.png
mv prober.php /home/www/php.php
wget -c http://nchc.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/3.4.10.1/phpMyAdmin-3.4.10.1-all-languages.zip
unzip phpMyAdmin-3.4.10.1-all-languages.zip
mv phpMyAdmin-3.4.10.1-all-languages /home/www/phpMyAdmin
rm -rf phpMyAdmin-3.4.10.1-all-languages.zip
chown -R www-data /home/www
chown -R www-data /home/wwwroot

/etc/init.d/nginx start
/etc/init.d/php5-fpm start
/etc/init.d/php5-fpm restart

## info ##
echo ""
echo -e "\033[41;37m ******************************************************** \033[0m"
echo -e "\033[41;37m *      LNMP Installer for Debian                       * \033[0m"
echo -e "\033[41;37m *                                                      * \033[0m"
echo -e "\033[41;37m *  apt-get install Nginx+PHP+MySql                     * \033[0m"
echo -e "\033[41;37m *                                                      * \033[0m"
echo -e "\033[41;37m *  Compiled by Jimmy Li http://jimmyli.blog.51cto.com  * \033[0m"
echo -e "\033[41;37m *                                                      * \033[0m"
echo -e "\033[41;37m *  Website: http://sourceforge.net/p/debian-lnmp       * \033[0m"
echo -e "\033[41;37m *                                                      * \033[0m"
echo -e "\033[41;37m ******************************************************** \033[0m"
## END ##
