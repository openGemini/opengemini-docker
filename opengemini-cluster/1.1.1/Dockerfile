FROM buildpack-deps:bookworm-curl

RUN export DEBIAN_FRONTEND=noninteractive && \
    # install dependencies \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      procps && \
    # cleanup apt \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV OPENGEMINI_VERSION 1.1.1

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" && \
    case "${dpkgArch##*-}" in \
      amd64) ARCH='amd64';; \
      arm64) ARCH='arm64';; \
      *)     echo "Unsupported architecture: ${dpkgArch}"; exit 1;; \
    esac && \
    wget --no-verbose --no-check-certificate https://github.com/openGemini/openGemini/releases/download/v${OPENGEMINI_VERSION}/openGemini-${OPENGEMINI_VERSION}-linux-${ARCH}.tar.gz && \
    tar zxvf openGemini-${OPENGEMINI_VERSION}-linux-${ARCH}.tar.gz --wildcards '*ts-*' && \
    mv usr/bin/ts-sql /usr/local/bin/ts-sql && \
    mv usr/bin/ts-meta /usr/local/bin/ts-meta && \
    mv usr/bin/ts-store /usr/local/bin/ts-store && \
    mv usr/bin/ts-monitor /usr/local/bin/ts-monitor && \
    mv usr/bin/ts-cli /usr/local/bin/ts-cli && \
    rm -f usr/bin/ts-* && \
    rm -f openGemini-${OPENGEMINI_VERSION}-linux-${ARCH}.tar.gz*

RUN chmod +x /usr/local/bin/ts-*

RUN mkdir -p /var/log/openGemini \
    && chmod ugo+Xrw -R /var/log/openGemini

ENV PATH="/usr/local/bin:${PATH}"
