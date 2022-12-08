#!/bin/bash


## Utility Functions and variables to be used by Scripts

# Styles

vhosts_av_dir="/etc/nginx/sites-available"
vhosts_av_files=( "$vhosts_av_dir"/* )
vhosts_av=( "${vhosts_av_files[@]##*/}" )

vhosts_en_dir="/etc/nginx/sites-enabled"
vhosts_en_files=( "$vhosts_en_dir"/* )
vhosts_en=( "${vhosts_en_files[@]##*/}" )

_bold=$(tput bold)
_underline=$(tput sgr 0 1)
_reset=$(tput sgr0)

_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)

print_vHosts() {
for i in ${!vhosts_av[*]}; do
n=$(($i+1))
echo -ne "
$(pGreen "($n)") "${vhosts_av[i]}""
done
}

print_vHosts_en() {
for i in ${!vhosts_en[*]}; do
n=$(($i+1))
echo -ne "
$(pGreen "($n)") "${vhosts_en[i]}""
done
}

pGreen(){
	echo -ne $_green$1$_reset
}
pBlue(){
	echo -ne $_blue$1$_reset
}
pRed(){
	echo -ne $_red$1$_reset
}
pTan(){
	echo -ne $_tan$1$_reset
}

function _debug()
{
    if [[ "$DEBUG" = 1 ]]; then
        "$@"
    fi
}

function _check(){
    if $1; 
    then _success "Installed and Working!";
    else
    _error "NOT Working!"
    fi
}

function is_installed() {
    if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
    return 1; # NOT INSTALLED
    else
    return 0; # INSTALLED
    fi
}

function _header()
{
    printf '\n%s%s==========  %s  ==========%s\n' "$_bold" "$_purple" "$@" "$_reset"
}

function _arrow()
{
    printf '➜ %s\n' "$@"
}

function _success()
{
    printf '%s✔ %s%s\n' "$_green" "$@" "$_reset"
}

function _error() {
    printf '%s✖ %s%s\n' "$_red" "$@" "$_reset"
}

function _info()
{
    printf '%s➜ %s%s\n' "$_tan" "$@" "$_reset"
}

function _underline()
{
    printf '%s%s%s%s\n' "$_underline" "$_bold" "$@" "$_reset"
}

function _bold()
{
    printf '%s%s%s\n' "$_bold" "$@" "$_reset"
}

function _note()
{
    printf '%s%s%sNote:%s %s%s%s\n' "$_underline" "$_bold" "$_blue" "$_reset" "$_blue" "$@" "$_reset"
}

function _die()
{
    _error "$@"
    exit 1
}

function _safeExit()
{
    exit 0
}

function _seekConfirmation()
{
  printf '\n%s%s%s' "$_bold" "$@" "$_reset"
  read -p " (y/n) " -n 1
  printf '\n'
}

# Test whether the result of an 'ask' is a confirmation
function _isConfirmed()
{
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0
    fi
    return 1
}

function _continue () {
   _info "Press Any Key to Continue"
         read response
         return 1
}


function _ubuntu_only() {
    UBUNTU_VERSION="$(lsb_release -rs)"

    if _isOsDebian; then

        if [[ "$UBUNTU_VERSION" != "20.04" && "$UBUNTU_VERSION" != "18.04" ]];
        then

        _die "This Script is Only for Ubuntu 20.04 or 18.04, SORRY, BYEEEE"
        

        fi

    else
         _die "This Script is Only for Debian Ubuntu 20.04 or 18.04, SORRY, BYEEEE"
    fi
    

    
}

function _checking_all() {
    _arrow "Checking PHP CLI"

_check "php -v";

_arrow "Checking PHP-FPM 8.2"

_check "service php8.2-fpm status";

_arrow "Checking PHP-FPM 8.1"

_check "service php8.1-fpm status";

_arrow "Checking PHP-FPM 8.0"

_check "service php8.0-fpm status";

_arrow "Checking PHP-FPM 7.4"

_check "service php7.4-fpm status";

_arrow "Checking PHP-FPM 7.3"

_check "service php7.3-fpm status";

_arrow "Checking PHP-FPM 7.2"

_check "service php7.2-fpm status";

_arrow "Checking PHP-FPM 7.1"

_check "service php7.1-fpm status";

_arrow "Checking PHP-FPM 7.0"

_check "service php7.0-fpm status";

_arrow "Checking PHP-FPM 5.6"

_check "service php5.6-fpm status";

_arrow "Checking Nginx"

_check "nginx -v";

_arrow "Checking Mysql"

_check "service mysql status";

_arrow "Checking NodeJs"

_check "node -v";

_arrow "Checking NPM"

_check "npm -v";

_arrow "Checking Yarn"

_check "yarn -v";

_arrow "Checking Redis"

_check "redis-cli ping";

_arrow "Checking Memcached"

_check "service memcached status";
}


