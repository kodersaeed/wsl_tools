#!/bin/bash

source $parent_path/utilities.sh

DOMAIN="-----"
DOMAIN_DIR="-----"
DOMAIN_TYPE="-----"
PHP_VER="8.2"


function prepareVhostFilePaths()
{
    NGINX_SITES_ENABLED_FILE="${vhosts_en_dir}/${DOMAIN}"
    NGINX_SITES_AVAILABLE_FILE="${vhosts_av_dir}/${DOMAIN}"
}

function createVhostSymlinks()
{
    _info "$DOMAIN vHost is Created, Do you want to Enable it Now ? (Y/N) : "
    read answer
        case $answer in
            y|Y) _success "Enabling $DOMAIN Now ...";;
            *) _info "EXITING Without Enabling $DOMAIN Now ..."; return 0;;
        esac

    ln -s "$NGINX_SITES_AVAILABLE_FILE" "$NGINX_SITES_ENABLED_FILE" || _die "Couldn't create symlink to file: ${NGINX_SITES_AVAILABLE_FILE}"


}

function ask_domain() {
    pBlue "
    Enter the domain (FQDN) that you want to create a vHost for:  "
        read DOMAIN

        if [ "$DOMAIN" == "0" ]; then
            exit 1;
        fi
        
    if is_Domain_Valid $DOMAIN; then
        if [[ -f "${vhosts_av_dir}/${DOMAIN}" ]]; then
            _error "Vhost file already exists: ${vhosts_av_dir}/${DOMAIN}, Remove it first"
            ask_domain
        else
            
            return 0
        fi
         
    else
         _error "Comon !!, That's not a VALID domain (FQDN)"
         ask_domain
    fi 
}

