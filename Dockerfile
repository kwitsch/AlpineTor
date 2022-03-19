FROM alpine 

ARG TORVERSION

ENV TOR_VERSION ${TORVERSION}
ENV TOR_TARBALL_NAME tor-$TOR_VERSION.tar.gz
ENV TOR_TARBALL_LINK https://dist.torproject.org/$TOR_TARBALL_NAME
ENV TOR_TARBALL_ASC $TOR_TARBALL_NAME.asc

RUN apk update
RUN apk add --no-cache \
    make \
    automake \
    autoconf \
    gcc \
    libtool \
    curl \
    libevent-dev \
    musl \
    musl-dev \
    libgcc \
    openssl \
    openssl-dev \
    openssh \
    gnupg \
    zlib-dev \
    tzdata

RUN wget $TOR_TARBALL_LINK
RUN wget $TOR_TARBALL_LINK.asc
RUN gpg --keyserver keys.openpgp.org --recv-keys 7A02B3521DC75C542BA015456AFEE6D49E92B601
RUN gpg --verify $TOR_TARBALL_NAME.asc
RUN tar xvf $TOR_TARBALL_NAME

WORKDIR /tor-$TOR_VERSION
RUN ./configure
RUN make
RUN make install

WORKDIR /
RUN rm -r tor-$TOR_VERSION
RUN rm $TOR_TARBALL_NAME
RUN rm $TOR_TARBALL_NAME.asc

ENTRYPOINT [ "tor" ]

HEALTHCHECK --interval=60s --timeout=15s --start-period=20s \
    CMD curl -s --socks5 127.0.0.1:9050 'https://check.torproject.org/' | grep -qm1 Congratulations