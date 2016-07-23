#!/bin/bash
# Version: 2.0.0
# Author: weiyixi
# Date: 2015/7/5
# Description: LampDevelopEnvironment Install Script
# Linux-CentOS 6.0
# Apache-2.2.19
# MySQL-5.5.17
# PHP-5.3.6

dir=$(cd `dirname $0`; pwd)

if [ "$UID" -ne 0 ]
then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi
clear
echo "
           Please Select Install
   +-----------------------------------+
   |  Linux + Apache + MySql + PHP5.3  |
   |                                   |
   |		  Sure?                |
   |                                   |
   |          YES:1    NO:0            |
   |                                   |
   |      don't install is now         |
   |  	                               |
   +-----------------------------------+
"
sleep 0.1
read -p "Please Input 1 or 0: " Select_Id
if [ $Select_Id == 1 ]; then
    bash $dir/tools/lamp_install.sh
elif [ $Select_Id == 0 ]; then
    echo "Exit Now..."
    exit 1
else
    echo "Select Error！ exit..."
    exit 1
fi