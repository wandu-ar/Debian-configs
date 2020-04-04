#!/bin/bash

# ############################################################################################# #
# /*-------------------- https://wandu.com.ar | soporte[at]wandu.com.ar ---------------------*/ #
# ############################################################################################# #
# #        /\      /\                                                                         # #
# #       / /\    / /\                                                                        # #
# #      / /%%\  / /##\                                                                       # #
# #     / /%%%%\/ /####\                                                __            (R)     # #
# #    / /%%/\%%//##/\##\                                              |  \                   # #
# #   | |\%/ \\//##/\ \##|      __   __   __   ______   _______    ____| ## __    __          # #
# #   | |#\  / /##/  \ \#|     |  \ |  \ |  \ |      \ |       \  /      ##|  \  |  \         # #
# #    \|##\/ /##//\  /@\|     | ## | ## | ##  \######\| #######\|  #######| ##  | ##         # #
# #     \\##\/##//@@\/@@/      | ## | ## | ## /      ##| ##  | ##| ##  | ##| ##  | ##         # #
# #      \\####/ \\@@@@/       | ##_/ ##_/ ##|  #######| ##  | ##| ##__| ##| ##__/ ##         # #
# #       \\##/   \\@@/         \##   ##   ## \##    ##| ##  | ## \##    ## \##    ##         # #
# #        \\/     \\/           \#####\####   \####### \##   \##  \#######  \######          # #
# #                                                                                           # #
# ############################################################################################# #
# /*--------------------------- MADE IN BUENOS AIRES - ARGENTINA ----------------------------*/ #
# ############################################################################################# #
#
# Welcome to my script!
#
# Author: Alejandro D. Guevara
# Version: 1.0.0
# Release date: 04/04/2020
# Languaje: Spanglish
# Script: basic_install_debian10.sh
# 
# "Dedicado a quienes se dedican a expandir el mundo del software libre..."
#          

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGFILE="/var/log/configure_debian10.log"

echo " 
---------------------------------------
--              Wandu ®              --
---------------------------------------
--    `date  +%a' '%F' '%H:%M:%S` hs.    --
---------------------------------------
---------------------------------------
"


if grep "^10\." /etc/debian_version > /dev/null; then
	echo "(INFO) Debian 10 Detectado."
else
    echo "(ERROR) No se encontro una instalacion de debian 10 válida."
    exit 0
fi

cd /root

HOSTNAME=$(</etc/hostname)

## INI - Instalacion de utilidades
    echo "• Instalacion de utilidades."

    echo "> Instalando rsync ..."
    apt install rsync -y

    echo "> Instalando unzip ..."
    apt install unzip -y

    echo "> Instalando locate ..."
    apt -y install locate

    echo "> Instalando CURL ..."
    apt -y install curl

## FIN - Instalacion de utilidades

## INI - Instalacion de WEBMIN
    echo "• Instalacion de webmin."
    
    echo "> Agregando repositorio..."
    apt -y install gnupg1
    wget -q http://www.webmin.com/jcameron-key.asc -O- | apt-key add -
    echo "deb https://download.webmin.com/download/repository sarge contrib" | tee /etc/apt/sources.list.d/webmin.list

    echo "> Instalando dependencias..."
    apt -y install apt-transport-https

    echo "> Actualizando paquetes..."
    apt update

    echo "> Instalando webmin..."
    apt -y install webmin
## FIN - Instalacion de WEBMIN

## INI - Instalacion de UFW
    echo "• Instalacion de UFW (Firewall)."
    
    echo "> Instalando UFW..."
    apt -y install ufw

    echo "> Por favor, escriba el puerto SSH."
    echo "> ATENCIÓN: Un error en el puerto podría dejarte sin acceso por SSH."
    read SSH_PORT

    echo "> Habilitando puertos..."
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow ${SSH_PORT}/tcp
    #ufw allow 10000/tcp

    echo "> Creando perfil de aplicaciones ..."
    cat > /etc/ufw/applications.d/appsrv << EOF
