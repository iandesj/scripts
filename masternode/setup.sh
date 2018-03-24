#!/usr/bin/env sh

isValidUsername() {
  if echo $1 | grep -Eq '^[[:lower:]_][[:lower:][:digit:]_-]{2,15}$'; then
    return 1
  fi
  return 0 
}

# Logic to handle arguments for optionally creating systemd service
SYSTEMD=false
RPCPORT=8545
SUCCESS=0

for i in "$@"
do
case $i in
    -s|--systemd)
    SYSTEMD=true
    shift # past argument=value
    ;;
    -p=*|--rpcport=*)
    RPCPORT="${i#*=}"
    if ! $(echo $RPCPORT | grep -Eq '^[0-9]+$') ; then
      echo "error: Provided RPC Port is not a number" >&2; exit 1
    fi
    echo '-p or --rpcport option will only be used when -s or --systemd is provided'
    shift # past argument=value
    ;;
    -h|--help)
    echo '-s=true or --systemd=true will create a systemd service for starting and stopping the masternode instance'
    echo '-p=port# or --rpcport=port# option to set specific port# for geth rpc to listen on (option will only be used if systemd service is created)'
    echo '-u=user# or --user=user# option to set/create user to run geth'
    exit 1
    ;;
    -u=*|--user=*)
    USERNAME="${i#*=}"
    CREATE_USER=true
    isValidUsername $USERNAME
    if [ "$?" -eq 0 ] ; then
      echo 'Please provide valid username.'
      exit 2
    fi
    shift # past argument with no value
    ;;
    -u|--user) #user default username
    CREATE_USER=true
    USERNAME="akroma"
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

echo '=========================='
echo 'Installing dependencies...'
echo '=========================='
# Check release types to install dependencies appropriately
if [ -f /etc/redhat-release ]; then
  sudo yum install curl unzip wget -y
fi

if [ "$(grep -Ei 'debian|buntu' /etc/*release)" ]; then
  sudo apt-get update && sudo apt-get install curl unzip wget -y
fi

echo '=========================='
echo 'Installing akroma node...'
echo '=========================='
# Download release zip for node
if [ $(uname -m) = 'x86_64' ]; then
  wget -q --show-progress https://github.com/akroma-project/akroma/releases/download/0.0.8/release.linux-amd64.0.0.8.zip
else
  wget -q --show-progress https://github.com/akroma-project/akroma/releases/download/0.0.8/release.linux-386.0.0.8.zip
fi

# Unzip release zip file
unzip release.linux-*0.0.8.zip

# Make `geth` executable
chmod +x geth

# Cleanup
rm release.linux-*0.0.8.zip

if [ "$CREATE_USER" = true ] ; then
  echo '=========================='
  echo "User configuration."
  echo '=========================='

  grep -q "$username" /etc/passwd
  if [ $? -ne $SUCCESS ] ; then 
     echo "Creating user $USERNAME." 
     sudo adduser $USERNAME --gecos "" --disabled-password
  else 
     echo "User $USERNAME found."
  fi
fi


if [ "$SYSTEMD" = true ]; then
    if [ -f /etc/systemd/system/masternode.service ]; then
        sudo systemctl stop masternode && sudo systemctl disable masternode && sudo rm /etc/systemd/system/masternode.service
    fi
echo '=========================='
echo 'Condiguring service...'
echo '=========================='

cat > /tmp/masternode.service << EOL
[Unit]
Description=Akroma Client -- masternode service
After=network.target

[Service]
EOL

if [ "$CREATE_USER" = true ] ; then
  cat >> /tmp/masternode.service << EOL
User=${USERNAME}
Group=${USERNAME}
EOL
fi

cat >> /tmp/masternode.service << EOL
Type=simple
Restart=always
RestartSec=30s
ExecStart=/usr/sbin/geth --masternode --rpcport ${RPCPORT}

[Install]
WantedBy=default.target
EOL
        sudo mv /tmp/masternode.service /etc/systemd/system
        sudo cp geth /usr/sbin/
        systemctl status masternode --no-pager --full
else
  echo 'systemd service will not be created.'
fi

echo 'Done.'
