FROM alpine:3.10 as build

RUN apk --no-cache add \
# compilation
    gcc \
    make \
    musl-dev \
# ftp urls
    wget \
  && true

ENV BIND_VERSION 9.4.2

WORKDIR /usr/src/bind

RUN set -x \
  && wget -qO bind.tgz ftp://ftp.manet.nu/pub/bind/bind-${BIND_VERSION}.tar.gz \
  && tar --strip-components 1 -xvzf bind.tgz \
  && ./configure \
  && make LDFLAGS=-static \
  && (cd bin/dig \
    && strip dig host nslookup \
    && cp dig host nslookup /bin)

FROM scratch

COPY --from=build /bin/dig /bin/host /bin/nslookup /bin/

ENTRYPOINT ["/bin/dig"]
