#!/bin/sh 
sudo pacman -S reflector 
sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist
sudo pacman -S rustup ruby zsh uim refind bandwhich mpv lollypop firefox qbittorrent neovim flatpak docker nomacs amd-ucode p7zip amd-vlk btrfs-progs easytag git yarn 
rustup install stable


cargo install ytop exa dust rua cargo-update

rua install dislocker dcron 

