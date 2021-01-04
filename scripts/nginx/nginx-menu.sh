#!/bin/bash

source ./utilities.sh

function create_vhost () {
    bash ./scripts/nginx/create_vhost.sh
}

function remove_vhost () {
    bash ./scripts/nginx/remove_vhost.sh
}

function enable_vhost () {    
    bash ./scripts/nginx/enable_vhost.sh
}

function disable_vhost () {    
    bash ./scripts/nginx/disable_vhost.sh
}


menu(){
echo -ne "

$(_underline '### NGINX Tools  ###')

$(pGreen '(1)') Create vHost & Enable it (Laravel/PHP, Vue/Static, NuxtJS SSR)
$(pGreen '(2)') $(pRed 'Remove vHost') (Delete from sites-available & sites-enabled)
$(pGreen '(3)') Enable a vHost (Symlink from sites-available TO sites-enabled)
$(pGreen '(4)') Disable a vHost (Remove from sites-enabled)

$(pGreen '(0)') << Go Back to MainMenu
-----------------------------------
$(pBlue ':: NGINX Tools :: Choose an option:') "
        read a
        case $a in
	        1) create_vhost ; menu ;;
	        2) remove_vhost ; menu ;;
	        3) enable_vhost ; menu ;;
	        4) disable_vhost ; menu ;;
		    0) exit 0 ;;
		    *) _error "Wrong Choice !!"; menu;;
        esac
}



menu