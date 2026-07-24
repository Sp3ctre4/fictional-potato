#!/bin/bash

echo "Replacing OpenCanary config files..."

sudo --validate

# get source and destination

ssh_config="$(pwd)/configs/ssh.py"
samba_config="$(pwd)/configs/samba.py"
llmnr_config="$(pwd)/configs/llmnr.py"
logger_config="$(pwd)/configs/logger.py"
portscan_config="$(pwd)/configs/portscan.py"
smb_config="$(pwd)/configs/smb.conf"
canary_config="$(pwd)/configs/opencanary.conf"

ssh_dst="$(find / -type f -name "ssh.py" 2>/dev/null | grep "opencanary")"
samba_dst="$(find / -type f -name "samba.py" 2>/dev/null | grep "opencanary")"
llmnr_dst="$(find / -type f -name "llmnr.py" 2>/dev/null | grep "opencanary")"
logger_dst="$(find / -type f -name "logger.py" 2>/dev/null | grep "opencanary")"
portscan_dst="$(find / -type f -name "portscan.py" 2>/dev/null | grep "opencanary")"
smb_dst="/etc/samba/smb.conf"
canary_dst="/etc/opencanaryd/opencanary.conf"

webhook="$(cat ~/link.txt)"

# replace config files

echo "[*] $ssh_config -> $ssh_dst"
sudo cp $ssh_config $ssh_dst

echo "[*] $samba_config -> $samba_dst"
sudo cp $samba_config $samba_dst

echo "[*] $llmnr_config -> $llmnr_dst"
sudo cp $llmnr_config $llmnr_dst

echo "[*] $logger_config -> $logger_dst"
sudo cp $logger_config $logger_dst

echo "[*] $portscan_config -> $portscan_dst"
sudo cp $portscan_config $portscan_dst

echo "[*] $smb_config !-> $smb_dst"
sudo cp $smb_config $smb_dst

echo "[*] $canary_config !-> $canary_dst"
sudo cp $canary_config $canary_dst

#echo "[*] Inserting webhook link"
sudo sed -i "s|09333-link-09333|$webhook|g" $canary_dst
# do again to replace the & symbols
sudo sed -i 's/09333-link-09333/\&/g' $canary_dst

#echo "[*] Turning off python depreciation warnings?"
# TODO

echo "[+] Complete."
