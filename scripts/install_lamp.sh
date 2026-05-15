#!/bin/bash
set -ex

sudo apt update

#Instalar apache
sudo apt install apache2 -y

#Copiamos archivo de configuracion de apache
cp ../conf/000-default.conf /etc/apache2/sites-available/

#Instalar My SQL
sudo apt install mysql-server -y

#Instalar PHP
sudo apt install php libapache2-mod-php php-mysql -y

#Reiniciar servicio de Apache
sudo systemctl restart apache2

# Copiamos el archivo index.php en /var/www/html
cp ../php/index.php /var/www/html

