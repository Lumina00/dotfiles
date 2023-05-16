#!/bin/sh
#Global theme = Breeze Dark
#Plasma style = Breeze Dark
#Window style = Diamond 
#Colors       = Breeze High Contrast
#Icons        = Candy-icons

git clone https://github.com/EliverLara/candy-icons ~/.local/share/icons/candy-icons
lookandfeeltool -a org.kde.breezedark.desktop
#kwriteconfig --file kdeglobals --group RecentDocuments --key UseRecent false
kwriteconfig5 --file kdeglobals --group RecentDocuments --key UseRecent false
kwriteconfig5 --file kwinrc --group Compositing --key 'AnimationSpeed' '0'
kwriteconfig5 --file kwinrc --group Plugins --key 'slidingpopupsEnabled' --type 'bool' 'false'
kwriteconfig5 --file kwalletrc --group 'Wallet' --key 'Enabled' 'false'
kwriteconfig5 --file kwalletrc --group 'Wallet' --key 'First Use' 'false'
kwriteconfig5 --file kcmshell5rc --group 'Basic Settings' --key 'Indexing-Enabled' 'false'
kwriteconfig5 --file baloofilerc --group 'Basic Settings' --key 'Indexing-Enabled' 'false'
kwriteconfig5 --file kscreenlockerrc --group 'Greeter' --group 'LnF' --group 'General' --key 'showMediaControls' --type 'bool' 'false'
kwriteconfig5 --file ksmserverrc --group 'General' --key 'loginMode' 'default'
kwriteconfig5 --file klipperrc --group 'General' --key 'PreventEmptyClipboard' --type bool 'false'
kwriteconfig5 --file klipperrc --group 'General' --key 'KeepClipboardContents' --type bool 'false'
kwriteconfig5 --file kdeglobals --group 'Icons' --key 'Theme' 'candy-icons'
kwriteconfig5 --file kwinrc --group 'org.kde.kdecoration2' --key 'library' 'org.kde.kwin.aurorae'
kwriteconfig5 --file kwinrc --group 'org.kde.kdecoration2' --key 'theme' '__aurorae__svg__Diamond'

rm -rf ~/.local/share/Trash
ln -s /tmp ~/.local/share/Trash

exit
