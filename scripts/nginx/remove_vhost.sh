#!/bin/bash

source $parent_path/utilities.sh

function ask_domain () {
    
    echo -ne "
    $(pRed 'WARNING: This will Delete the vHost file from sites-available & sites-enabled !!')
    "

    echo -ne "
    $(pBlue 'Enter the domain (FQDN) that you want to remove (eg. example.com, sub.example.com):  ')
    "
        read DOMAIN
    if [ "$DOMAIN" == "0" ]; then
            exit 1;
        fi

            echo -ne "
    $(pBlue 'Enter the domain (FQDN) again:  ')
    "
        read DOMAIN2
    
    if [[ "$DOMAIN" == "$DOMAIN2" ]]; then
    remove_domain
    else
        _error "Confirmation Failed, Try Again !!"
        ask_domain
    fi
}

function remove_domain() {

        if [[ -f "$vhosts_en_dir/$DOMAIN" ]]; then

        rm -f $vhosts_en_dir/$DOMAIN

        _success "=========================================="
        _success "$vhosts_en_dir/$DOMAIN Removed SUCCESSFULLY"
        _success "=========================================="
    else
        _error "=========================================="
        _error "$vhosts_en_dir/$DOMAIN Does Not Exists"
        _error "=========================================="
    fi
    
    if [[ -f "$vhosts_av_dir/$DOMAIN" ]]; then

        rm -f $vhosts_av_dir/$DOMAIN

        _success "=========================================="
        _success "$vhosts_av_dir/$DOMAIN Removed SUCCESSFULLY"
        _success "=========================================="
    else
        _error "=========================================="
        _error "$vhosts_av_dir/$DOMAIN Does Not Exists"
        _error "=========================================="
    fi



    _arrow "Restarting Nginx and PHP"

    _restart_nginx_php
}

_info "================================"

_arrow "Available vHosts"

    print_vHosts

ask_domain