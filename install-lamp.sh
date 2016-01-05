#/bin/bash
# RHEL 7

set -x 

# Root check

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Installing epel-release

yum -y install epel-release

rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# Installing httpd

which httpd >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum -y install httpd >/dev/null 2>&1
fi

# Start httpd 
 
systemctl start httpd.service
 
# checking web status

curl -i localhost

# Enabling httpd on startup
 
systemctl enable httpd.service

# Installing mariadb

which mariadb-server >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum -y install mariadb-server >/dev/null 2>&1
fi

which mariadb >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum -y install mariadb >/dev/null 2>&1
fi
 
systemctl start mariadb

echo " Please setup database "

mysql_secure_installation
 
systemctl enable mariadb.service

# Installing Php
 
yum install php php-mysql php-gd php-pear 

echo "<?php
   phpinfo(INFO_GENERAL);
?> " | tee /var/www/html/test.php
 
systemctl restart httpd.service

# Adding firewall rules
 
firewall-cmd --permanent --zone=public --add-service=http 

firewall-cmd --permanent --zone=public --add-service=https

firewall-cmd --reload

echo " php verions "
php -v

echo " httpd version"

httpd -v

curl -i localhost