[appsrv-ssh]
title=Secure shell server, an rshd replacement
description=OpenSSH is a free implementation of the Secure Shell protocol.
ports=22,2022,2222,$SSH_PORT/tcp

[appsrv-web]
title=Web Server 
description=Web server services (HTTP,HTTPS)
ports=80,443,8080/tcp

[appsrv-sql]
title=MariaDB
description=MariaDB database service
ports=3306/tcp

[appsrv-webmin]
title=Webmin
description=Webmin service
ports=10000/tcp
EOF
    ufw --force enable
    service ufw force-reload
## FIN - Instalacion de UFW

## INI - Instalacion de LAMP
    echo "• Instalacion de LAMP."
    
    #REF: https://www.howtoforge.com/tutorial/install-apache-with-php-and-mysql-lamp-on-debian-stretch/
    #REF: https://tecadmin.net/install-multiple-php-version-with-apache-on-debian/
    #REF: https://certbot.eff.org/lets-encrypt/debianstretch-apache.html
    
    echo "> Instalando MariaDB..."
    apt -y install mariadb-server

    echo "> Ingrese la clave para root en servidor de base datos"
    read SQL_ROOT_PASSWORD

    mysql_secure_installation

    echo "> Instalando PHP-FPM..."
    echo "> Agregando repositorios..."
    apt -y install ca-certificates
    wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
    echo "deb https://packages.sury.org/php/ buster main" | tee /etc/apt/sources.list.d/php.list

    echo "> Actualizando paquetes..."
    apt update

    #echo "> Instalando PHP 5.6 ..."
    #apt install php5.6 php5.6-fpm php5.6-mysql php5.6-curl php5.6-gd php5.6-memcache php5.6-opcache php5.6-apcu php5.6-bz2 php5.6-zip php5.6-mbstring php5.6-xml -y

    echo "> Instalando dependencias para PHP ..."
    apt -y install libcurl4

    echo "> Instalando PHP 7.3 ..."
    apt -y install php7.3 php7.3-fpm php7.3-mysql php7.3-curl php7.3-gd php7.3-opcache php7.3-bz2 php7.3-zip php7.3-mbstring php7.3-xml php7.3-json php7.3-mysqlnd php7.3-intl php7.3-gmp php7.3-cli

    echo "> Instalando paquetes adicionales para PHP ..."
    apt -y install php-memcache php-apcu php-imagick php-phpseclib php-php-gettext

    echo "> Instalando Apache 2 y mod-fcgid para PHP-FPM ..."
    apt install apache2 libapache2-mod-fcgid -y

    echo "> Habilitando mods de Apache ..."
    a2enmod rewrite ssl include headers actions proxy_fcgi alias http2
    a2enconf php7.3-fpm

    echo "> Agregando puerto de escucha 800/tcp ..."
    echo "Listen 800" >> /etc/apache2/ports.conf

    echo "> Creando archivo /var/www/html/info.php de ejemplo ..."
    echo "<?php phpinfo(); ?>" > /var/www/html/info.php

    echo "> Habilitando HTTP/2 ..."
    echo "Protocols h2 h2c http/1.1" >> /etc/apache2/apache2.conf

    echo "> Securizando apache ..."
    sed -i 's/ServerSignature.*/ServerSignature Off/' /etc/apache2/conf-available/security.conf
    sed -i 's/ServerTokens.*/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
    
    # No usar... porque no me anda los frames
    # sed -i 's/#Header set X-Frame-Options.*/Header set X-Frame-Options: "sameorigin"/' /etc/apache2/conf-available/security.conf

    echo "> Reiniciando servicio Apache..."
    systemctl restart apache2

    echo "> Instalando phpMyAdmin ..."
    wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.zip
    unzip -q phpMyAdmin-5.0.2-all-languages.zip
    mv phpMyAdmin-5.0.2-all-languages /usr/share/phpmyadmin
    chown -R www-data:www-data /usr/share/phpmyadmin

    echo "> Ingresa un password para el usuario phpmyadmin ..."
    read PHPMYADMIN_PASSWORD

    echo "CREATE DATABASE phpmyadmin DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | mysql -u root -p$SQL_ROOT_PASSWORD
    
    echo "GRANT ALL ON phpmyadmin.* TO 'phpmyadmin'@'localhost' IDENTIFIED BY '${PHPMYADMIN_PASSWORD}';" | mysql -u root -p$SQL_ROOT_PASSWORD

    echo "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root' AND plugin = 'unix_socket';" | mysql -u root -p$SQL_ROOT_PASSWORD

    echo "FLUSH PRIVILEGES;" | mysql -u root -p$SQL_ROOT_PASSWORD

    mkdir -m 0755 /var/www/phpmyadmin/

    cat > /var/www/phpmyadmin/.user.ini << EOF
