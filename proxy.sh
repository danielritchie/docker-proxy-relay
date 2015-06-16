#!/bin/bash

FORWARD_TO_PROXY="PREROUTING -i docker0 -p tcp --dport 80 -j REDIRECT --to 33128 -m comment --comment 'DOCKER_PROXY'"

set -e

case "$1" in
drop)
  $0 stop
  docker rm transparent-auth-proxy
  ;;
create)
  docker run --name transparent-auth-proxy -d -e username=USERNAME -e password=PASSWORD -e proxy=PROXU_HOST:PROXY_PORT -p 33128:3128 transparent-auth-proxy:latest
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
start)
  docker start transparent-auth-proxy
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
stop)
  sudo iptables -t nat -D $FORWARD_TO_PROXY
  docker stop transparent-auth-proxy || docker kill transparent-auth-proxy
  ;;
ps)
  docker ps | head -1
  docker ps | grep transparent-auth-proxy
  ;;
*)
  echo "Usage: $0 [create|start|stop]"
  ;;
esac
