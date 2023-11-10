#!/bin/env bash
set -e

# dynamic configuration parameters by --config=item
if [ "${1:0:1}" = '-' ]; then
    set -- ts-server "$@"
fi

# execute `ts-server CMD`
if [ "$1" = 'ts-server' ]; then
	/init-server.sh "${@:2}"
fi

exec "$@" -config /etc/openGemini/server.conf
