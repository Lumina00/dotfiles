#!/bin/sh 
sudo pacman -S --noconfirm reflector 
sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist
sudo pacman -Sy --noconfirm --needed rustup zsh 
sudo nohup pacman -Sy --noconfirm --needed ruby uim refind bandwhich mpv lollypop firefox qbittorrent neovim flatpak docker nomacs amd-ucode p7zip amdvlk btrfs-progs easytag yarn anthy lvm2 pipewire pipewire-pulse gst-plugins-good qt5-imageformats 1> /dev/null 2> &1 &
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
mkdir ~/.zinit 
git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
cp .tmux.conf ~/
cp -r .config ~/
cp -b .zshrc ~/
cp -b .gdbinit ~/
sudo cp -b config.ini /etc/ly/
sudo cp nftables.conf /etc/nftables.conf
nohup rustup install stable 1 > /dev/null 2 > &1 & 
cargo install rua
nohup cargo install bottom exa dust cargo-update 1 > /dev/null 2 >&1 &
rua install dislocker dcron aic94xx-firmware xxd-standalone
