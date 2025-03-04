#!/bin/sh
shell=$(pwd)/shell
dot=$(pwd)/dotfiles
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
if [ $3 = "1" ]; then 
	$shell/kdesettings.sh 
fi
cd $dot
if [ $3 = "2" ];then 
	mkdir temp
	git clone https://gitlab.com/lumina0/dotfiles -b hypr temp 
	mv .config/* .config 
fi
cp .tmux.conf ~/    
cp -r .config ~/        
\cp -f .zshrc ~    
\cp -f .gdbinit ~    
sudo cp linux-lts.preset /etc/mkinitcpio.d/linux-lts.preset
sudo \cp -f cmdline /etc/kernel/cmdline 
sudo cp mkinitcpio.conf /etc/mkinitcpio.conf
cat config.ini | sudo tee /etc/ly/config.ini
cd $shell
$shell/network.sh $dot $1 $2 
$shell/firefox.sh $dot

xdg-user-dirs-update    
sudo sed -i "23s/$/ --graceful/" /usr/lib/systemd/system/systemd-pcrmachine.service
git clone https://github.com/lukechilds/refind-ambience /tmp/ambience/
sudo cp -r /tmp/ambience /boot/efi/EFI/refind/themes/ambience
exit
