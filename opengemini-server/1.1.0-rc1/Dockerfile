FROM buildpack-deps:bullseye-curl

ENV OPENGEMINI_VERSION 1.1.0-rc1

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" && \
    case "${dpkgArch##*-}" in \
      amd64) ARCH='amd64';; \
      arm64) ARCH='arm64';; \
      *)     echo "Unsupported architecture: ${dpkgArch}"; exit 1;; \
    esac && \
    wget --no-verbose --no-check-certificate https://github.com/openGemini/openGemini/releases/download/v${OPENGEMINI_VERSION}/openGemini-${OPENGEMINI_VERSION}-linux-${ARCH}.tar.gz && \
    tar zxvf openGemini-${OPENGEMINI_VERSION}-linux-${ARCH}.tar.gz --wildcards '*ts-server' && \
    mv usr/bin/ts-server /usr/local/bin/ts-server && \
    rm -f openGemini-${OPENGEMINI_VERSION}-linux-${ARCH}.tar.gz*

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