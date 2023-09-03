#!/bin/sh 
sudo sed -i "37s/#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf
sudo pacman -S --needed --noconfirm reflector 
sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist
sudo pacman -S --noconfirm --needed rustup cmake docker nodejs \
  zsh refind bandwhich mpv lollypop gst-plugins-good easytag firefox-developer-{edition,edition-i18n-ja} qbittorrent neovim xclip wl-clipboard rsync\
  flatpak amd-ucode p7zip btrfs-progs pipewire pipewire-pulse wireplumber amdvlk mesa-vdpau vulkan-radeon libva-mesa-driver xorg-{server,xauth,xinit} xf86-video-amdgpu xdg-user-dirs nftables noto-fonts-cjk iwd\
  plasma-desktop powerdevil bluedevil plasma-pa plasma-nm spectacle kgamma5 kscreen qt5-imageformats kdeconnect konsole dolphin gwenview
sudo pacman -Rdd wpa_supplicant
exit
