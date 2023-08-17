#!/bin/sh
shell=$(pwd)
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
cd ../dotfiles/
dot=$(pwd)
cp .tmux.conf ~/    
cp -r .config ~/        
\cp -f .zshrc ~    
\cp -f .gdbinit ~    
echo "define ssh = $1" | cat - nftables.conf > nftables.conf
echo "define private = $2" | cat - nftables.conf > nftables.conf
sudo \cp -f nftables.conf /etc/nftables.conf
sudo cp nft-blackhole.conf /etc/nft-blackhole.conf
sudo cp linux-lts.preset /etc/mkinitcpio.d/linux-lts.preset
sudo \cp -f cmdline /etc/kernel/cmdline 
sudo cp mkinitcpio.conf /etc/mkinitcpio.conf
sudo \cp -f config.ini /etc/ly/
./$shell/privacy.sh
./$shell/firefox.sh
xdg-user-dirs-update    
sudo systemctl mask NetworkManager-wait-online.service   
sudo systemctl enable --now NetworkManager nftables
sudo sed -i "23s/$/ --graceful/" /usr/lib/systemd/system/systemd-pcrmachine.service
./$shell/kdesettings.sh 
git clone https://github.com/lukechilds/refind-ambience /tmp/ambience/
sudo cp -r /tmp/ambience /boot/efi/EFI/refind/themes/ambience
exit
