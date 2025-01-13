#!/bin/sh
shell=$(pwd)/shell
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
dot=$(pwd)/dotfiles
cd dotfiles/
cp .tmux.conf ~/    
cp -r .config ~/        
\cp -f .zshrc ~    
\cp -f .gdbinit ~    
sudo cp linux-lts.preset /etc/mkinitcpio.d/linux-lts.preset
sudo \cp -f cmdline /etc/kernel/cmdline 
sudo cp mkinitcpio.conf /etc/mkinitcpio.conf
sudo \cp -f config.ini /etc/ly/
cd $shell
$shell/network.sh $dot $1 $2 
$shell/firefox.sh $dot
if [ $3 = "1" ]; then 
	$shell/kdesettings.sh 
fi

xdg-user-dirs-update    
sudo sed -i "23s/$/ --graceful/" /usr/lib/systemd/system/systemd-pcrmachine.service
git clone https://github.com/lukechilds/refind-ambience /tmp/ambience/
sudo cp -r /tmp/ambience /boot/efi/EFI/refind/themes/ambience
exit
