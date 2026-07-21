#!/bin/bash

echo "Replacing OpenCanary config files..."

sudo --validate

samba_config="$(pwd)/configs/samba.py"
llmnr_config="$(pwd)/configs/llmnr.py"
logger_config="$(pwd)/configs/logger.py"
smb_config="$(pwd)/configs/smb.conf"
canary_config="$(pwd)/configs/opencanary.conf"
# add portscan
# add ssh

samba_dst="$(find / -type f -name "samba.py" 2>/dev/null | grep "opencanary")"
llmnr_dst="$(find / -type f -name "llmnr.py" 2>/dev/null | grep "opencanary")"
logger_dst="$(find / -type f -name "logger.py" 2>/dev/null | grep "opencanary")"
smb_dst="/etc/samba/smb.conf"
canary_dst="/etc/opencanaryd/opencanary.conf"

webhook="$(cat ~/link.txt)"

# Replace config files

echo "[*] $samba_config -> $samba_dst"
sudo cp $samba_config $samba_dst

echo "[*] $llmnr_config -> $llmnr_dst"
sudo cp $llmnr_config $llmnr_dst

echo "[*] $logger_config -> $logger_dst"
sudo cp $logger_config $logger_dst

echo "[*] $smb_config -> $smb_dst"
sudo cp $smb_config $smb_dst

echo "[*] $canary_config -> $canary_dst"
sudo cp $canary_config $canary_dst

echo "[*] Inserting webhook link"
sudo sed -i "s|09333-link-09333|$webhook|g" $canary_dst
# do again to replace the & symbols
sudo sed -i 's/09333-link-09333/\&/g' $canary_dst

echo "[+] Complete."