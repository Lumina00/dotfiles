#!/bin/sh

./shell/packages.sh &
./shell/setting.sh &
wait

echo "Complete"
