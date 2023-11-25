FROM alpine:3.18

RUN echo 'hosts: files dns' >> /etc/nsswitch.conf
RUN apk add --no-cache tzdata bash ca-certificates && \
    update-ca-certificates

ENV OPENGEMINI_VERSION 1.1.0

RUN OPENGEMINI_ARCH= && dpkgArch="$(arch)" && \
    case "${dpkgArch##*-}" in \
      x86_64) OPENGEMINI_ARCH='amd64';; \
      amd64) OPENGEMINI_ARCH='amd64';; \
      arm64) OPENGEMINI_ARCH='arm64';; \
      aarch64) OPENGEMINI_ARCH='arm64';; \
      *)     echo "Unsupported architecture: ${dpkgArch}"; exit 1;; \
    esac && \
    set -ex && \
    mkdir ~/.gnupg; \
    echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf; \
    apk add --no-cache --virtual .build-deps wget tar && \
    wget --no-verbose --no-check-certificate https://github.com/openGemini/openGemini/releases/download/v${OPENGEMINI_VERSION}/openGemini-${OPENGEMINI_VERSION}-linux-${OPENGEMINI_ARCH}.tar.gz && \
    tar zxvf openGemini-${OPENGEMINI_VERSION}-linux-${OPENGEMINI_ARCH}.tar.gz --wildcards '*ts-*' && \
    mv usr/bin/ts-server /usr/local/bin/ts-server && \
    mv usr/bin/ts-cli /usr/local/bin/ts-cli && \
    rm -f usr/bin/ts-* && \
    rm -f openGemini-${OPENGEMINI_VERSION}-linux-${OPENGEMINI_ARCH}.tar.gz*

COPY server.conf /etc/openGemini/server.conf
COPY entrypoint.sh /entrypoint.sh
COPY init-server.sh /init-server.sh

RUN chmod +x /entrypoint.sh \
             /init-server.sh \
             /usr/local/bin/ts-server

EXPOSE 8086

VOLUME /var/lib/openGemini
VOLUME /var/log/openGemini

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ts-server"]