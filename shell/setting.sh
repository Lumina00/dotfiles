#!/bin/sh
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir ~/.zinit     
git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin    
cd ../settings
cp .tmux.conf ~/    
cp -r .config ~/        
\cp -f .zshrc ~    
\cp -f .gdbinit ~    
sudo cp nftables.conf /etc/nftables.conf    
sudo cp ./linux-lts.preset /etc/mkinitcpio.d/linux-lts.preset    
sudo \cp -f config.ini /etc/ly/    
../shell/privacy.sh
xdg-user-dirs-update    
sudo systemctl mask NetworkManager-wait-online.service   
sudo systemctl enable NetworkManager
sudo systemctl enable nftables
exit
