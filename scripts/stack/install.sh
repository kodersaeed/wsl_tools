#!/bin/bash

source $parent_path/utilities.sh

UBUNTU_VERSION=$(lsb_release -rs)

menu(){
echo -ne "

$(pGreen 'OK, This will install the following stuff:')

$(pGreen '*)') PHP with Essential Extensions (from 8.2 to 5.6)

$(pGreen '*)') Composer (PHP Package Manager)

$(pGreen '*)') MariaDB 10.6 | MySQL 8.0 $(pBlue '(you will be asked)')

$(pGreen '*)') Nginx

$(pGreen '*)') NVM, Node, Npm, Yarn

$(pGreen '*)') Redis & MemCached

$(pBlue "Are you sure you want to continue? Type $(pGreen 'Y') to Continue or $(pRed 'N') to Abort"): "
        read a
        case $a in
	      y|Y) continue_install ;;
	      n|N) _bold "Aborted, Going to Main Menu"; exit 0 ;;
			*) _error "Wrong Choice !!, Y for Continue, N for Abort"; menu;;
        esac
}

function continue_install() {

if is_installed mysql-* || is_installed php* || is_installed nginx* || is_installed mariadb-* ; then
	echo -ne "
	$(pRed '======= WARNING ========')

	$(pRed 'SEEMS LIKE YOUR UBUNTU IS NOT A FRESH INSTALL, THIS SCRIPT MAY MESS THINGS UP !!!!')

	$(pTan "If You Continue, $(_underline "apt install") command will update the existing packages !!!!")

	$(pRed '======= WARNING ========')

	$(pBlue "Are you sure you want to continue? Type $(pRed 'Y') to Continue or $(pGreen 'N') to Abort, $(pTan 'C') to Check Statuses"): "	
        read a
        case $a in
	      y|Y) _info "CONTINUING ON YOUR RESPONSIBILITY !!!";;
	      n|N) _bold "Aborted, Going to Main Menu"; exit 0 ;;
	      c|C) _checking_all; exit 0 ;;
			*) _bold "Aborted, Going to Main Menu"; exit 0 ;;
        esac

fi


# Upgrade The Base Packages
_info "Upgrading the Base Packages"

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt_wait

apt-get upgrade -y

apt_wait

apt autoremove

# Adding A Few PPAs To Stay Current
_info "Adding A Few PPAs To Stay Current"

apt-get install -y --force-yes software-properties-common

apt-add-repository ppa:ondrej/nginx -y

apt-add-repository ppa:ondrej/apache2 -y

apt-add-repository ppa:ondrej/php -y

_info "Updating Package Lists"

apt_wait

apt-get update

_info "Now Installing Base Packages"

apt_wait

add-apt-repository universe

apt-get install -y --force-yes build-essential curl pkg-config fail2ban gcc g++ git libmcrypt4 libpcre3-dev \
make python3 python3-pip sendmail supervisor ufw zip unzip whois zsh ncdu awscli uuid-runtime acl libpng-dev libmagickwand-dev

_info "Now Installing Python Httpie"

pip3 install httpie


_info "Some Questions for You, Then sit back and Enjoy your drink!"

echo -ne "$(pBlue 'For Git, Enter your Name (For Commits)::  ')"
read git_name

echo -ne "$(pBlue 'For Git, Enter your Email (For Commits)::  ')"
read git_email

echo -ne "Enter any non-root user that should be allowed to reload PHP, Nginx etc, $(pBlue 'We will Skip this step if User not found or Blank, user:  ')"
read user_reloader




_info "Setting $git_name as username in Git"

git config --global user.name "$git_name"

_info "Setting $git_email as email in Git"

git config --global user.email "$git_email"


if id "$user_reloader" &>/dev/null; 
then
	_info "Found $user_reloader"



cat << FOE >> /home/$user_reloader/.bashrc

