#!/bin/bash

GREEN='\033[0;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color


printf "${GREEN}create a non-root user to increase your security!!! ${NC}\n"

# delete duplicate user & create & promote new user
read -p "please enter a user's name: " user
id $user > /dev/null 2>&1
if [ $? -eq 0 ]; then
    printf "${RED}user [$user] is exists ${NC}\n"
    userdel -r $user
    useradd -m $user --shell /bin/bash
    mkdir -p $user/.ssh
    printf "${GREEN}user [$user] was deleted & created clearly ${NC}\n"
    sleep 2
else
    useradd -m $user --shell /bin/bash
    mkdir -p $user/.ssh
    printf "${GREEN}user [$user] was created ${NC}\n"
    sleep 2
fi
