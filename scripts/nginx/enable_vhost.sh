#!/bin/bash

source $parent_path/utilities.sh

function enable_vhost () {
   
   
echo -ne "
$(pTan '== List of vHosts Available ==')
"

print_vHosts

echo -ne "

$(pGreen '(0)') << Go Back to NGinx Tools
--------------------------------
$(pBlue ':: Select Your vHost (by number) that you want to ENABLE: ') "

read a


b=$(($a-1))

if [ $a == "0" ]; then

exit 1;

elif [ -z "${vhosts_av[b]}" ]; then

_error "Wrong Choice"

else

_success "You selected: ${vhosts_av[b]}"

if [[ -f "$vhosts_en_dir/${vhosts_av[b]}" ]]; then
    _error "${vhosts_av[b]} is already enabled. Do you want to remove it and Enable again ? (Y/N) : "
    read answer
        case $answer in
            y|Y) rm -f $vhosts_en_dir/${vhosts_av[b]}; ln -s "$vhosts_av_dir/${vhosts_av[b]}" "$vhosts_en_dir/${vhosts_av[b]}";;
            *) exit 1;;
        esac
else 
ln -s "$vhosts_av_dir/${vhosts_av[b]}" "$vhosts_en_dir/${vhosts_av[b]}" || _die "Couldn't create symlink to file: "$vhosts_en_dir/${vhosts_av[b]}""
fi

_success "${vhosts_av[b]} Enabled Successfully"

fi

_continue

}


_info "================================"

enable_vhost

_arrow "Restarting Nginx and PHP"

_restart_nginx_php

exit 1;