#Auto Starting services
sudo /etc/init.d/nginx start
sudo /etc/init.d/php8.2-fpm start
sudo /etc/init.d/php8.1-fpm start
sudo /etc/init.d/php8.0-fpm start
sudo /etc/init.d/php7.4-fpm start
sudo /etc/init.d/php7.3-fpm start
sudo /etc/init.d/php7.2-fpm start
sudo /etc/init.d/php7.1-fpm start
sudo /etc/init.d/php7.0-fpm start
sudo /etc/init.d/php5.6-fpm start
sudo /etc/init.d/mysql start
sudo /etc/init.d/redis-server start
sudo /etc/init.d/memcached start
FOE

	_info "Removing Password Requirements from Services"

	echo '%sudo   ALL=NOPASSWD: /etc/init.d/nginx' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php8.2-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php8.1-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php8.0-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php7.4-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php7.3-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php7.2-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php7.1-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php7.0-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/php5.6-fpm' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/mysql' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/redis-server' | sudo EDITOR='tee -a' visudo
	echo '%sudo   ALL=NOPASSWD: /etc/init.d/memcached' | sudo EDITOR='tee -a' visudo

	apt_wait

else
	_info "Blank or User $user_reloader Not Found, Moving On ..."
fi

_info "Installing PHP $(pGreen 8.2) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php8.2-cli php8.2-fpm php8.2-dev \
php8.2-pgsql php8.2-sqlite3 php8.2-gd \
php8.2-curl php8.2-memcached \
php8.2-imap php8.2-mysql php8.2-mbstring \
php8.2-xml php8.2-zip php8.2-bcmath php8.2-soap \
php8.2-intl php8.2-readline php8.2-msgpack php8.2-igbinary php8.2-gmp

_info "Installing PHP $(pGreen 8.1) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php8.1-cli php8.1-fpm php8.1-dev \
php8.1-pgsql php8.1-sqlite3 php8.1-gd \
php8.1-curl php8.1-memcached \
php8.1-imap php8.1-mysql php8.1-mbstring \
php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
php8.1-intl php8.1-readline php8.1-msgpack php8.1-igbinary php8.1-gmp

_info "Installing PHP $(pGreen 8.0) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php8.0-cli php8.0-fpm php8.0-dev \
php8.0-pgsql php8.0-sqlite3 php8.0-gd \
php8.0-curl php8.0-memcached \
php8.0-imap php8.0-mysql php8.0-mbstring \
php8.0-xml php8.0-zip php8.0-bcmath php8.0-soap \
php8.0-intl php8.0-readline php8.0-msgpack php8.0-igbinary php8.0-gmp



_info "Installing PHP $(pGreen 7.4) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php7.4-cli php7.4-fpm php7.4-dev \
php7.4-pgsql php7.4-sqlite3 php7.4-gd \
php7.4-curl php7.4-memcached \
php7.4-imap php7.4-mysql php7.4-mbstring \
php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap \
php7.4-intl php7.4-readline php7.4-msgpack php7.4-igbinary php7.4-gmp



_info "Installing PHP $(pGreen 7.3) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php7.3-cli php7.3-fpm php7.3-dev \
php7.3-pgsql php7.3-sqlite3 php7.3-gd \
php7.3-curl php7.3-memcached \
php7.3-imap php7.3-mysql php7.3-mbstring \
php7.3-xml php7.3-zip php7.3-bcmath php7.3-soap \
php7.3-intl php7.3-readline php7.3-msgpack php7.3-igbinary php7.3-gmp



_info "Installing PHP $(pGreen 7.2) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php7.2-cli php7.2-fpm php7.2-dev \
php7.2-pgsql php7.2-sqlite3 php7.2-gd \
php7.2-curl php7.2-memcached \
php7.2-imap php7.2-mysql php7.2-mbstring \
php7.2-xml php7.2-zip php7.2-bcmath php7.2-soap \
php7.2-intl php7.2-readline php7.2-msgpack php7.2-igbinary php7.2-gmp


