#!/bin/sh
read -p "Enter SSH port: " port
read -p "Enter Private ip address: " private
read -p "Choose Desktop environment \n 1.kde 2.hyprland" de
./shell/package.sh $de
./shell/setting.sh $port $private $de

echo "Complete"
