FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.12

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

RUN apk add --no-cache \
 ca-certificates \
 openssh-client

# set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV DOCKER_VERSION 20.10.1

ADD https://download.docker.com/linux/static/stable/aarch64/docker-20.10.1.tgz /docker.tgz

RUN set -eux \
 && tar x -f /docker.tgz \
        --strip-components 1 \
        --directory /usr/local/bin/ \
 && rm -rvf /docker.tgz \
 && dockerd --version \
 && docker --version

COPY modprobe.sh /usr/local/bin/modprobe
COPY entrypoint /entrypoint

COPY config.toml /etc/docker/config.toml
COPY certs/docker.crt /etc/docker/docker.crt
COPY certs/docker.pem /etc/docker/docker.pem

ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client

ENTRYPOINT ["/entrypoint"]
CMD ["sh"]







# FROM golang:1.13.15-alpine as src-docker
# 
# RUN apk add --no-cache git \
#                       bash \
#                       coreutils \
#                       gcc \
#                       musl-dev
# 
# ENV CGO_ENABLED=0 \
#     DISABLE_WARN_OUTSIDE_CONTAINER=1
# 
# RUN mkdir -p /go/src/github.com/docker \
#  && cd /go/src/github.com/docker \
#  && git clone --depth 1 https://github.com/docker/cli.git
# 
# WORKDIR /go/src/github.com/docker/cli
# 
# RUN ./scripts/build/binary
# 
# 
# FROM alpine:edge
# 
# COPY --from=config-alpine /etc/localtime /etc/localtime
# COPY --from=config-alpine /etc/timezone  /etc/timezone
# 
# COPY --from=src-docker /go/src/github.com/docker/cli/build/docker-linux-arm64 /usr/bin/docker
# 
# EXPOSE 4444
# 
# # https://nparsons.uk/blog/using-btrfs-on-alpine-linux
# 
# RUN echo btrfs >> /etc/modules
# RUN apk add --no-cache build-base git go libseccomp libseccomp-dev protobuf protobuf-dev btrfs-progs btrfs-progs-dev 
# 
# RUN git clone --branch v1.4.3 --depth 1 https://github.com/containerd/containerd.git
# 
# RUN go get github.com/containerd/containerd \
#  && go get github.com/opencontainers/runc \
#  && cd /root/go/src/github.com/containerd/containerd \
#  && make \
#  && make install \
#  && cd /root/go/src/github.com/opencontainers/runc \
#  && make \
#  && make install
# 
# RUN cp -v /usr/local/bin/* /usr/bin/  \
#  && cp -v /usr/local/sbin/runc /usr/bin/runc
#
# COPY config.toml /etc/containerd/config.toml
# # containered.crt  privkey.pem
# COPY certs/containered.crt /etc/containerd/containered.crt
# #COPY certs/privkey.pem /etc/containerd/containered.pem
# 
# CMD ["tail", "-f", "/dev/null"]
#
# # install -D -m0755 runc /usr/local/sbin/runc
# # install bin/ctr bin/containerd bin/containerd-stress bin/containerd-shim bin/containerd-shim-runc-v1 
# # bin/containerd-shim-runc-v2








#!/usr/local/bin/docker
#FROM registry.gautier.local:5000/alpine:3.8

# RUN apk --no-cache add socat

# EXPOSE 4243

# VOLUME /var/run/docker.sock

# CMD ["/usr/bin/socat", "-v", "TCP-LISTEN:4243,reuseaddr,fork", "UNIX:/var/run/docker.sock"]
# /usr/bin/socat -v TCP-LISTEN:4243,reuseaddr,fork UNIX:/var/run/docker.sock
