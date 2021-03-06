#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='12345678'
PROJECTFOLDER='testproject'
EMAIL='admin@192.168.33.22.de'
BACKENDUSER='admin'
PHP='7' # 5 or 7

# create project folder
sudo mkdir "/var/www/html/${PROJECTFOLDER}"

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y apache2
sudo apt-get install -y php5

sudo apt-get -y install php5-mbstring
sudo apt-get -y install php5-dom
sudo apt-get -y install php5-mcrypt

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

# sudo vim /etc/hosts
#
# 127.0.0.1 localhost localhost.localdomain your_domain_name_here.com
#

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECTFOLDER}"
    <Directory "/var/www/html/${PROJECTFOLDER}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# install sendmail
sudo apt-get -y install sendmail

sudo replace "max_execution_time = 30" "max_execution_time = 240" -- /etc/php5/apache2/php.ini
sudo replace "; max_input_vars = 1000" "max_input_vars = 1500" -- /etc/php5/apache2/php.ini
sudo replace "post_max_size = 8M" "post_max_size = 128M" -- /etc/php5/apache2/php.ini
sudo replace "memory_limit = 128M" "memory_limit = 256M" -- /etc/php5/apache2/php.ini
sudo replace "upload_max_filesize = 2M" "upload_max_filesize = 64M" -- /etc/php5/apache2/php.ini
sudo replace "display_errors = Off" "display_errors = On" -- /etc/php5/apache2/php.ini



# Create Database
mysql -u root -p12345678 -e "CREATE DATABASE wp_${PROJECTFOLDER} CHARACTER SET utf8 COLLATE utf8_general_ci"

cd /var/www/html/
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html/${PROJECTFOLDER}

sudo wp core download --path=/var/www/html/${PROJECTFOLDER} --locale=de_DE --allow-root
sudo wp core config --dbhost=127.0.0.1 --dbname=wp_${PROJECTFOLDER} --dbuser=root --dbpass=${PASSWORD} --allow-root
sudo chmod 644 wp-config.php
sudo wp core install --url=192.168.33.22 --title="${PROJECTFOLDER}" --admin_name=$BACKENDUSER --admin_password=$PASSWORD --admin_email=$EMAIL --allow-root

# Sendmail Hots configuration
sudo replace "127.0.0.1 localhost" "127.0.0.1 vagrant-ubuntu-trusty-64.localdomain vagrant-ubuntu-trusty-64 localdev localhost" -- /etc/hosts



if [ "$PHP" == "7" ]; then

	sudo add-apt-repository ppa:ondrej/php
	echo -e "\n"

	sudo apt-get update

	sudo apt-get -y install php7.0

	sudo apt-get -y install php7.0-mysql
    
	sudo apt-get -y install php7.0-mbstring
	sudo apt-get -y install php7.0-dom
    sudo apt-get -y install php7.0-mcrypt

	sudo a2dismod php5
	sudo a2enmod php7.0
	
	# PHP Configuration
	sudo replace "max_execution_time = 30" "max_execution_time = 240" -- /etc/php/7.0/apache2/php.ini
	sudo replace "; max_input_vars = 1000" "max_input_vars = 1500" -- /etc/php/7.0/apache2/php.ini
    sudo replace "post_max_size = 8M" "post_max_size = 128M" -- /etc/php/7.0/apache2/php.ini
    sudo replace "memory_limit = 128M" "memory_limit = 256M" -- /etc/php/7.0/apache2/php.ini
    sudo replace "upload_max_filesize = 2M" "upload_max_filesize = 64M" -- /etc/php/7.0/apache2/php.ini
    sudo replace "display_errors = Off" "display_errors = On" -- /etc/php/7.0/apache2/php.ini
	
	sudo service apache2 restart
	
else

	sudo service apache2 restart
	
fi