_info "Installing PHP $(pGreen 7.1) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php7.1-cli php7.1-fpm php7.1-dev \
php7.1-pgsql php7.1-sqlite3 php7.1-gd \
php7.1-curl php7.1-memcached \
php7.1-imap php7.1-mysql php7.1-mbstring \
php7.1-xml php7.1-zip php7.1-bcmath php7.1-soap \
php7.1-intl php7.1-readline php7.1-msgpack php7.1-igbinary php7.1-gmp



_info "Installing PHP $(pGreen 7.0) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php7.0-cli php7.0-fpm php7.0-dev \
php7.0-pgsql php7.0-sqlite3 php7.0-gd \
php7.0-curl php7.0-memcached \
php7.0-imap php7.0-mysql php7.0-mbstring \
php7.0-xml php7.0-zip php7.0-bcmath php7.0-soap \
php7.0-intl php7.0-readline php7.0-msgpack php7.0-igbinary php7.0-gmp



_info "Installing PHP $(pGreen 5.6) with Extensions"

apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes php5.6-cli php5.6-fpm php5.6-dev \
php5.6-pgsql php5.6-sqlite3 php5.6-gd \
php5.6-curl php5.6-memcached \
php5.6-imap php5.6-mysql php5.6-mbstring \
php5.6-xml php5.6-zip php5.6-bcmath php5.6-soap \
php5.6-intl php5.6-readline php5.6-msgpack php5.6-igbinary php5.6-gmp


_info "Installing Composer Package Manager" 

if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
	
	
fi


_info "Doing Misc. PHP CLI Configuration"

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.2/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.2/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.2/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.2/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.2/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.1/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.1/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.1/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.1/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.1/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.0/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/5.6/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/5.6/cli/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/5.6/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/5.6/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/5.6/cli/php.ini



_info "Configuring $(pGreen 'Imagick')"

apt-get install -y --force-yes libmagickwand-dev

echo "extension=imagick.so" > /etc/php/8.2/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/8.1/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/8.0/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/7.4/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/7.3/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/7.2/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/7.1/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/7.0/mods-available/imagick.ini
echo "extension=imagick.so" > /etc/php/5.6/mods-available/imagick.ini

yes '' | apt install php-imagick




_info "Configure Sessions Directory Permissions"

chmod 733 /var/lib/php/sessions
chmod +t /var/lib/php/sessions




_info "Making PHP $(pGreen '8.2') default in CLI"

sudo update-alternatives --set php /usr/bin/php8.2





_info "Enough of PHP Stuff, Now Installing $(pGreen 'NGINX')"

apt-get install -y --force-yes nginx






_info "Tweaking Some PHP-FPM Settings"

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.2/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.2/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.2/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.2/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.2/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.1/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.1/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.1/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.1/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.1/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/5.6/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/5.6/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/5.6/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/5.6/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/5.6/fpm/php.ini




_info "Configuring Primary Nginx Settings"

##sed -i "s/user www-data;/user forge;/" /etc/nginx/nginx.conf
sed -i "s/worker_processes.*/worker_processes auto;/" /etc/nginx/nginx.conf
sed -i "s/# multi_accept.*/multi_accept on;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 128;/" /etc/nginx/nginx.conf




# Configure Gzip

# cat > /etc/nginx/conf.d/gzip.conf << EOF
# gzip_comp_level 5;
# gzip_min_length 256;
# gzip_proxied any;
# gzip_vary on;
# gzip_http_version 1.1;

# gzip_types
# application/atom+xml
# application/javascript
# application/json
# application/ld+json
# application/manifest+json
# application/rss+xml
# application/vnd.geo+json
# application/vnd.ms-fontobject
# application/x-font-ttf
# application/x-web-app-manifest+json
# application/xhtml+xml
# application/xml
# font/opentype
# image/bmp
# image/svg+xml
# image/x-icon
# text/cache-manifest
# text/css
# text/plain
# text/vcard
# text/vnd.rim.location.xloc
# text/vtt
# text/x-component
# text/x-cross-domain-policy;

# EOF


