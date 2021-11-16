#!/bin/sh 
sudo pacman -S --needed --noconfirm reflector 
sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist
sudo pacman -S --noconfirm --needed rustup ruby zsh refind bandwhich mpv lollypop firefox qbittorrent neovim flatpak docker nomacs amd-ucode p7zip amdvlk btrfs-progs easytag yarn anthy lvm2 pipewire pipewire-pulse gst-plugins-good qt5-imageformats mesa-vdpau vulkan-radeon plasma-destkop powerdevil bluedevil plasma-pa plasma-nm spectacle
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
mkdir ~/.zinit 
git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
cp .tmux.conf ~/
cp -r .config ~/
\cp -f .zshrc ~
\cp -f .gdbinit ~
sudo cp nftables.conf /etc/nftables.conf
./rust.sh
cargo install bottom du-dust paru cargo-update
./paru.sh
sudo \cp -f config.ini /etc/ly/
