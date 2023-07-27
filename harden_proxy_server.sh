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

# define functions
function fn_yes {
    rm -f /etc/ssh/sshd_config
    cp  ${PWD}/sshd_config /etc/ssh/sshd_config
    sleep 1
    printf "${GREEN}config file has been copied ${NC}\n"
    systemctl restart ssh
    printf "${PURPLE}ssh service status${NC}\n"
    systemctl status ssh
    printf "${PURPLE}ssh port(s) status${NC}\n"
    ss -tlpn | grep sshd
}

function fn_ufw {
    sed -i s/IPV6=yes/IPV6=no/ /etc/default/ufw
    ssh_pn=`cat /etc/ssh/sshd_config | grep "Port " | cut -d" " -f2`
    printf "ssh port number is ${PURPLE}$ssh_pn${NC}\n"
    sleep 3
    ufw allow $ssh_pn
    printf "${RED_BLINK}ENABLING UFW !!!${NC}\n"
    sleep 3
    ufw enable
    sleep 3
    ufw status
}

function fn_no {
    printf "${PURPLE}Go back and return after copy, I'm wating for you :) ${NC}\n"
    printf "${BLACK}HINT: ${NC}'ssh-copy-id -p $ssh_pn -i ./id_rsa.pub ${user}@<your-server-addr>' \n"
    sleep 10
    printf "${RED_BLINK}did you copy sshkey? ${NC}\n"
    read -p "[ yes | no ] or 'e' to exit: " answer
}

function fn_else {
    read -p "usage: just [ yes | no ] or 'e' to exit enter again: " answer
}

# check user is root or sudoer or not
if [ "$EUID" -ne 0 ]; then
    printf "${YELLOW}please run as root's privilege ${NC}\n"
    exit 1
fi

# create and promote new user
read -p "please enter a user's name: " user
useradd -m $user --shell /bin/bash
mkdir -p $user/.ssh

# set a new password for user
passwd $user
while [ $? -ne 0 ];do
    printf "please enter the new user's password below \n"
    passwd $user
done

# add the new user to sudeor group
usermod -aG sudo $user

# lock root login
usermod --lock root

# create a custom ssh banner
apt update -y && apt install -y figlet
figlet drsrv > /etc/ssh/custom_banner

# change ssh default config [port, root login, restrict login with password]
printf "${RED}did you copy sshkey for new user!? ${NC}\n"
read -p "enter [ yes | no ] or [e] to exit: " answer

while [ true ]; do
    case $answer in
        yes)
            fn_yes
            fn_ufw
            cat /etc/ssh/custom_banner
            exit 0
        ;;
        no)
            fn_no
            continue
        ;;
        e)
            printf "${GREEN}BYE! ${NC}\n"
            exit 0
        ;;
        *)
            fn_else
            continue
            
        ;;
    esac
done
