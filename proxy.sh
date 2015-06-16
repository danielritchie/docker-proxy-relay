#!/bin/bash

FORWARD_TO_PROXY="PREROUTING -i docker0 -p tcp --dport 80 -j REDIRECT --to 33128 -m comment --comment 'DOCKER_PROXY'"

set -e

case "$1" in
drop)
  $0 stop
  docker rm proxy-oab
  ;;
create)
  docker run --name proxy-oab -d -p 33128:3128 proxy-oab:latest
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
start)
  docker start proxy-oab
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
stop)
  sudo iptables -t nat -D $FORWARD_TO_PROXY
  docker stop proxy-oab || docker kill proxy-oab
  ;;
ps)
  docker ps | head -1
  docker ps | grep proxy-oab
  ;;
*)
  echo "Usage: $0 [create|start|stop]"
  ;;
esac
