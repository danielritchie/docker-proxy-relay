FROM debian:latest
MAINTAINER Jeremie HUCHET

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get upgrade -qy

RUN apt-get install -qy squid3

COPY squid.conf /etc/squid3/squid.conf

EXPOSE 3128
VOLUME /etc/squid3/conf.d

CMD [ "squid3", "-N" ]
