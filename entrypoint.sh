#!/bin/bash

DB_USERNAME=${DB_USERNAME-pathfinder}
DB_PASSWORD=${DB_PASSWORD-secret}
SITE_NAME=${SITE_NAME-pathfinder}
SITE_ROOT=/var/www/html

start_mysql.sh

MYSQL_ROOT_PASS=$(echo -e `date` | md5sum | awk '{ print $1 }');

echo $(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Re-enter new password:\"
send \"$MYSQL_ROOT_PASS\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

apt-get remove -y expect
apt-get autoremove -y

mysql -uroot -p$MYSQL_ROOT_PASS -e "create database pathfinder;"

mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL ON vanguard.* to '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL ON pathfinder.* to '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "ALTER DATABASE vanguard CHARACTER SET utf8 COLLATE utf8_general_ci;"

start_mysql.sh

mv $SITE_ROOT/.htaccess_HTTP $SITE_ROOT/.htaccess

sed -i -e "s/\/www\/htdocs\/w0128162\/www\.pathfinder-dev\.exodus4d\.de\/logs/\/var\/log\/apache2/" $SITE_ROOT/.htaccess
sed -i -e '/Rewrite.*www.*/d' $SITE_ROOT/.htaccess

sed -i -e "s/DB_USER *=.*/DB_USER = $DB_USERNAME/g" $SITE_ROOT/app/environment.ini
sed -i -e "s/DB_PASS *=.*/DB_PASS = $DB_PASSWORD/g" $SITE_ROOT/app/environment.ini
sed -i -e "s/DB_NAME *=.*/DB_NAME = pathfinder/g" $SITE_ROOT/app/environment.ini

sed -i -e "s/DB_CCP_USER *=.*/DB_CCP_USER = $DB_USERNAME/g" $SITE_ROOT/app/environment.ini
sed -i -e "s/DB_CCP_PASS *=.*/DB_CCP_PASS = $DB_PASSWORD/g" $SITE_ROOT/app/environment.ini
sed -i -e "s/DB_CCP_NAME *=.*/DB_CCP_NAME = vanguard/g" $SITE_ROOT/app/environment.ini

sed -i -e "s/URL *=.*/URL = http:\/\/$SITE_NAME/g" $SITE_ROOT/app/environment.ini

echo "ServerName $SERVER_NAME" >> /etc/apache2/apache2.conf
unlink /etc/apache2/sites-enabled/000-default.conf
sed -i -e "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
sed -i -e "s/ServerTokens OS/ServerTokens Prod/" /etc/apache2/conf-enabled/security.conf
sed -i -e "s/ServerSignature On/ServerSignature Off/" /etc/apache2/conf-enabled/security.conf

cat <<EOF >> /etc/apache2/sites-available/100-$SERVER_NAME.conf
<VirtualHost *:80>
    ServerAdmin $ADMIN_EMAIL
    DocumentRoot "/var/www/html"
    ServerName $SERVER_NAME
    ServerAlias www.$SERVER_NAME
    ErrorLog /var/log/apache2/$SERVER_NAME-error.log
    CustomLog /var/log/apache2/$SERVER_NAME-access.log combined
    <Directory "/var/www/html">
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
EOF

ln -s /etc/apache2/sites-available/100-$SERVER_NAME.conf /etc/apache2/sites-enabled/

a2enmod rewrite headers
service apache2 restart
apachectl -t -D DUMP_VHOSTS
php --version

while [[ 1 ]]; do
    tail -f /var/log/apache2/*
    sleep 1
done
