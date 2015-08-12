#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}

Update

echo "-- Prepare configuration for MySQL and phpMyAdmin --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"

echo "-- Install tools and helpers --"
sudo apt-get install -y vim curl git python-software-properties
Update

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php5-5.6
sudo add-apt-repository ppa:ondrej/mysql-5.6
sudo add-apt-repository ppa:chris-lea/node.js
Update

echo "-- Install packages --"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-xsl mysql-server php5-mysql git-core php5-xdebug phpmyadmin nodejs npm
Update

echo "-- Configure Xdebug --"
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "-- Configure Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
sudo a2enmod rewrite

echo "-- Restart apache --"
sudo /etc/init.d/apache2 restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo "-- Install phpDocumentor --"
wget http://www.phpdoc.org/phpDocumentor.phar
sudo mv phpDocumentor.phar /usr/local/bin/phpdoc
sudo chmod +x /usr/local/bin/phpdoc

echo "-- Install PHPUnit --"
wget -k https://phar.phpunit.de/phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit
sudo chmod +x /usr/local/bin/phpunit

echo "-- Setup database --"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -proot -e "CREATE DATABASE my_database";
