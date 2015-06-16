#!/bin/bash

set -e

USER=$2
PROXY=$3


FORWARD_TO_PROXY="PREROUTING -i docker0 -p tcp --dport 80 -j REDIRECT --to 33128 -m comment --comment 'DOCKER PROXY'"

case "$1" in
start)
  echo -n "$USER@$PROXY password: "
  read -rs PASS
  echo
  docker run --name docker-proxy -d -p 33128:3128 \
      -e username=$USER \
      -e password=$PASS \
      -e proxy=$PROXY \
      docker-proxy-relay:v2
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  sudo iptables -t nat -L -n
  ;;
stop)
  sudo iptables -t nat -D $FORWARD_TO_PROXY
  sudo iptables -t nat -L -n
  docker stop docker-proxy || docker kill docker-proxy
  docker rm docker-proxy
  ;;
status)
  docker ps | head -1
  docker ps | grep docker-proxy
  sudo iptables -t nat -L -n | grep "DOCKER PROXY"
  ;;
*)
  cat <<EOF
Usage: $0 start <username> <proxy_host:proxy_port>"
       $0 stop
       $0 status
EOF
  ;;
esac
