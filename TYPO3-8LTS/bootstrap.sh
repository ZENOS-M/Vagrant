# VAGRANT CMS Bootstrap
# Version: 0.0.5
#  Author: Akira Henke
# Website: http://akira-henke.de/
#    Repo: https://github.com/ZENOS-M/Vagrant

/usr/bin/env bash

#
# Web-Server Installation
#

# Vriables
PASSWORD='12345678'
PROJECTFOLDER='testproject'
NEWESTVERSION='8.7.2'

# create project folder
sudo mkdir "/var/www/html/${PROJECTFOLDER}"

# update and upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y apache2
sudo apt-get install -y php5

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

# install phpmyadmin
# same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

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


#
# TYPO3 Installation
#

# install imagemagick
sudo apt-get update
sudo apt-get -y install imagemagick
sudo apt-get -y install php5-imagick

# Create Database
mysql -u root -p12345678 -e "CREATE DATABASE typo3_${PROJECTFOLDER} CHARACTER SET utf8 COLLATE utf8_general_ci"

# Get TYPO3 Files
cd /var/www/html/
wget get.typo3.org/8.7
tar -xzvf 8.7
mv -v /var/www/html/typo3_src-${NEWESTVERSION}/* /var/www/html/${PROJECTFOLDER}
sudo rm -r -f /var/www/html/typo3_src-${NEWESTVERSION}/
sudo rm -r -f /var/www/html/8.7
cd /var/www/html/${PROJECTFOLDER}
sudo touch FIRST_INSTALL
sudo mkdir "/var/www/html/${PROJECTFOLDER}/typo3_src"

# PHP Configuration
sudo replace "max_execution_time = 30" "max_execution_time = 240" -- /etc/php5/apache2/php.ini
sudo replace "; max_input_vars = 1000" "max_input_vars = 1500" -- /etc/php5/apache2/php.ini

# Sendmail Hots configuration
sudo replace "127.0.0.1 localhost" "127.0.0.1 vagrant-ubuntu-trusty-64.localdomain vagrant-ubuntu-trusty-64 localdev localhost" -- /etc/hosts

sudo service apache2 restart

#
# PHP7 Installation
#

sudo add-apt-repository ppa:ondrej/php
echo -e "\n"

sudo apt-get update

sudo apt-get -y install php7.0

sudo apt-get -y install php7.0-mysql

sudo a2dismod php5
sudo a2enmod php7.0

# PHP Configuration
sudo replace "max_execution_time = 30" "max_execution_time = 240" -- /etc/php/7.0/apache2/php.ini
sudo replace "; max_input_vars = 1000" "max_input_vars = 1500" -- /etc/php/7.0/apache2/php.ini

sudo apt-get -y install php7.0-gd
sudo apt-get -y install php7.0-soap
sudo apt-get -y install php7.0-xml
sudo apt-get -y install php7.0-zip

sudo service apache2 restart

# Change InstallToolPW in LocalConfiguration.php to: bacb98acf97e0b6112b1d1b650b84971
# Login in TYPO3 backend with: joh316