#!/usr/bin/env sh

# Download setup and make executable
wget -N https://raw.githubusercontent.com/akroma-project/akroma-masternode-management/master/scripts/debian/setup.sh
chmod +x setup.sh

# create systemd with baneslayer
./setup.sh --systemd

# start and enable
sudo systemctl start akromanode
sudo systemctl enable akromanode


# utils
wget https://raw.githubusercontent.com/akroma-project/akroma-masternode-management/master/scripts/any/utils.sh
chmod +x utils.sh # makes script executable
./utils.sh --enodeId --nodePort --nodeIp

# update
sudo apt-get update
sudo apt-get upgrade -y

sudo reboot