function ask_dir() {
    

    pBlue "
    Enter root path (e.g. /var/www/html/$DOMAIN) for $(pGreen $DOMAIN) (Enter 0 to Change Domain)::  "
        read a

        case $a in
		    0) ask_domain ;;
		    *) DOMAIN_DIR="$a" ;;
        esac

    if [[ -z $DOMAIN_DIR || "$DOMAIN_DIR" != /* ]]; then
        
        _error "Root Must be Absolute Path beginning with a /"
         ask_dir
         
    else
        if [[ ! -d "$DOMAIN_DIR" ]]; then

        _error "$DOMAIN_DIR directory doesn't exist. You Want to Continue ? (Y/N) : "
        read answer
            case $answer in
                y|Y) DOMAIN_DIR=$DOMAIN_DIR;;
                *) ask_dir;;
            esac
        fi

        # Verify the current directory as per application
        _arrow "Verifying the current directory is root of ${DOMAIN_TYPE}..."
        verifyCurrentDirIsAppRoot
    
        
    fi

    
}


function ask_type() {
    

echo -ne "
Choose the type for $(pGreen $DOMAIN) 

$(pGreen '(1)') Laravel ( with /public root)

$(pGreen '(2)') Any PHP Site (Wordpress, index.php Websites)

$(pGreen '(3)') Static HTML (index.html)

$(pGreen '(4)') Vue Or Nuxt Static (Not SSR)

$(pGreen '(5)') NuxtJs (SSR with NodeJS)

$(pGreen '(0)') << Change Directory Name
-----------------------------------
$(pBlue ':: PHPTools :: Choose an option:') "
        read a

        case $a in
	        1) DOMAIN_TYPE="laravel" ;;
	        2) DOMAIN_TYPE="php" ;;
	        3) DOMAIN_TYPE="static" ;;
	        4) DOMAIN_TYPE="vue" ;;
	        5) DOMAIN_TYPE="nuxt" ;;
		    0) ask_dir ;;
		    *) _error "Wrong Choice !!"; ask_type;;
        esac

}

function ask_php() {
	
    echo -ne "
"
pTan "== Which PHP Version would you like for vHost $(pGreen $DOMAIN)? ==

"

echo -ne "
$(pGreen '(1)') 8.2
$(pGreen '(2)') 8.1
$(pGreen '(3)') 8.0
$(pGreen '(4)') 7.4
$(pGreen '(5)') 7.3
$(pGreen '(6)') 7.2
$(pGreen '(7)') 7.1
$(pGreen '(8)') 7.0
$(pGreen '(9)') 5.6

$(pGreen '(0)') << Go Back to Directory Step
-----------------------------------
$(pBlue ':: Choose an option:  ') "
        read a
        case $a in
	        1) PHP_VER="8.2";;
	        2) PHP_VER="8.1";;
	        3) PHP_VER="8.0";;
	        4) PHP_VER="7.4";;
	        5) PHP_VER="7.3";;
	        6) PHP_VER="7.2";;
	        7) PHP_VER="7.1";;
	        8) PHP_VER="7.0";;
	        9) PHP_VER="5.6";;
		    0) ask_dir ;;
		    *) _error "Wrong Choice !!";_continue; ask_php;;
        esac

}

function create_vhost_file() {

    _arrow "Creating Nginx Vhost File..."

    prepareVhostFilePaths
    prepareAppVhostContent
    createVhostSymlinks

    if nginx -t > /dev/null 2>&1; then
       _success "Nginx Conf is Valid & Successful"
    fi
    

    _arrow "Restarting Nginx and PHP"

_restart_nginx_php

    printSuccessMessage

    _continue
}

function prepareAppVhostContent()
{
    if [[ "$DOMAIN_TYPE" = 'laravel' || "$DOMAIN_TYPE" = 'php' ]]; then
        preparePHPVhostContent
    elif [[ "$DOMAIN_TYPE" = 'static' || "$DOMAIN_TYPE" = 'vue' ]]; then
        prepareStaticVhostContent
    elif [[ "$DOMAIN_TYPE" = 'nuxt' ]]; then
        prepareNuxtSSRVhostContent
    fi
}

function preparePHPVhostContent() {
 
 echo "server {
    listen     80;             # the port nginx is listening on
    server_name ${DOMAIN};
    root ${DOMAIN_DIR};

    add_header X-Frame-Options \"SAMEORIGIN\";
    add_header X-XSS-Protection \"1; mode=block\";
    add_header X-Content-Type-Options \"nosniff\";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/${DOMAIN}-error.log error;

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php${PHP_VER}-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}" > "$NGINX_SITES_AVAILABLE_FILE" || _die "Couldn't write to file: ${NGINX_SITES_AVAILABLE_FILE}"

    _arrow "${NGINX_SITES_AVAILABLE_FILE} file has been created."
}

function prepareStaticVhostContent() {
 
 echo "server {
    listen     80;             # the port nginx is listening on
    server_name ${DOMAIN};
    server_tokens off;
    root ${DOMAIN_DIR};

    add_header X-Frame-Options \"SAMEORIGIN\";
    add_header X-XSS-Protection \"1; mode=block\";
    add_header X-Content-Type-Options \"nosniff\";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/${DOMAIN}-error.log error;

    error_page 404 /index.html;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php${PHP_VER}-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}" > "$NGINX_SITES_AVAILABLE_FILE" || _die "Couldn't write to file: ${NGINX_SITES_AVAILABLE_FILE}"

    _arrow "${NGINX_SITES_AVAILABLE_FILE} file has been created."
}

function prepareNuxtSSRVhostContent()
{
 
 echo "
map \$sent_http_content_type \$expires {
    \"text/html\"                 epoch;
    \"text/html; charset=utf-8\"  epoch;
    default                     off;
}

server {
    listen          80;             # the port nginx is listening on
    server_name ${DOMAIN};
    root ${DOMAIN_DIR};

    add_header X-Frame-Options \"SAMEORIGIN\";
    add_header X-XSS-Protection \"1; mode=block\";
    add_header X-Content-Type-Options \"nosniff\";

    index index.html index.htm index.php;

    charset utf-8;
    
    gzip            off;            ## For DEV env
    gzip_types      text/plain application/xml text/css application/javascript;
    gzip_min_length 1000;

    location / {
        expires \$expires;
        proxy_redirect off;
        proxy_read_timeout 1m;
        proxy_http_version 1.1;
        proxy_connect_timeout 1m;
        proxy_set_header Host \$host;
        proxy_pass http://127.0.0.1:3000;   # set the address of the Node.js instance here
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/${DOMAIN}-error.log error;

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php${PHP_VER}-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

" > "$NGINX_SITES_AVAILABLE_FILE" || _die "Couldn't write to file: ${NGINX_SITES_AVAILABLE_FILE}"

    _arrow "${NGINX_SITES_AVAILABLE_FILE} file has been created."
}



menu(){
echo -ne "

$(_underline '### NGINX Tools  ###')

$(pGreen '(1)') Create vHost (Laravel/PHP, Static HTML, Wordpress)
$(pGreen '(2)') Remove vHost
$(pGreen '(3)') Enable a vHost
$(pGreen '(4)') Disable a vHost

$(pGreen '(0)') << Go Back to MainMenu
-----------------------------------
$(pBlue ':: NGINX Tools :: Choose an option:') "
        read a
        case $a in
	        1) create_vhost ; menu ;;
	        2) change_vhost_menu ; menu ;;
		    0) exit 0 ;;
		    *) _error "Wrong Choice !!"; menu;;
        esac
}

function verifyCurrentDirIsAppRoot()
{
    if [[ "$DOMAIN_TYPE" = 'laravel' ]]; then
        verifyCurrentDirIsLaravelRoot
    elif [[ "$DOMAIN_TYPE" = 'vue' ]]; then
        verifyCurrentDirIsVueRoot
    fi
}

function verifyCurrentDirIsLaravelRoot()
{
    if [[ ! -f "$DOMAIN_DIR/bootstrap/app.php" && "$DOMAIN_DIR" != *public ]]; then
        _error "$DOMAIN_DIR doesn't seem like Laravel Root & it also Doesn't end with /public, Should We Add /public at the end? (Y/N)"
        read a
        case $a in
	        y|Y) _success "OK, Making it $DOMAIN_DIR/public"; makeLaravelPublicWithPermissions;;
	        n|N) _info "OK, We will add it in vHost conf as $DOMAIN_DIR"; DOMAIN_DIR="$DOMAIN_DIR";;
	        *) ask_dir;;
        esac
    else
    
    makeLaravelPublicWithPermissions

    fi
}

function makeLaravelPublicWithPermissions()
{
    _info "$DOMAIN_DIR is considered a Laravel Root, making it $DOMAIN_DIR/public"

    _info "Fixing Permissions on $DOMAIN_DIR/storage and $DOMAIN_DIR/bootstrap/cache"
    
    sudo chown -R $USER:www-data $DOMAIN_DIR/storage
    sudo chown -R $USER:www-data $DOMAIN_DIR/bootstrap/cache
    sudo chmod -R 775 $DOMAIN_DIR/storage
    sudo chmod -R 775 $DOMAIN_DIR/bootstrap/cache

    
    DOMAIN_DIR="$DOMAIN_DIR/public"
}

function verifyCurrentDirIsVueRoot()
{
    if [[ "$DOMAIN_DIR" != *dist ]]; then
        _error "You chose 'VUE/NUXT Generated' but Your vHost root doesn't end with /dist, Should we add /dist at the end? (Y/N)"
        read a
        case $a in
	        y|Y) _success "OK, Making it $DOMAIN_DIR/dist"; DOMAIN_DIR="$DOMAIN_DIR/dist";;
	        n|N) _info "OK, We will add it in vHost conf as $DOMAIN_DIR"; DOMAIN_DIR="$DOMAIN_DIR";;
	        *) ask_dir;;
        esac
    fi
}

function printSuccessMessage()
{
    _success "Virtual host for Nginx has been successfully created!"

    echo "################################################################"
    echo ""
    echo " >> Domain               : ${DOMAIN}"
    echo " >> Application          : ${DOMAIN_TYPE}"
    echo " >> Document Root        : ${DOMAIN_DIR}"
    echo " >> PHP Version          : PHP ${PHP_VER}"
    echo " >> Nginx Config File    : ${NGINX_SITES_ENABLED_FILE}"
    echo ""
    echo "################################################################"

    _success "You can add \""'127.0.0.1 '${DOMAIN}"\" in your %WINDIR%\System32\drivers\etc\hosts file to access the vHost"

}




_info "================================"

ask_domain

_info "================================"

ask_type

_info "================================"

ask_dir

 if [[ "$DOMAIN_TYPE" = 'laravel' || "$DOMAIN_TYPE" = 'php' ]]; then

_info "================================"

ask_php

fi





_info "================================"

create_vhost_file
