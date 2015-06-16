#!/bin/bash

FORWARD_TO_PROXY="PREROUTING -i docker0 -p tcp --dport 80 -j REDIRECT --to 33128 -m comment --comment 'DOCKER_PROXY'"

set -e

case "$1" in
drop)
  $0 stop
  docker rm docker-proxy-relay
  ;;
create)
  docker run --name docker-proxy-relay -d -e username=USERNAME -e password=PASSWORD -e proxy=PROXY_HOST:PROXY_PORT -p 33128:3128 proxy-oab:latest
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
start)
  docker start docker-proxy-relay
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
stop)
  sudo iptables -t nat -D $FORWARD_TO_PROXY
  docker stop docker-proxy-relay || docker kill docker-proxy-relay
  ;;
ps)
  docker ps | head -1
  docker ps | grep docker-proxy-relay
  ;;
*)
  echo "Usage: $0 [create|start|stop]"
  ;;
esac
