#!/bin/bash

FORWARD_TO_PROXY="PREROUTING -i docker0 -p tcp --dport 80 -j REDIRECT --to 3128"

set -e

case "$1" in
drop)
  $0 stop
  docker rm proxy-spike
  ;;
create)
  docker run --name proxy-spike -d -p 3128:3128 -v $(cd $(dirname $0) ; pwd)/conf.d:/etc/squid3/conf.d transparent-auth-proxy
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
start)
  docker start proxy-spike
  sudo iptables -t nat -A $FORWARD_TO_PROXY
  ;;
stop)
  sudo iptables -t nat -D $FORWARD_TO_PROXY
  docker stop proxy-spike || docker kill proxy-spike
  ;;
ps)
  docker ps | head -1
  docker ps | grep proxy-spike
  ;;
*)
  echo "Usage: $0 [create|start|stop]"
  ;;
esac
