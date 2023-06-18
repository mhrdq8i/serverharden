#!/bin/bash

# define color's variables
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

# create and promote new user
read -p "please enter a user's name: " user
useradd -m $user --shell /bin/bash
mkdir -p $user/.ssh

# set new password for new user
passwd $user
while [ $? -ne 0 ];do
    printf "please enter the new user's password below \n"
    passwd $user
done

# add new user to sudeor group
usermod -aG sudo $user

# lock root login
usermod --lock root

# create custom ssh banner
apt update -y && apt install -y figlet
figlet drsrv > /etc/ssh/custom_banner

# change ssh defult config [port, root login, restrict login with password]
printf "${RED}did you copy sshkey for new user!? ${NC}\n"
read -p "yes or no: " answer

while [ $answer != "" ]; do
    if [ $answer = "yes" ]; then
        rm -f /etc/ssh/sshd_config
        cp  ${PWD}/sshd_config /etc/ssh/sshd_config
        sleep 1
        printf "${GREEN}config file has been copied ${NC}\n"
        systemctl restart ssh
        printf "${PURPLE}ssh service status${NC}\n"
        systemctl status ssh
        printf "${PURPLE}ssh port(s) status${NC}\n"
        ss -tlpn | grep sshd
        exit 0
    elif [ $answer = "no" ]; then
        printf "${PURPLE}go back and return after copy, I'm wating for you :) ${NC}\n"
        printf "${BLACK}HINT: ${NC}'ssh-copy-id -p 8452 -i ./id_rsa.pub ${user}@<your-server-addr>' \n"
        sleep 10
        printf "${RED_BLINK}did you copy sshkey? ${NC}\n"
        read -p "yes or no: " answer
        continue
    else
        read -p "usage: just 'yes' or 'no' enter again: " answer
        continue
    fi
done
