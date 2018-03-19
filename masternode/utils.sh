#!/usr/bin/env sh

SYSTEMD_INUSE=0

if systemctl is-active --quiet masternode; then
  SYSTEMD_INUSE=1
fi

# Logic to handle arguments for optionally creating systemd service
for i in "$@"
do
case $i in
    -e|--enodeId)
    if [ $SYSTEMD_INUSE -eq 1 ]; then
      echo 'Enode Id:' $(journalctl -u masternode.service | grep 'UDP listener up' | awk '{print $11}' | grep -o -P '(?<=node://).*(?=@)' | tail -1)
    else
      echo 'Enode Id:' $(echo "$(tac ./geth.out)" | grep 'UDP listener up' | awk '{print $6}' | grep -o -P '(?<=node://).*(?=@)' | tail -1)
    fi
    shift
    ;;
    -p|--nodePort)
    if [ $SYSTEMD_INUSE -eq 1 ]; then
      echo 'Node Port:' $(journalctl -u masternode.service | grep 'HTTP endpoint opened' | awk '{print $11}' | awk '{print $1}' | grep -o -P '(?<=http://0.0.0.0:).*' | tail -1)
    else
      echo 'Node Port:' $(echo "$(tac ./geth.out)" | grep 'HTTP endpoint opened' | awk '{print $6}' | awk '{print $1}' | grep -o -P '(?<=http://0.0.0.0:).*' | tail -1)
    fi
    shift
    ;;
    -i|--nodeIp)
    echo 'Node IP:' $(curl --silent -4 icanhazip.com)
    shift
    ;;
    -h|--help)
    echo '-e or --enodeId prints out EnodeID tied to geth instance'
    echo '-p or --nodePort prints out the rpc port tied to geth instance'
    echo '-i or --nodeIp prints out the public facing IP address for this server'
    shift
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