### Disable The Default Nginx Site

# rm /etc/nginx/sites-enabled/default
# rm /etc/nginx/sites-available/default
# service nginx restart

### Install A Catch All Server

# cat > /etc/nginx/sites-available/000-catch-all << EOF
# server {
#     return 404;
# }
# EOF

# ln -s /etc/nginx/sites-available/000-catch-all /etc/nginx/sites-enabled/000-catch-all


_info "Restarting Nginx & PHP-FPM Services"

# func from utilities
_restart_nginx_php






_info "Installing NodeJS, NPM, Yarn"

apt_wait

curl --silent --location https://deb.nodesource.com/setup_12.x | bash -

apt-get update

sudo apt-get install -y --force-yes nodejs



npm install -g pm2
npm install -g gulp
npm install -g yarn

_info "Time to Install RDBMS"

if is_installed mysql-* || is_installed mariadb* ; then
	
	_error "Wo Wo Wo ! Seems like MySQL/MariaDB server is Already Installed, Won't Mess with it, Skipping Next ...."

else

	ask_db_install

	_info "usermod on MYSQL"

	apt_wait

	sudo usermod -d /var/lib/mysql/ mysql

fi


apt_wait


_info "Installing & Configuring Redis Server"

apt-get install -y redis-server
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
service redis-server restart


yes '' | pecl install -f redis

if pecl list | grep redis >/dev/null 2>&1;
then

_info "Configuring $(pGreen 'PHPRedis')"

echo "extension=redis.so" > /etc/php/8.2/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/8.1/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/8.0/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/7.4/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/7.3/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/7.2/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/7.1/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/7.0/mods-available/redis.ini
echo "extension=redis.so" > /etc/php/5.6/mods-available/redis.ini

yes '' | apt install php-redis

fi

apt_wait



_info "Installing & Configuring Memcached"

apt-get install -y memcached
sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf
service memcached restart

_info "Configuring Supervisor Autostart"

service supervisor start

_info "=============================="

_success "Everything DONE, Now Verifying"

_checking_all


## Clean and Autoremove

sudo apt autoremove -y


### BYE

_success "Don't Forget to Update your Windows Hosts file"

_success "MySQL default user is $(pTan 'root') and password is $(pTan 'root')"

_success "All PHP versions are Running, Use PHP Tools to Change Version for vHosts and CLI"

_success "Redis and Memcached are both running with default ports/settings"

_success "========== ALL GOOD, EXITING TO MAIN MENU =========="

exit 0;

}

ask_db_install(){
echo -ne "$(pBlue "What you want to Install? Type $(pGreen '1') to MariaDB 10.6 or $(pRed '2') for MySQL 8.0):  ")"
        read a
        case $a in
	      1) install_mariadb ;;
	      2) install_mysql ;;
			*) _error "Wrong Choice !!, Y for Continue, N for Abort"; ask_db_install;;
        esac
}

