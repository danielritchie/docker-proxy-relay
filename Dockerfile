FROM debian:latest
MAINTAINER Jeremie HUCHET

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get upgrade -qy

RUN apt-get install -qy cntlm redsocks

ADD cntlm.conf /etc/cntlm.conf
RUN chmod 600 /etc/cntlm.conf

ADD redsocks.conf /etc/redsocks.conf

EXPOSE 3131
EXPOSE 3132

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
