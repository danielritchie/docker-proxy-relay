danielritchie/docker-proxy-relay
==================
A docker container to act as a transparent relay for forwarding traffic to an HTTP proxy (probably because you are behind a corporate proxy at work).

Configured for two primary use cases:

1. **Formatting values for variables like _http_proxy_ can be challenging under certain conditions**
  * eg, npm's special handling of the backslash, needing to escape special characters, etc.
  * This container provides an unauthenticated proxy using the Docker host's IP and port 33128 (configurable)
2. **Dockerfiles are not portable when proxy information changes**
  * iptable rule will redirect everything incoming from network interface _docker0_ (outgoing traffic on port 80) to the _docker-proxy-relay container_ so that all containers running on this host will by default use this container's proxy

It uses [redsocks](https://github.com/darkk/redsocks) to forward requests to a proxy. NOTE: [go-any-proxy](https://github.com/ryanchapman/go-any-proxy) may be an alternative.

This was made possible by [Jeremie Huchet] (http://jeremie.huchet.nom.fr/)'s allowance of derivative works from [kops/docker-proxy-relay] (https://github.com/kops/docker-proxy-relay).  Je vous remercie.


# INITIAL SETUP:

#####PRE-REQUISITES:
* Git with access to GitHub
* Docker

#####1. Acquire the latest source by cloning (or equivalent):
&nbsp;&nbsp;```git clone git@github.com:danielritchie/docker-proxy-relay.git```

#####2. Setup Dockerfile from Dockerfile.TEMPLATE
&nbsp;&nbsp;```cp Dockerfile.TEMPLATE Dockerfile```				
* Modify _Dockerfile_ to set environment values for **http_proxy** and **https_proxy**
* NOTE: It is presumed that you are already behind a proxy and are using this container as a result.  If not, these values can be left blank.
* FYI: The _Dockerfile_ is omitted in .gitignore and will not be updated or overwritten on future pulls

#####3. Build the Docker image
&nbsp;&nbsp;```docker build -t docker-proxy-relay . ```

#####4. Setup your default configuration information
&nbsp;&nbsp;```cp conf/config.example conf/config```
  * Modify _conf/config_ file so that values match your desired defaults
  * FYI: The _conf/config_ file is omitted in .gitignore and will not be updated or overwritten on future pulls
		


# USE:

Command | Detail
---------------------------|----------------------------------
`etc/docker_proxy.sh start` | Start container and add iptables rule
`etc/docker_proxy.sh stop` | Stop container and revert iptables rule
`etc/docker_proxy.sh status` | Return status of the proxy relay
`etc/docker_proxy.sh help` |  Provide more info and additional options
  * Once the container is running, direct proxy variables (http_proxy, https_proxy, etc.) to _http://your.docker.host.ip:33128_
  * Enjoy!

#####Misc. References:
[cntlm] (http://cntlm.sourceforge.net/)  
[Markdown Cheatsheet] (https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)  
[Jeremie Huchet] (http://jeremie.huchet.nom.fr/)  