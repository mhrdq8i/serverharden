#!/bin/bash

# define color variables
BLACK='\033[1;30m'
BLUE='\033[0;34m'
RED='\033[1;31m'
RED_BLINK='\033[5;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color


# check user is root or sudoer or not
if [ "$EUID" -ne 0 ]; then
    printf "${YELLOW}please run as root's privilege ${NC}\n"
    exit 1
fi


function fn_int_server {
    apt update -y
    apt install -y vnstat haproxy vim-haproxy
    vim-addons install haproxy
    cp --force ${PWD}/haproxy.cfg /etc/haproxy/haproxy.cfg
    printf "${GREEN}haproxy config file has been copied${NC}\n"
    printf "${PURPLE}now you can enter your custom config into the '/etc/haproxy/haproxy.cfg' file${NC}\n"
}

function fn_ext_server {
    bash <(curl -Ls https://raw.githubusercontent.com/mehrdad-drpc/x-ui/main/install.sh)
}

function fn_invalid_input {
    printf "${RED}invalid input${NC}\n"
    read -p "usage: just enter [ int | ext ] and try again: " srv_loc_answr
}

read -p "which server are you on [ int | ext ]: " srv_loc_answr
while [ true ]; do
    case $srv_loc_answr in
        int)
            fn_int_server
            exit 0
        ;;
        ext)
            fn_ext_server
            exit 0
        ;;
        *)
            fn_invalid_input
            continue
        ;;
    esac
done