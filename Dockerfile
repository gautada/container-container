#!/usr/local/bin/docker
FROM registry.gautier.local:5000/alpine:3.8

RUN apk --no-cache add socat

EXPOSE 4243

VOLUME /var/run/docker.sock

CMD ["/usr/bin/socat", "-v", "TCP-LISTEN:4243,reuseaddr,fork", "UNIX:/var/run/docker.sock"]
# /usr/bin/socat -v TCP-LISTEN:4243,reuseaddr,fork UNIX:/var/run/docker.sock
