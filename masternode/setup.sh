#!/bin/bash

# Logic to handle arguments for optionally creating systemd service
SYSTEMD=false
RPCPORT=8545
for i in "$@"
do
case $i in
    -s|--systemd)
    SYSTEMD=true
    shift # past argument=value
    ;;
    -p=*|--rpcport=*)
    RPCPORT="${i#*=}"
    re='^[0-9]+$'
    if ! [[ $RPCPORT =~ $re ]] ; then
      echo "error: Provided RPC Port is not a number" >&2; exit 1
    fi
    echo '-p or --rpcport option will only be used when -s or --systemd is provided'
    shift # past argument=value
    ;;
    -h|--help)
    echo '-s=true or --systemd=true will create a systemd service for starting and stopping the masternode instance'
    echo '-p=port# or --rpcport=port# option to set specific port# for geth rpc to listen on (option will only be used if systemd service is created)'
    exit 1
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

# Check release types to install dependencies appropriately
if [ -f /etc/redhat-release ]; then
  sudo yum unzip wget
fi

if [ -f /etc/lsb-release ]; then
  sudo apt-get install unzip wget
fi

# Download release zip for node
if [ $(uname -m) == 'x86_64' ]; then
  wget https://github.com/akroma-project/akroma/releases/download/0.0.8/release.linux-amd64.0.0.8.zip
else
  wget https://github.com/akroma-project/akroma/releases/download/0.0.8/release.linux-386.0.0.8.zip
fi

# Unzip release zip file
unzip release.linux-*0.0.8.zip

# Make `geth` executable
chmod +x geth

# Cleanup
rm release.linux-*0.0.8.zip

if [[ "$SYSTEMD" = true ]]; then
cat > /tmp/masternode.service << EOL
[Unit]
Description=Akroma Client -- masternode service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=30s
ExecStart=/usr/sbin/geth --masternode --rpcport ${RPCPORT}

[Install]
WantedBy=default.target
EOL
sudo mv /tmp/masternode.service /etc/systemd/system
sudo mv geth /usr/sbin/
systemctl status masternode
else
  echo 'systemd service will not be created.'
fi

echo 'Done.'
