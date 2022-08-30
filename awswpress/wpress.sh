#!/bin/bash -ex

apt update

amazon-linux-extras install -y lamp-mariadb10.2-php8.1 php8.1
apt -y install apache2 mariadb-server
apt -y install php-common php8.1-common php8.1-cli php8.1-fpm php8.1-mysql libapache2-mod-php8.1 libsodium23 php8.1-opcache php8.1-readline

wget https://wordpress.org/latest.tar.gz
tar xvf latest.tar.gz
cp -R wordpress/* /var/www/html/

mv /var/www/html/index.html /var/www/html/index.html.old
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

usermod -a -G apache ubuntu
chown -R www-data:www-data /var/www/html/
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

apache2ctl restart

# SET PASSWORD AFRESH BEFORE USING
mysql -u root -e "CREATE DATABASE wordpress; \
	CREATE USER 'wpress'@'localhost' IDENTIFIED BY 'WpDb!1'; \
	GRANT ALL PRIVILEGES ON wordpress.* TO 'wpress'@'localhost'; \
	FLUSH PRIVILEGES;"
