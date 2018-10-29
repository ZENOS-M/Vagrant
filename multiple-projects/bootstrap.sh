#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='12345678'
PHP='7.2' # 5, 7 or 7.2

# create project folder
sudo mkdir "/var/www/html/project1"
sudo mkdir "/var/www/html/project2"
sudo mkdir "/var/www/html/project3"
sudo mkdir "/var/www/html/project4"
sudo mkdir "/var/www/html/project5"
sudo mkdir "/var/www/html/project6"
sudo mkdir "/var/www/html/project7"

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
<VirtualHost 192.168.33.21:80>
    DocumentRoot "/var/www/html/project1"
    <Directory "/var/www/html/project1">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost 192.168.33.22:80>
    DocumentRoot "/var/www/html/project2"
    <Directory "/var/www/html/project2">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost 192.168.33.23:80>
    DocumentRoot "/var/www/html/project3"
    <Directory "/var/www/html/project3">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost 192.168.33.24:80>
    DocumentRoot "/var/www/html/project4"
    <Directory "/var/www/html/project4">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost 192.168.33.25:80>
    DocumentRoot "/var/www/html/project5"
    <Directory "/var/www/html/project5">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost 192.168.33.26:80>
    DocumentRoot "/var/www/html/project6"
    <Directory "/var/www/html/project6">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost 192.168.33.27:80>
    DocumentRoot "/var/www/html/project7"
    <Directory "/var/www/html/project7">
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

# install gd for image generation
install php-gd

# install imagemagick
sudo apt-get update
sudo apt-get -y install imagemagick
sudo apt-get -y install php5-imagick

sudo replace "max_execution_time = 30" "max_execution_time = 240" -- /etc/php5/apache2/php.ini
sudo replace "; max_input_vars = 1000" "max_input_vars = 1500" -- /etc/php5/apache2/php.ini
sudo replace "post_max_size = 8M" "post_max_size = 128M" -- /etc/php5/apache2/php.ini
sudo replace "memory_limit = 128M" "memory_limit = 256M" -- /etc/php5/apache2/php.ini
sudo replace "upload_max_filesize = 2M" "upload_max_filesize = 64M" -- /etc/php5/apache2/php.ini
sudo replace "display_errors = Off" "display_errors = On" -- /etc/php5/apache2/php.ini


# Sendmail Hots configuration
sudo replace "127.0.0.1 localhost" "127.0.0.1 vagrant-ubuntu-trusty-64.localdomain vagrant-ubuntu-trusty-64 localdev localhost" -- /etc/hosts

mysql -u root -p12345678 -e "CREATE DATABASE project1 CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -u root -p12345678 -e "CREATE DATABASE project2 CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -u root -p12345678 -e "CREATE DATABASE project3 CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -u root -p12345678 -e "CREATE DATABASE project4 CHARACTER SET utf8 COLLATE utf8_general_ci"
mysql -u root -p12345678 -e "CREATE DATABASE project5 CHARACTER SET utf8 COLLATE utf8_general_ci"


if [ "$PHP" == "7" ]; then

	sudo add-apt-repository ppa:ondrej/php
	echo -e "\n"

	sudo apt-get update

	sudo apt-get -y install php7.0

	sudo apt-get -y install php7.0-mysql
    
	sudo apt-get -y install php7.0-mbstring
	sudo apt-get -y install php7.0-dom
    sudo apt-get -y install php7.0-mcrypt
    
    // TYPO3
    sudo apt-get -y install php7.0-gd
    sudo apt-get -y install php7.0-soap
    sudo apt-get -y install php7.0-xml
    sudo apt-get -y install php7.0-zip
    sudo apt-get -y install php7.0-intl

    sudo apt-get -y install libpcre3
    sudo apt-get -y install libpcre3-dev

	sudo a2dismod php5
	sudo a2enmod php7.0
	
	# PHP Configuration
	sudo replace "max_execution_time = 30" "max_execution_time = 360" -- /etc/php/7.0/apache2/php.ini
	sudo replace "; max_input_vars = 1000" "max_input_vars = 2000" -- /etc/php/7.0/apache2/php.ini
    sudo replace "post_max_size = 8M" "post_max_size = 1024M" -- /etc/php/7.0/apache2/php.ini
    sudo replace "memory_limit = 128M" "memory_limit = 1024M" -- /etc/php/7.0/apache2/php.ini
    sudo replace "upload_max_filesize = 2M" "upload_max_filesize = 256M" -- /etc/php/7.0/apache2/php.ini
    sudo replace "display_errors = Off" "display_errors = On" -- /etc/php/7.0/apache2/php.ini
	
	sudo service apache2 restart
	
else
    sudo service apache2 restart
fi


if [ "$PHP" == "7.2" ]; then

	sudo add-apt-repository ppa:ondrej/php
	echo -e "\n"

	sudo apt-get update

	sudo apt-get -y install php7.2

	sudo apt-get -y install php7.2-mysql
    
	sudo apt-get -y install php7.2-mbstring
	sudo apt-get -y install php7.2-dom
    
    // TYPO3
    sudo apt-get -y install php7.2-gd
    sudo apt-get -y install php7.2-soap
    sudo apt-get -y install php7.2-xml
    sudo apt-get -y install php7.2-zip
    sudo apt-get -y install php7.2-intl

    sudo apt-get -y install libpcre3
    sudo apt-get -y install libpcre3-dev

	sudo a2dismod php5
	sudo a2enmod php7.2
	
	# PHP Configuration
	sudo replace "max_execution_time = 30" "max_execution_time = 360" -- /etc/php/7.2/apache2/php.ini
	sudo replace "; max_input_vars = 1000" "max_input_vars = 2000" -- /etc/php/7.2/apache2/php.ini
    sudo replace "post_max_size = 8M" "post_max_size = 1024M" -- /etc/php/7.2/apache2/php.ini
    sudo replace "memory_limit = 128M" "memory_limit = 1024M" -- /etc/php/7.2/apache2/php.ini
    sudo replace "upload_max_filesize = 2M" "upload_max_filesize = 256M" -- /etc/php/7.2/apache2/php.ini
    sudo replace "display_errors = Off" "display_errors = On" -- /etc/php/7.2/apache2/php.ini
    
    # sudo apt-get -y install php7.0-dev
    # sudo apt-get -y install php-pear
    # sudo apt-get -y install libmcrypt-dev libreadline-dev
    # sudo pecl install mcrypt-1.0.1
    # echo 'extension=mcrypt.so' | sudo tee --append /etc/php/7.2/apache2/php.ini
	
	sudo service apache2 restart
	
else
    sudo service apache2 restart
fi