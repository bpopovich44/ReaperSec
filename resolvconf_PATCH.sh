#!/bin/sh

##########################
##
## README: find what is creating /run/resolvconf/interface/NetworkManager and replicate 
##
## When reboot, these files are deleted.  This script adds files and sym links needed for operation of vpn
##
###########################


mkdir /run/resolvconf/
>> /run/resolvconf/enable-updates
echo "nameserver 192.168.1.1" >> /run/resolvconf/resolv.conf
mkdir /run/resolvconf/interface
ln -s /run/NetworkManager/resolv.conf /run/resolvconf/interface/origional.resolvconf