function install_mariadb() {
UBUNTU_VERSION="$(lsb_release -rs)"
	
	
	


	_info "OK, Installing MariaDB 10.6"

	sudo apt-get install software-properties-common
	sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
   
  if [[ "$UBUNTU_VERSION" == "22.04" ]];
	then

	sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirrors.coreix.net/mariadb/repo/10.6/ubuntu jammy main'

	elif [[ "$UBUNTU_VERSION" == "20.04" ]];
	then

	sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirrors.coreix.net/mariadb/repo/10.6/ubuntu focal main'

	elif [[ "$UBUNTU_VERSION" == "18.04" ]];
	then

	sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirrors.coreix.net/mariadb/repo/10.6/ubuntu bionic main'

	fi



	export DEBIAN_FRONTEND=noninteractive

	debconf-set-selections <<< "mariadb-server-10.6 mysql-server/data-dir select ''"
	debconf-set-selections <<< "mariadb-server-10.6 mysql-server/root_password password root"
	debconf-set-selections <<< "mariadb-server-10.6 mysql-server/root_password_again password root"

	apt_wait
	sudo apt update
	apt_wait
	sudo apt install -y mariadb-server

	_info "Configure Max Connections"

	RAM=$(awk '/^MemTotal:/{printf "%3.0f", $2 / (1024 * 1024)}' /proc/meminfo)
	MAX_CONNECTIONS=$(( 70 * $RAM ))
	REAL_MAX_CONNECTIONS=$(( MAX_CONNECTIONS>70 ? MAX_CONNECTIONS : 100 ))
	sed -i "s/^max_connections.*=.*/max_connections=${REAL_MAX_CONNECTIONS}/" /etc/mysql/my.cnf


	_info "Configure Access Permissions For Root"

	sed -i '/^bind-address/s/bind-address.*=.*/bind-address = */' /etc/mysql/my.cnf
	mysql --user="root" --password="root" -e "GRANT ALL ON *.* TO root@'localhost' IDENTIFIED BY 'root';"
	mysql --user="root" --password="root" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root';"
	service mysql restart
	mysql --user="root" --password="root" -e "FLUSH PRIVILEGES;"


	# # Set Character Set

	echo "" >> /etc/mysql/my.cnf
	echo "[mysqld]" >> /etc/mysql/my.cnf
	# # echo "character-set-server = utf8" >> /etc/mysql/my.cnf

	# # Create The Initial Database If Specified

	# mysql --user="root" --password="GrEAl7KC2cRCpEPrKoWC" -e "CREATE DATABASE forge;"

}


function install_mysql() {


	_info "OK, Installing MySQL 8.0"

	export DEBIAN_FRONTEND=noninteractive

wget -c https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb
dpkg --install mysql-apt-config_0.8.15-1_all.deb

debconf-set-selections <<< "mysql-community-server mysql-community-server/data-dir select ''"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password root"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password root"

apt-get update

_info "Install MySQL"

apt-get install -y mysql-community-server
apt-get install -y mysql-server

_info "Configure Password Expiration"

echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

_info "Set Character Set"

echo "" >> /etc/mysql/my.cnf
echo "[mysqld]" >> /etc/mysql/my.cnf
echo "default_authentication_plugin=mysql_native_password" >> /etc/mysql/my.cnf
echo "skip-log-bin" >> /etc/mysql/my.cnf

_info "Configure Max Connections"

RAM=$(awk '/^MemTotal:/{printf "%3.0f", $2 / (1024 * 1024)}' /proc/meminfo)
MAX_CONNECTIONS=$(( 70 * $RAM ))
REAL_MAX_CONNECTIONS=$(( MAX_CONNECTIONS>70 ? MAX_CONNECTIONS : 100 ))
sed -i "s/^max_connections.*=.*/max_connections=${REAL_MAX_CONNECTIONS}/" /etc/mysql/my.cnf

_info "Configure Access Permissions For Root"

sed -i '/^bind-address/s/bind-address.*=.*/bind-address = */' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql --user="root" --password="root" -e "CREATE USER 'root'@'188.166.106.68' IDENTIFIED BY 'root';"
mysql --user="root" --password="root" -e "CREATE USER 'root'@'%' IDENTIFIED BY 'root';"
mysql --user="root" --password="root" -e "GRANT ALL PRIVILEGES ON *.* TO root@'188.166.106.68' WITH GRANT OPTION;"
mysql --user="root" --password="root" -e "GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION;"

service mysql restart

mysql --user="root" --password="root" -e "FLUSH PRIVILEGES;"

# Create The Initial Database If Specified

# mysql --user="root" --password="root" -e "CREATE DATABASE forge CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

    # If MySQL Fails To Start, Re-Install It

    service mysql restart

    if [[ $? -ne 0 ]]; then
        echo "Purging previous MySQL8 installation..."

        sudo apt-get purge mysql-server mysql-community-server -y
        sudo apt-get autoclean && sudo apt-get clean
		install_mysql
	fi

}
 
#### MAIN ####


menu
