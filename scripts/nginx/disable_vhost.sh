#!/bin/bash

source utilities.sh

function disable_vhost () {
   
   
echo -ne "
$(pTan '== List of Currently Enabled vHosts ==')
"

print_vHosts_en

echo -ne "

$(pGreen '(0)') << Go Back to NGinx Tools
--------------------------------
$(pBlue ':: Select Your vHost (by number) that you want to DISABLE:') "

read a


b=$(($a-1))

if [ $a == "0" ]; then

exit 1;

elif [ -z "${vhosts_en[b]}" ]; then

_error "Wrong Choice"

else

_success "You selected: ${vhosts_en[b]}"

rm -f $vhosts_en_dir/${vhosts_en[b]};

if [[ ! -f "$vhosts_en_dir/${vhosts_en[b]}" ]]; then

_success "${vhosts_en[b]} Successfully $(pRed 'Disabled')"

else 

_info "Problem in Disabling ${vhosts_en[b]}"

fi

fi

_continue

}


_info "================================"

disable_vhost

_arrow "Restarting Nginx and PHP"

_restart_nginx_php

exit 1;