docker-proxy-relay
==================

A docker container to act as a transparent relay for forwarding traffic to an HTTP proxy.

It uses [redsocks](https://github.com/darkk/redsocks) to forward requests to a proxy. NOTE: [go-any-proxy](https://github.com/ryanchapman/go-any-proxy) may be an alternative.

Thank you to [Jeremie Huchet] (http://jeremie.huchet.nom.fr/)
This was made possible by Jeremie's allowance of derivative works from [kops/docker-proxy-relay] (https://github.com/kops/docker-proxy-relay)

## Why?

To simplify access to a proxy (ie, behind a corporate proxy while at work).  We have configured this for two primary use cases:
1. Formatting variables for http_proxy can be challenging with special characters in the proxy information
* Docker container with cntlm and redsocks, accessible without authentication via Docker host IP and configurable port
2. Dockerfiles are not portable when proxy information needs to change depending upon location
* iptable rule to redirect everything incoming from network interface _docker0_ to the _proxy-relay-container_

## How to use it?

Prerequisites:
A host with access to GitHub that has Docker installed

Acquire the latest source by cloning (or equivalent):
	git clone https://github.com/danielritchie/docker-proxy-relay

Setup Dockerfile from Dockerfile.TEMPLATE
	cp Dockerfile.TEMPLATE Dockerfile
				
	Set environment values for http_proxy and https_proxy
	NOTE: It is presumed that you are already behind a proxy and are using this container as a result.  If not, these values can be left blank.
	
Build the Docker image

	docker build -t docker-proxy-relay .

Make the wrapper script executable

	chmod +x etc/docker_proxy.sh

Set your default configuration information (optional)
	
	cp conf/config.example conf/config

	Modify configuration information to match your desired default values
	NOTE: While it is possible to set your password here, it is not recommended to store it in plain text!
	
Start/Stop the container as desired using `etc/docker_proxy.sh`

`start` | `stop` | `status` | `help`
---| --- | ---
Follow prompts and enter password | Stops container and reverts IP table rule | Returns status of container | More options than defined here

START the proxy relay and redirect all docker containers outgoing traffic on port 80 to the _proxy-relay-container_

	etc/docker_proxy.sh start 
	Follow prompts and enter password

STOP the proxy relay:

	etc/docker_proxy.sh stop

Get STATUS:

	etc/docker_proxy.sh status
		

Misc. References:
    cntlm: http://cntlm.sourceforge.net/