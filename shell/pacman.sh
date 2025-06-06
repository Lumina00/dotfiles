#!/bin/sh 
sudo sed -i "37s/#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf
sudo pacman -S --needed --noconfirm reflector 
sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist
sudo pacman -S --noconfirm --needed rustup cmake docker nodejs \
  zsh refind mpv gst-plugins-{base,good,ugly,bad} gst-libav firefox-developer-{edition,edition-i18n-ja} qbittorrent neovim xclip wl-clipboard rsync eza bat\
  flatpak amd-ucode p7zip btrfs-progs pipewire pipewire-pulse wireplumber amdvlk vulkan-radeon xf86-video-amdgpu xdg-user-dirs nftables noto-fonts-cjk iwd ly bluez-{base,obex} tinyxxd \

if [ "$1" == "1"]; then 
	pacman -S --noconfirm --needed plasma-desktop powerdevil bluedevil plasma-pa plasma-nm spectacle kgamma kscreen qt6-imageformats kdeconnect konsole kid3 dolphin gwenview xorg-{server,xauth,xinit,xrandr} 
elif [ "$1" == "2"]; then
	pacman -S --noconfirm --need hyprland hypridle hyprpolkitagent ruby jq bluetoothctl grim slurp mpd brightlessctl dunst swww
fi 
exit
