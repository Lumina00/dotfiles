#!/bin/sh 
sudo pacman -S --no-confirm reflector 
sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist
sudo pacman -Sy --no-confirm rustup ruby zsh uim refind bandwhich mpv lollypop firefox qbittorrent neovim flatpak docker nomacs amd-ucode p7zip amd-vlk btrfs-progs easytag yarn anthy lvm2
rustup install stable
cargo install bottom exa dust rua cargo-update starship

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
mkdir ~/.zinit 
git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
cp -r .config ~/
cp -b .zshrc ~/
sudo cp -i nftables.conf /etc/nftables.conf

rua install dislocker dcron aic94xx-firmware xxd-standalone
