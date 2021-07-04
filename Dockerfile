FROM debian:buster as builder
RUN apt-get update && apt-get install -y \
        build-essential \
        automake autoconf \
        libtool \
        pkg-config \
        intltool \
        libcurl4-openssl-dev \
        libglib2.0-dev \
        libevent-dev \
        libminiupnpc-dev \
        libssl-dev  \
        libappindicator3-dev
ENV TRANSMISSION_VERSION=3.00   WEB_CONTROL_VERSION=1.6.1-update1
RUN curl -sSL https://github.com/transmission/transmission/releases/download/3.00/transmission-${TRANSMISSION_VERSION}.tar.xz | tar -Jxf -
# install transmission
RUN cd transmission-${TRANSMISSION_VERSION} \
        && ./configure --enable-cli \
            --without-gtk \
            --prefix=/opt/transmission-3.00 \
            --disable-shared \
            --enable-static \
            && make -j$(nproc) install
# install transmission
RUN curl -sSL https://github.com/ronggang/transmission-web-control/archive/v${WEB_CONTROL_VERSION}.tar.gz | tar -zxf -
RUN mv /opt/transmission-3.00/share/transmission/web/index.html /opt/transmission-3.00/share/transmission/web/index.original.html \
        && mv transmission-web-control-${WEB_CONTROL_VERSION}/src/* /opt/transmission-3.00/share/transmission/web/

FROM debian:buster
COPY --from=builder /opt/transmission-3.00 /opt/transmission-3.00
RUN apt-get update && apt-get install -y libcurl4-openssl-dev libevent-dev libminiupnpc-dev libssl-dev

EXPOSE 51413 9091
VOLUME /downloads

ENV TRANSMISSION_VERSION=3.00 
ENV WEB_CONTROL_VERSION=1.6.1-update1

WORKDIR /downloads
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/transmission-3.00/bin/transmission-daemon", "--config-dir", "/var/lib/transmission", "--download-dir", "/downloads", "--foreground"]
