#!/bin/bash
ls -al $1
WorkingDiretory=$(pwd)
cd ~/.librewolf
if [[ $(grep '\[Profile[^0]\]' profiles.ini) ]]; then 
	PROFPATH=$(grep -E '^\[Profile|^Path|^Default' profiles.ini | grep -1 '^Default=1' | grep '^Path' | cut -c6-)
else PROFPATH=$(grep 'Path=' profiles.ini | sed 's/^Path=//')
fi
cd $WorkingDiretory
echo 'user_pref("browser.cache.disk.parent_diretory","/run/user/'$(id -u)'/firefox")' >> $1/.librewolf/user.js
cat $1/.librewolf/user.js >> ~/.librewolf/"$PROFPATH"/user.js

exit
