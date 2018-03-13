#!/usr/bin/env sh

# Logic to handle arguments for optionally creating systemd service
for i in "$@"
do
case $i in
    -e|--enodeId)
    echo 'Enode Id:' $(journalctl -u masternode.service | grep 'UDP listener up' | awk '{print $11}' | grep -o -P '(?<=node://).*(?=@)' | tail -1)
    shift
    ;;
    -p|--nodePort)
    echo 'Node Port:' $(journalctl -u masternode.service | grep 'HTTP endpoint opened' | awk '{print $11}' | awk '{print $1}' | grep -o -P '(?<=http://0.0.0.0:).*' | tail -1)
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
