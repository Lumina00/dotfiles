#!/bin/bash 

tmux new-session -d -s "AppImage" "
curl https://imagemagick.org/archive/binaries/magick -o ~/.local/bin/magick

curl -s https://api.github.com/repos/ivan-hc/Steam-appimage/releases/latest | awk -F '\"' '/browser_download_url/ && /AppImage/ {print \$4}' | xargs curl -L -o ~/.local/bin/steam-bin

curl -s https://api.github.com/repos/mmtrt/WINE_Appimage/releases/tags/continuous-stable | awk -F '\"' '/browser_download_url/ && /AppImage/ {print \$4}'xargs curl -L -o ~/.local/bin/wine 

curl -s https://api.github.com/repos/vicinaehq/vicinae/releases/latest | awk -F '\"' '/browser_download_url/ && /AppImage/ {print \$4}' | xargs curl -L -o ~/.local/bin/vicinae 

chmod +x ~/.local/bin/* 
exit
"
exit

