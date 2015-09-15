#!/bin/bash

set -e

IAMWHO=`whoami`
if [[ "$IAMWHO" == "root" ]]; then
	echo "Support does not yet exist to run as root...try another user"
	exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Defaults are to be sourced from configuration file.  This will be the one provided in the readme
CFG_FILE="${SCRIPT_DIR}/../conf/config"

# default override from configuration
if [[ -f $CFG_FILE ]]; then
  . $CFG_FILE
  #echo "The following has been sourced: `cat $CFG_FILE`"
else
  echo "ERROR: A configuration file is required!"
  echo "Configuration file path: ${CFG_FILE}"
fi

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
                    POTENTIAL FUTURE ENHANCEMENTS:
                    docker	- Redirect local Docker traffic, but do not expose for external/remote access
                    proxy   - Do not redirect Docker traffic, only make available for external/remote access
    -c CFG_FILE Configuration file for proxy information [default: ${CFG_FILE}]
    -p LCL_PORT Local port where this proxy can be accessed [default: ${LCL_PORT}] 
    -i DCKR_IMG Name of Docker image to be used (default: ${DCKR_IMG})

This script is a wrapper to start a Docker container that will act as a proxy, and will also redirect all local docker traffic through it.  See documentation for additional/latest information:
https://github.com/danielritchie/docker-proxy-relay/blob/master/README.md	
"

while getopts "m:c:p:i:h" OPTION
do
    case $OPTION in
        m) MODE="$OPTARG" ;;
		c) CFG_FILE="$OPTARG" ;;
		p) LCL_PORT="$OPTARG" ;;
		i) DCKR_IMG="$OPTARG" ;;
        h) echo "$USAGE"; exit;;
        *) exit 1;;
    esac
done

if [[ "$MODE" == "help" ]] ; then
   echo "$USAGE"
   exit 1
fi

FORWARD_TO_PROXY="PREROUTING -i docker0 -p tcp --dport 80 -j REDIRECT --to 33128 -m comment --comment 'DOCKER_PROXY'"

case "$1" in
start)
  read -p "Proxy host: ($proxy_host) " input && proxy_host="${input:-$proxy_host}"
  read -p "Proxy port: ($proxy_port) " input && proxy_port="${input:-$proxy_port}"
  read -p "Proxy domain: ($proxy_domain) " input && proxy_domain="${input:-$proxy_domain}"
  read -p "$proxy_host:$proxy_port username: ($proxy_user) " input && proxy_user="${input:-$proxy_user}"
  read -s -p "$proxy_user@$proxy_host:$proxy_port password: " proxy_pass && echo

  docker run --name docker-proxy -d -p ${LCL_PORT}:3128 -e username=$proxy_user -e password=$proxy_pass -e domain=$proxy_domain -e proxy=$proxy_host:$proxy_port ${DCKR_IMG}
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
  sudo iptables -t nat -L -n | grep "DOCKER_PROXY"
  ;;
*)
  echo "$USAGE"
  exit
  ;;
esac
