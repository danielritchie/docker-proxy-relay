#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# defaults
proxy_host=localhost
proxy_port=3128
proxy_user=
proxy_domain=
CFG_FILE="${SCRIPT_DIR}/../conf/config"
LCL_PORT=33128

USAGE="Usage: $0 [action]
	Follow prompts to confirm or override default/configured values, and enter password

Actions that can be passed for $0:
    start   Start the container
    stop    Stop the container
    status  Return status for the container
    help    Print this ;-)
	
Options:
    -m MODE     Mode of operation, options as follows:
                    full    - (default) Redirect local Docker traffic and expose for external/remote access
					FUTURE ENHANCEMENTS:
					docker	- Redirect local Docker traffic, but do not expose for external/remote access
					proxy   - Do not redirect Docker traffic, expose for external/remote access
    -c CFG_FILE Configuration file [default: ${CFG_FILE}]
    -p LCL_PORT Local port where this proxy can be accessed [default: ${LCL_PORT}] 

This script is a wrapper to start a Docker container that will act as a proxy, and will also redirect all local docker traffic through it.  See documentation for additional/latest information:
https://github.com/danielritchie/docker-proxy-relay/blob/master/README.md	
"

while getopts "m:c:p:h" OPTION
do
    case $OPTION in
        m) MODE="$OPTARG" ;;
		c) CFG_FILE="$OPTARG" ;;
		p) LCL_PORT="$OPTARG" ;;
        h) echo "$USAGE"; exit;;
        *) exit 1;;
    esac
done

if [[ "$MODE" == "help" ]] ; then
   echo "$USAGE"
   exit 1
fi

# default override from configuration
if [[ -f $CFG_FILE ]] then
  . $CFG_FILE
else
  echo "WARNING: A configuration file cannot be found!"
  echo "Default values WILL NOT BE SOURCED from: ${CFG_FILE}"
fi
#test -f $CFG_FILE && . $CFG_FILE

FORWARD_TO_PROXY="PREROUTING -i docker0 -p tcp --dport 80 -j REDIRECT --to ${LCL_PORT} -m comment --comment 'DOCKER_PROXY'"

case "$1" in
start)
  read -p "Proxy host: ($proxy_host) " input && proxy_host="${input:-$proxy_host}"
  read -p "Proxy port: ($proxy_port) " input && proxy_port="${input:-$proxy_port}"
  read -p "Proxy domain: ($proxy_domain) " input && proxy_domain="${input:-$proxy_domain}"
  if [[ "z$proxy_domain" != "z" ]] ; then
	domain_entry="$proxy_domain\\"
  else
    domain_entry=""
  fi
  read -p "$proxy_host:$proxy_port username: ($proxy_user) " input && proxy_user="${input:-$proxy_user}"
  read -s -p "$domain_entry$proxy_user@$proxy_host:$proxy_port password: " proxy_pass && echo

  docker run --name docker-proxy -d -p ${LCL_PORT}:${proxy_port} \
      -e username=$proxy_user \
      -e password=$proxy_pass \
      -e domain=$proxy_domain
      -e proxy=$proxy_host:$proxy_port \
      docker-proxy-relay
	  #kops/docker-proxy-relay:2.0

  if [[ "$MODE" != "proxy" ]] ; then
	  sudo iptables -t nat -A $FORWARD_TO_PROXY
	  sudo iptables -t nat -L -n
  fi 
  ;;
stop)
  docker stop docker-proxy || docker kill docker-proxy
  docker rm docker-proxy
  #Will error if no entries found, but that's OK...could modify to update MODE in status and respond appropriately here 
  sudo iptables -t nat -D $FORWARD_TO_PROXY
  sudo iptables -t nat -L -n
  ;;
status)
  docker ps | head -1
  docker ps | grep docker-proxy
  sudo iptables -t nat -L -n | grep "DOCKER PROXY"
  ;;
*)
  echo "$USAGE"
  exit
  ;;
esac