upload_max_filesize = 50M
post_max_size = 50M
display_errors = On
error_reporting = E_ALL
EOF

    echo '<?php header("Location: /phpmyadmin/");' > /var/www/phpmyadmin/index.php

    cat > /etc/apache2/sites-available/phpmyadmin.conf << EOF
<VirtualHost *:800>
    DocumentRoot "/var/www/phpmyadmin"
    <Directory "/var/www/phpmyadmin">
        Allow from all
        Options -Indexes +FollowSymLinks -MultiViews
        Require all granted
    </Directory>
    <FilesMatch ".+\.ph(p[3457]?|t|tml)$">
        SetHandler "proxy:unix:/run/php/php7.3-fpm.sock|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
EOF

    ln -s /usr/share/phpmyadmin /var/www/phpmyadmin/phpmyadmin

    a2ensite phpmyadmin.conf
    systemctl reload apache2

    echo "> Instalando mysqltuner ..."
    wget http://mysqltuner.pl/ -O mysqltuner.pl --no-check-certificate
    
    echo "perl mysqltuner.pl --user root --pass $SQL_ROOT_PASSWORD" > /root/mysqltuner.sh
    chmod +x /root/mysqltuner.sh

    echo "> Instalando LetsEncrypt ..."
    apt -y install certbot python-certbot-apache

## FIN - Instalacion de LAMP

## INI - Instalacion de fail2ban
    echo "• Instalacion de fail2ban."

    echo "> Instalando fail2ban ..."
    apt -y install fail2ban 

    cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = false

[ssh-with-ufw]
enabled = true
port = $SSH_PORT
filter = sshd
action = ufw[application="appsrv-ssh", blocktype=reject]
logpath = /var/log/auth.log
maxretry = 3
ignoreip = 127.0.0.1/8
findtime = 600
bantime = 3600

EOF

    service fail2ban reload
## FIN - Instalacion de fail2ban

## INI - Instalacion de GIT
    echo "• Instalacion de GIT."
    apt -y install git 
## FIN - Instalacion de GIT

## INI - Instalacion de sudo
    echo "• Instalacion de sudo."
    apt -y install sudo 

    usermod --shell /bin/bash www-data
## FIN - Instalacion de sudo

## INI - Instalacion de sudo

## INI - Instalacion de Composer
    echo "• Instalacion de composer."

    echo "> Instalando composer ..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
## FIN - Instalacion de Composer

## INI - Configuraciones
    echo "• Configuracion del sistema."

    echo "> Modificando shell de www-data y sus permisos sobre /var/www ..."
    usermod --shell /bin/bash www-data
    chown -R www-data:www-data /var/www
    find /var/www -type d -exec chmod 0755 {} \;
    find /var/www -type f -exec chmod 644 {} \;

    echo "> Configurando acceso SSH mediante pair key ..."
    ssh-keygen -t rsa
    cp ~/.ssh/id_rsa.pub  ~/.ssh/authorized_keys

    echo "> Copia la clave privada ...
    
    "
    cat ~/.ssh/id_rsa

    echo "
    
    "

## END - Configuraciones

echo "Instalación finalizada ;)"
