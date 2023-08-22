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

# define functions
function fn_yes {
    rm --force /etc/ssh/sshd_config
    cp  ${PWD}/sshd_config /etc/ssh/sshd_config
    printf "${GREEN}config file has been copied ${NC}\n"
    sleep 1
    systemctl restart ssh
    printf "${PURPLE}ssh service status${NC}\t"
    systemctl status sshd | awk 'NR==2{ print $4 }' | tr --delete ";"
    printf "${PURPLE}ssh port(s) status${NC}\n"
    ss -tulpn | grep ssh | head --lines 1
}

function fn_ufw {
    sed --in-place s/IPV6=yes/IPV6=no/ /etc/default/ufw
    ssh_pn=`cat /etc/ssh/sshd_config | grep "Port " | cut --delimiter=" " -f2`
    printf "ssh port number is ${PURPLE}$ssh_pn${NC}\n"
    sleep 3
    ufw allow $ssh_pn
    printf "${RED_BLINK}ENABLING UFW !!!${NC}\n"
    ufw enable
    sleep 3
    ufw status
}

function fn_no {
    printf "${BLACK}HINT: ${NC}'ssh-copy-id -p $ssh_pn -i ./id_rsa.pub ${user}@<your-server-addr>' \n"
    printf "${PURPLE}Go back and return after copy, I'm wating for you :) ${NC}\n"
    printf "${RED_BLINK}did you copy sshkey? ${NC}\n"
    read -p "[ yes | no ] or 'e' to exit: " answer
}

function fn_else {
    rm --recursive --force ./$user
    read -p "usage: just [ yes | no ] or 'e' to exit enter again: " answer
}

function fn_create_promot_new_user {
    printf "${GREEN}create a non-root user to increase your security!!! ${NC}\n"
    # delete duplicate user & create & promote new user
    read -p "please enter a user's name: " user
    id $user > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        printf "${RED}user [$user] does exists ${NC}\n"
        userdel --remove $user
        useradd --create-home $user --shell /bin/bash
        mkdir --parents $user/.ssh
        rm --recursive --force ./$user
        printf "${GREEN}user [$user] was deleted & created clearly ${NC}\n"
        sleep 3
    else
        useradd --create-home $user --shell /bin/bash
        mkdir --parents $user/.ssh
        rm -rf ./$user
        printf "${GREEN}user [$user] was created ${NC}\n"
        sleep 3
    fi
    
    # set a new password for user
    passwd $user
    while [ $? -ne 0 ];do
        printf "please enter the new user's password below \n"
        passwd $user
    done
    
    # add the new user to sudeor group
    usermod --append --groups sudo $user
    
}

# create a custom ssh banner
printf "${PURPLE}running some background tasks, please be patient ${NC} \n"
apt update -y > /dev/null 2>&1
apt install -y figlet ufw > /dev/null 2>&1
figlet drsrv > /etc/ssh/custom_banner
printf "${YELLOW}ssh banner has been configured ${NC} \n"
printf "${YELLOW}apt update & install has been done ${NC} \n"

# run function create & promot new user
fn_create_promot_new_user

# lock root login
read -p "would you like to disable root login? [ yes | no ]: " rl_answr
if [ $rl_answr  = "yes" ]; then
    usermod --lock root
fi


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
            userdel --remove $user
            printf "${RED}The user $user has been removed${NC}\n"
            printf "${GREEN}BYE! ${NC}\n"
            exit 0
        ;;
        *)
            fn_else
            continue
            
        ;;
    esac
done
