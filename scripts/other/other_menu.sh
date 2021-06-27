#!/bin/bash

source $parent_path/utilities.sh

menu(){
echo -ne "

$(_underline '### Other Tools  ###')

$(pGreen '(1)') Restart PHP & Nginx

$(pGreen '(0)') << Go Back to MainMenu
-----------------------------------
$(pBlue ':: PHPTools :: Choose an option:') "
        read a
        case $a in
	        1) _restart_nginx_php ; menu ;;
		    0) exit 0 ;;
		    *) _error "Wrong Choice !!"; menu;;
        esac
}



menu