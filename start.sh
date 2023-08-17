#!/bin/sh
read -p "Enter SSH port: " port
read -p "Enter Private ip address: " private
./shell/pacman.sh
./shell/rust.sh
./shell/setting.sh $port $private

echo "Complete"
