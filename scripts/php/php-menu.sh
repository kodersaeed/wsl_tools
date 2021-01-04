#!/bin/bash

source utilities.sh

function change_cli_ver () {
    if sudo update-alternatives --set php /usr/bin/php$1 > /dev/null 2>&1; then
         _success "=========================================="
         _success "PHP CLI Version Successfully Changed to $(pTan $1)"
         _success "=========================================="

        ## starting it just in case
        service php$1-fpm start > /dev/null 2>&1;

         _continue

    elif service php$1-fpm start > /dev/null 2>&1; then

         change_cli_ver $1
         
    else
         _error "PHP $1 is not installed"
         _continue
    fi
}


function change_vhost_ver () {

    if grep -q fastcgi_pass "$vhosts_av_dir/$1"; then

    ## change version
    sed -i "s/fastcgi_pass.*/fastcgi_pass unix:\/var\/run\/php\/php$2-fpm.sock;/" $vhosts_av_dir/$1 > /dev/null 2>&1

    _success "Changed PHP version in fastcgi_pass SUCCESSFULLY"
         
    else
         _error "$1 is NOT a valid PHP vHost, IT DOES NOT CONTAIN fastcgi_pass, Use NGINX Tools to Create a PHP vHost"
         
    fi

# func from utilities
_arrow "Restarting Nginx and PHP"

_restart_nginx_php
_continue

}


function change_cli_menu() {
	
    echo -ne "
$(pTan '== Which PHP Version would you like to Change CLI to? ==')

$(pGreen '(1)') PHP 8.0
$(pGreen '(2)') PHP 7.4
$(pGreen '(3)') PHP 7.3
$(pGreen '(4)') PHP 7.2
$(pGreen '(5)') PHP 7.1
$(pGreen '(6)') PHP 7.0
$(pGreen '(7)') PHP 5.6

$(pGreen '(0)') << Go Back to PHP Tools
-----------------------------------
$(pBlue ':: Change CLI Version :: Choose an option (by number): ') "
        read a
        case $a in
	        1) change_cli_ver "8.0" ; menu ;;
	        2) change_cli_ver "7.4" ; menu ;;
	        3) change_cli_ver "7.3" ; menu ;;
	        4) change_cli_ver "7.2" ; menu ;;
	        5) change_cli_ver "7.1" ; menu ;;
	        6) change_cli_ver "7.0" ; menu ;;
	        7) change_cli_ver "5.6" ; menu ;;
		    0) menu ;;
		    *) _error "Wrong Choice !!";_continue; change_cli_menu;;
        esac

}

function change_vhost_php_menu() {
	
    echo -ne "
"
pTan "== Which PHP Version would you like for vHost $(pGreen $1)? ==

"

echo -ne "
$(pGreen '(1)') PHP 8.0
$(pGreen '(2)') PHP 7.4
$(pGreen '(3)') PHP 7.3
$(pGreen '(4)') PHP 7.2
$(pGreen '(5)') PHP 7.1
$(pGreen '(6)') PHP 7.0
$(pGreen '(7)') PHP 5.6

$(pGreen '(0)') << Go Back to vHosts List
-----------------------------------
$(pBlue ':: Choose an option (by number):  ') "
        read a
        case $a in
	        1) change_vhost_ver $1 "8.0" ; menu;;
	        2) change_vhost_ver $1 "7.4" ; menu;;
	        3) change_vhost_ver $1 "7.3" ; menu;;
	        4) change_vhost_ver $1 "7.2" ; menu;;
	        5) change_vhost_ver $1 "7.1" ; menu;;
	        6) change_vhost_ver $1 "7.0" ; menu;;
	        7) change_vhost_ver $1 "5.6" ; menu;;
		    0) change_vhost_menu ;;
		    *) _error "Wrong Choice !!";_continue; change_vhost_php_menu $1;;
        esac

}

function change_vhost_menu() {

echo -ne "
$(pTan '== Please select the your vHost (list from sites-available) ==')
"




print_vHosts

echo -ne "

$(pGreen '(0)') << Go Back to PHP Tools
--------------------------------
$(pBlue ':: Select Your vHost:') "

read a


b=$(($a-1))

if [ $a == "0" ]; then

menu

elif [ -z "${vhosts_av[b]}" ]; then

_error "Wrong Choice"

else

_success "You selected: ${vhosts_av[b]}"

change_vhost_php_menu "${vhosts_av[b]}"

fi

_continue
change_vhost_menu

}

function change_values_menu () {

    echo -ne "
$(pTan '== This change upload_max_filesize, post_max_size in PHP.ini for All versions & client_max_body_size in Nginx conf ==')
"

    echo -ne "
$(pTan 'Type the Upload size in Kilobyte (e.g. 100K), Megabyte (e.g. $size) or Gigabyte (e.g. 1G) :  ')
"
read size

if [[ $size =~ ^[+-]?([0-9]*[.])?[0-9]+[KMG]$ ]]; then
     change_values $size
else
     _error "That's not a Valid Size ! Type any Number with K, M or G"
     change_values_menu
fi
}

function change_values () {
    
        
rm -f /etc/nginx/conf.d/limits.conf

sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/8.0/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/8.0/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/8.0/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/8.0/cli/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.4/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.4/cli/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.3/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.3/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.3/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.3/cli/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.2/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.2/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.2/cli/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = $size/" /etc/php/5.6/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/5.6/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = $size/" /etc/php/5.6/cli/php.ini

if grep client_max_body_size /etc/nginx/nginx.conf; then
    sudo sed -i '/client_max_body_size/d' /etc/nginx/nginx.conf
fi

echo "client_max_body_size $size;" > /etc/nginx/conf.d/uploads.conf

_success "Sizes in PHP.ini files & Nginx CHANGED SUCCESSFULLY to $(pRed $size)"

_arrow "Restarting Nginx and PHP"

_restart_nginx_php

}




menu(){
echo -ne "

$(_underline '### PHP Tools  ###')

$(pGreen '(1)') Change PHP CLI Version
$(pGreen '(2)') Change PHP Version for vHost
$(pGreen '(3)') Update MAX POST/UPLOAD Size in PHP.ini

$(pGreen '(0)') << Go Back to MainMenu
-----------------------------------
$(pBlue ':: PHPTools :: Choose an option:') "
        read a
        case $a in
	        1) change_cli_menu ; menu ;;
	        2) change_vhost_menu ; menu ;;
	        3) change_values_menu ; menu ;;
		    0) exit 0 ;;
		    *) _error "Wrong Choice !!"; menu;;
        esac
}



menu