FROM alpine:3.13.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.13.1 as containers-build

ENV RUNC_BRANCH="v1.0.0-rc93"
ENV CONMON_BRANCH="v2.0.26"
ENV BUILDAH_BRANCH="v1.19.4"
ENV PODMAN_BRANCH="v3.0.0"
ENV PLUGINS_BRANCH="v0.9.1"

RUN apk add --no-cache build-base git go pkgconf libseccomp-dev bash device-mapper gpgme-dev device-mapper-libs lvm2-dev
WORKDIR /build
RUN git config --global advice.detachedHead false
RUN git clone --branch=$RUNC_BRANCH    --depth=1 https://github.com/opencontainers/runc.git
RUN git clone --branch=$CONMON_BRANCH  --depth=1 https://github.com/containers/conmon.git
RUN git clone --branch=$BUILDAH_BRANCH --depth=1 https://github.com/containers/buildah.git
RUN git clone --branch=$PODMAN_BRANCH  --depth=1 https://github.com/containers/podman.git
RUN git clone --branch=$PLUGINS_BRANCH --depth=1 https://github.com/containernetworking/plugins.git

WORKDIR /build/runc
RUN make

WORKDIR /build/conmon
RUN make

WORKDIR /build/buildah
RUN make

WORKDIR /build/podman
RUN make

WORKDIR /build/plugins
RUN /build/plugins/build_linux.sh

FROM alpine:3.13.1 

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone
COPY --from=containers-build /build/runc/runc /usr/bin/runc
COPY --from=containers-build /build/conmon/bin/conmon /usr/bin/conmon
COPY --from=containers-build /build/buildah/bin/buildah /usr/bin/buildah
COPY --from=containers-build /build/buildah/bin/imgtype /usr/bin/imgtype
COPY --from=containers-build /build/podman/bin/podman /usr/bin/podman
COPY --from=containers-build /build/podman/bin/podman-remote /usr/bin/podman-remote
COPY --from=containers-build /build/podman/cni/87-podman-bridge.conflist /etc/cni/net.d/87-podman-bridge.conflist
COPY --from=containers-build /build/plugins/bin /usr/libexec/cni

RUN apk add --no-cache libseccomp device-mapper gpgme

CMD ["tail", "-f", "/dev/null"]
