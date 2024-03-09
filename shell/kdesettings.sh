#!/bin/sh
#Global theme = Breeze Dark
#Plasma style = Breeze Dark
#Window style = Diamond 
#Colors       = Breeze High Contrast
#Icons        = Candy-icons

git clone https://github.com/EliverLara/candy-icons ~/.local/share/icons/candy-icons
lookandfeeltool -a org.kde.breezedark.desktop
if command -v kwriteconfig6 & > /dev/null ; then
	kwriteconfig --file kdeglobals --group RecentDocuments --key UseRecent false
fi
kwriteconfig6 --file kdeglobals --group RecentDocuments --key UseRecent false
kwriteconfig6 --file kdeglobals --group 'Icons' --key 'Theme' 'candy-icons'

kwriteconfig6 --file kwinrc --group Compositing --key 'AnimationSpeed' '0'
kwriteconfig6 --file kwinrc --group Plugins --key 'slidingpopupsEnabled' --type 'bool' 'false'
kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'library' 'org.kde.kwin.aurorae'
kwriteconfig6 --file kwinrc --group 'org.kde.kdecoration2' --key 'theme' '__aurorae__svg__Diamond'

kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'Enabled' 'false'
kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'First Use' 'false'

kwriteconfig6 --file kcmshell5rc --group 'Basic Settings' --key 'Indexing-Enabled' 'false'

kwriteconfig6 --file baloofilerc --group 'Basic Settings' --key 'Indexing-Enabled' 'false'

kwriteconfig6 --file kscreenlockerrc --group 'Greeter' --group 'LnF' --group 'General' --key 'showMediaControls' --type 'bool' 'false'

kwriteconfig6 --file ksmserverrc --group 'General' --key 'loginMode' 'default'

kwriteconfig6 --file klipperrc --group 'General' --key 'PreventEmptyClipboard' --type bool 'false'
kwriteconfig6 --file klipperrc --group 'General' --key 'KeepClipboardContents' --type bool 'false'

kwriteconfig6 --file plasmashellrc --group 'Action_0' --key 'Automatic' --type bool 'false'
kwriteconfig6 --file plasmashellrc --group 'Action_0' --key 'Number of commands' '1'
kwriteconfig6 --file plasmashellrc --group 'Action_0' --key 'Regexp' '^http.+(youtu|twitch)'
kwriteconfig6 --file plasmashellrc --group 'Action_0' --key 'Description' ''

kwriteconfig6 --file plasmashellrc --group 'Action_0/Command_0]' --key 'Commandline[$e]' 'mpv %s'
kwriteconfig6 --file plasmashellrc --group 'Action_0/Command_0]' --key 'Description' 'mpv'
kwriteconfig6 --file plasmashellrc --group 'Action_0/Command_0]' --key 'Enabled' --type bool 'true'
kwriteconfig6 --file plasmashellrc --group 'Action_0/Command_0]' --key 'Icon' 'mpv'
kwriteconfig6 --file plasmashellrc --group 'Action_0/Command_0]' --key 'Output' '0'

rm -rf ~/.local/share/Trash
ln -s /tmp ~/.local/share/Trash

exit
