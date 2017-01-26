#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}
Update

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"

echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes python-software-properties vim htop curl git npm

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:chris-lea/redis-server
Update

echo "-- Install NodeJS --"
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -

echo "-- Install packages --"
sudo apt-get install -y --force-yes apache2 mysql-server-5.6 git-core nodejs rabbitmq-server redis-server
sudo apt-get install -y --force-yes php7.0-common php7.0-dev php7.0-json php7.0-opcache php7.0-xml php7.0-cli libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-mcrypt php7.0-mbstring php7.0-bcmath php7.0-zip php7.0-intl
Update

echo "-- Install java --"
sudo apt-get remove openjdk* -y
sudo apt-get autoremove -y
sudo apt-get install openjdk-8-jre-headless -y
Update


echo "--Install elastic--"
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.2.0.deb
sudo dpkg -i elasticsearch-2.2.0.deb
### NOT starting elasticsearch by default on bootup, please execute
sudo update-rc.d elasticsearch defaults 95 10
sudo /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head
sudo service elasticsearch stop

echo "--Install  and enabling xdebug--"
sudo apt-get -y --force-yes  install php-xdebug
cat << EOF | sudo tee -a /etc/php/7.0/apache2/conf.d/20-xdebug.ini    
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.max_nesting_level = 512
xdebug.show_error_trace = 1
EOF


echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo a2enmod rewrite

echo "-- Creating virtual hosts --"
sudo ln -fs /vagrant/public/app /var/www/app

#normal site apache
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<Directory "/var/www/">
    AllowOverride All
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/app
    ServerName app.dev
</VirtualHost>

EOF
sudo a2ensite default.conf

sudo ln -fs /vagrant/public/symfony /var/www/symfony
#symfony site
cat << EOF | sudo tee -a /etc/apache2/sites-available/symfony.conf
<VirtualHost *:80>
    ServerName symfony.dev
    ServerAlias www.symfony.dev

    DocumentRoot /var/www/symfony/web
    <Directory /var/www/symfony/web>
        AllowOverride None
        Order Allow,Deny
        Allow from All

        <IfModule mod_rewrite.c>
            Options -MultiViews
            RewriteEngine On
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule ^(.*)$ app.php [QSA,L]
        </IfModule>
    </Directory>

    # uncomment the following lines if you install assets as symlinks
    # or run into problems when compiling LESS/Sass/CoffeeScript assets
    # <Directory /var/www/project>
    #     Options FollowSymlinks
    # </Directory>

    # optionally disable the RewriteEngine for the asset directories
    # which will allow apache to simply reply with a 404 when files are
    # not found instead of passing the request into the full symfony stack
    <Directory /var/www/symfony/web/bundles>
        <IfModule mod_rewrite.c>
            RewriteEngine Off
        </IfModule>
    </Directory>
    ErrorLog /var/log/apache2/project_error.log
    CustomLog /var/log/apache2/project_access.log combined
</VirtualHost>
EOF
sudo a2ensite symfony.conf

#vi /etc/php/7.0/mods-available/xdebug.ini
#xdebug.show_error_trace = 1

echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo "-- Install symfony --"
sudo mkdir -p /usr/local/bin
sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
sudo chmod a+x /usr/local/bin/symfony


echo "-- Setup databases --"
mysql -uroot -psecret -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -psecret -e "CREATE DATABASE app";
mysql -uroot -psecret -e "CREATE DATABASE symfony";
