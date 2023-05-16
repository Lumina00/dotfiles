#!/bin/sh

./shell/pacman.sh
./shell/rust.sh & ./shell/setting.sh
wait

echo "Complete"
