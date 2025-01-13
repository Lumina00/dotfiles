#!/bin/sh

sudo cp -r $1/network/* /etc/NetworkManager/conf.d/
echo -e "#!/usr/bin/nft -f\ndefine ssh = $2\ndefine private = $3" | cat - nftables.conf > nftables.conf.new
sudo \cp -f nftables.conf.new /etc/nftables.conf
sudo chmod 600 /etc/nftables.conf
sudo cp nft-blackhole.conf /etc/nft-blackhole.conf
echo "IPQoS=none" | sudo tee -a /etc/ssh/sshd_config.d/98-IPQoS.conf
sudo systemctl mask NetworkManager-wait-online.service   
sudo systemctl enable --now NetworkManager nftables

exit
