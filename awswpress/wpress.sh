#!/bin/bash -ex

sudo apt update

# sudo amazon-linux-extras install -y lamp-mariadb10.2-php8.1 php8.1
sudo apt -y install apache2 mariadb-server
sudo apt -y install php-common php8.1-common php8.1-cli php8.1-fpm php8.1-mysql libapache2-mod-php8.1 libsodium23 php8.1-opcache php8.1-readline

wget https://wordpress.org/latest.tar.gz
tar xvf latest.tar.gz
sudo cp -R wordpress/* /var/www/html/

sudo mv /var/www/html/index.html /var/www/html/index.html.old
sudo echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

sudo usermod -a -G apache ubuntu
sudo chown -R www-data:www-data /var/www/html/
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

sudo pache2ctl restart

# SET PASSWORD AFRESH BEFORE USING
sudo mysql -u root -e "CREATE DATABASE wordpress; \
	CREATE USER 'wpress'@'localhost' IDENTIFIED BY 'WpDb!1'; \
	GRANT ALL PRIVILEGES ON wordpress.* TO 'wpress'@'localhost'; \
	FLUSH PRIVILEGES;"
