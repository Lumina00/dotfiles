#!/bin/sh 
sudo sed -i "37s/#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf
sudo pacman -S --needed --noconfirm reflector 
sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist
sudo pacman -S --noconfirm --needed rustup zsh refind bandwhich mpv lollypop firefox qbittorrent neovim flatpak docker \
  nomacs amd-ucode p7zip amdvlk btrfs-progs easytag yarn anthy lvm2 pipewire pipewire-pulse \
  gst-plugins-good qt5-imageformats mesa-vdpau vulkan-radeon libva-mesa-driver plasma-desktop powerdevil bluedevil plasma-pa plasma-nm spectacle kscreen\
  xdg-user-dirs ccls xclip kdeconnect konsole dolphin xorg-server 
./rust.sh
cargo install bottom du-dust paru cargo-update
./paru.sh
bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

exit