function _typeExists()
{
    if type "$1" >/dev/null; then
        return 0
    fi
    return 1
}

function _isOs()
{
    if [[ "${OSTYPE}" == $1* ]]; then
      return 0
    fi
    return 1
}

function _isOsDebian()
{
    if [[ -f /etc/debian_version ]]; then
        return 0
    else
        return 1
    fi
}

function _isOsRedHat()
{
    if [[ -f /etc/redhat-release ]]; then
        return 0
    else
        return 1
    fi
}

function _isOsMac()
{
    if [[ "$(uname -s)" = "Darwin" ]]; then
        return 0
    else
        return 1
    fi
}

function _checkRootUser()
{
    # Check if script is run as root user
	if [[ "$EUID" -ne 0 ]] ; then
		_die "You must run this script as root user, Try: sudo $0"
	fi
}

function _greeting()
{
    cat <<EOF
${_purple}
########################################
Welcome to WSL Tools v1.0

>> Author: Saeed (kodersaeed@gmail.com)
########################################
${_reset}
EOF
}

function _domainCheck {
	# Check if input is a domain/subdomain and set variable accordingly
	if [[ ! "$FQDN" =~ (^[A-Za-z0-9._%+-]*\.*[A-Za-z0-9.-]+\.[A-Za-z]{2,10}$) ]]; then
		FQDNVALID=false
	else
		FQDNVALID=true
	fi
}

apt_wait () {
    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
        echo "Waiting: dpkg/lock is locked..."
        sleep 5
    done

    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 ; do
        echo "Waiting: dpkg/lock-frontend is locked..."
        sleep 5
    done

    while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
        echo "Waiting: lists/lock is locked..."
        sleep 5
    done

    if [ -f /var/log/unattended-upgrades/unattended-upgrades.log ]; then
        while fuser /var/log/unattended-upgrades/unattended-upgrades.log >/dev/null 2>&1 ; do
            echo "Waiting: unattended-upgrades is locked..."
            sleep 5
        done
    fi
}

function _restart_nginx_php () {

    _arrow "Restarting Nginx and PHP, Please wait"

    if nginx -t > /dev/null 2>&1; then
       _success "Nginx Conf is Valid & Successful"
       service nginx restart > /dev/null 2>&1
        service nginx reload > /dev/null 2>&1
    fi

if [ ! -z "\$(ps aux | grep php-fpm | grep -v grep)" ]
then
	service php8.2-fpm start > /dev/null 2>&1	
	service php8.1-fpm start > /dev/null 2>&1	
	service php8.0-fpm start > /dev/null 2>&1	
    service php7.4-fpm start > /dev/null 2>&1
    service php7.3-fpm start > /dev/null 2>&1
    service php7.2-fpm start > /dev/null 2>&1
    service php7.1-fpm start > /dev/null 2>&1
    service php7.0-fpm start > /dev/null 2>&1
    service php5.6-fpm start > /dev/null 2>&1
    service php5-fpm start > /dev/null 2>&1

    service php8.2-fpm restart > /dev/null 2>&1
    service php8.1-fpm restart > /dev/null 2>&1
    service php8.0-fpm restart > /dev/null 2>&1
    service php7.4-fpm restart > /dev/null 2>&1
    service php7.3-fpm restart > /dev/null 2>&1
    service php7.2-fpm restart > /dev/null 2>&1
    service php7.1-fpm restart > /dev/null 2>&1
    service php7.0-fpm restart > /dev/null 2>&1
    service php5.6-fpm restart > /dev/null 2>&1
    service php5-fpm restart > /dev/null 2>&1
fi

 _success "Restarted NGINX & All PHP-FPM versions"

}

function is_Domain_Valid {
	# Check if input is a domain/subdomain and set variable accordingly
	if [[ ! "$1" =~ (^[A-Za-z0-9._%+-]*\.*[A-Za-z0-9.-]+\.[A-Za-z]{2,10}$) ]]; then
		
        return 1; #domain invalid
	else
		return 0; #domain VALID
	fi
}

## Trapping CTRL+C
exitfn () {
    trap INT              # Restore signal handling for SIGINT
    echo; echo "OH NOO!! DONT LEAVE US LIKE THAT!! 😁😁"    # Growl at user
	# returning to dir saved in pushd by the alias
    exit                     #   then exit script.
}

trap "exitfn" INT


#check root
_checkRootUser

#check_ubuntu
_ubuntu_only