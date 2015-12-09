#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}

Update

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "-- Install tools and helpers --"
sudo apt-get install -y vim python-software-properties htop curl git npm
Update

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php-7.0
sudo add-apt-repository ppa:chris-lea/node.js
sudo add-apt-repository ppa:rwky/redis
Update

echo "-- Install packages --"
sudo apt-get install -y php7.0-common php7.0-json php7.0-opcache php7.0-cli libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd
sudo apt-get install -y apache2 mysql-server-5.6 git-core nodejs rabbitmq-server redis-server
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo a2enmod rewrite

echo "-- Creating virtual hosts --"
sudo mkdir -p /var/www/{myapp,phpmyadmin}
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<VirtualHost *:80>
    DocumentRoot /var/www/myapp
    ServerName app1.dev
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/phpmyadmin
    ServerName phpmyadmin.dev
</VirtualHost>
EOF
sudo ln -fs /vagrant/ /var/www/myapp
sudo a2ensite default.conf

echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo "-- Install phpMyAdmin --"
wget -k https://files.phpmyadmin.net/phpMyAdmin/4.0.10.11/phpMyAdmin-4.0.10.11-english.tar.gz
sudo tar -xzvf phpMyAdmin-4.0.10.11-english.tar.gz -C /var/www/
sudo rm phpMyAdmin-4.0.10.11-english.tar.gz
sudo mv /var/www/phpMyAdmin-4.0.10.11-english/ /var/www/phpmyadmin

echo "-- Setup databases --"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -proot -e "CREATE DATABASE my_database";
