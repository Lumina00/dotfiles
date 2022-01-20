#!/bin/sh

./packages.sh &
./setting.sh &

wait

echo "Complete"
