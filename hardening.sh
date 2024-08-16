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
function fn_ssh {
    rm --force /etc/ssh/sshd_config
    cp  ${PWD}/sshd_config /etc/ssh/sshd_config
    printf "${GREEN}ssh config file has been copied ${NC}\n"
    sleep 1
    systemctl enable ssh
    systemctl restart ssh
    ssh_status=`systemctl status sshd | awk 'NR==2{ print $4 }' | tr --delete ";"`
    printf "ssh service status is ${GREEN}$ssh_status${NC}\n"
    sleep 3
}

function fn_custom_ssh_banner {
    # create a custom ssh banner
    printf "${PURPLE}config ssh banner ${NC} \n"
    apt install -y figlet > /dev/null 2>&1
    figlet drsrv > /etc/ssh/custom_banner
    printf "apt update & install has been done \n"
}

function fn_ufw {
    printf "${PURPLE}install & configure ufw ${NC} \n"
    apt install -y ufw > /dev/null 2>&1
    sed --in-place s/IPV6=yes/IPV6=no/ /etc/default/ufw
    ssh_pn=`cat /etc/ssh/sshd_config | grep "Port " | cut --delimiter=" " -f2`
    printf "new ssh port number is ${GREEN}$ssh_pn${NC}\n"
    sleep 3
    printf "${RED_BLINK}ENABLING UFW !!!${NC}\n"
    ufw allow $ssh_pn > /dev/null 2>&1
    ufw enable
    printf "${PURPLE}list of activated ports by UFW on your system${NC}\n"
    ufw status
    sleep 3
}

function fn_no {
    printf "${BLACK}HINT: ${NC}'ssh-copy-id -p <default-port-number | 22> -i ./id_rsa.pub ${user}@<your-server-addr>' \n"
    printf "${PURPLE}Go back and return after copy, I'm wating for you :) ${NC}\n"
    printf "${RED_BLINK}did you copy sshkey? ${NC}\n"
    read -p "[ yes | no ] or [ e ] to exit: " answer
}

function fn_else {
    read -p "usage: just [ yes | no ] or [ e ] to exit enter again: " answer
}

function fn_create_promot_new_user {
    printf "${GREEN}create a non-root user to increase your security!!! ${NC}\n"
    # delete duplicate user & create & promote new user
    read -p "please enter a user's name: " user
    id $user > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        printf "${RED}$user does exists ${NC}\n"
        userdel --remove $user > /dev/null 2>&1
        printf "${GREEN}$user was deleted ${NC}\n"
        useradd --create-home $user --shell /bin/bash
        mkdir --parents $user/.ssh
        rm --recursive --force ./$user
        printf "${GREEN}$user was created successfully${NC}\n"
    else
        useradd --create-home $user --shell /bin/bash
        mkdir --parents $user/.ssh
        rm --recursive --force ./$user
        printf "${GREEN}$user was created successfully${NC}\n"
        sleep 3
    fi
    
    # set a new password for user
    passwd $user > /dev/null
    while [ $? -ne 0 ];do
        printf "please enter the new user's password below \n"
        passwd $user > /dev/null
    done
    
    # add the new user to sudeor group
    usermod --append --groups sudo $user
}

function fn_lock_root {
    # lock root login
    read -p "would you like to disable root login? [ yes | no ]: " rl_answr
    if [ $rl_answr  = "yes" ]; then
        usermod --lock root
    fi
}

function fn_change_hostname {
    # change hostname
    printf "Your hostname is: ${GREEN}`hostname -A` ${NC}\n"
    read -p "would you like to change it [ yes | no ]: " hn_answr
    if [ $hn_answr  = "yes" ]; then
        read -p "Enter the new hostname: " new_host_name
        hostnamectl set-hostname $new_host_name
        printf "Your hostname is changed to ${GREEN}$new_host_name ${NC}\n"
    fi
}


#update apt repo
printf "${PURPLE}updating 'apt' repo please be patient... ${NC}\n"
apt update -y > /dev/null 2>&1

# run function create & promot new user
fn_create_promot_new_user


# change ssh default config [port, root login, restrict login with password]
printf "${RED}did you copy sshkey for new user!? ${NC}\n"
read -p "enter [ yes | no ] or [ e ] to exit: " answer
while [ true ]; do
    case $answer in
        yes)
            fn_change_hostname
            fn_ssh
            fn_custom_ssh_banner
            fn_lock_root
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
