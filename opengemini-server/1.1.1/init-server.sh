#!/bin/bash
set -e


AUTH_ENABLED="$OPENGEMINI_HTTP_AUTH_ENABLED"

if [ -z "$AUTH_ENABLED" ]; then
	AUTH_ENABLED="$(grep -iE '^\s*auth-enabled\s*=\s*true' /etc/openGemini/server.conf | grep -io 'true' | cat)"
else
	AUTH_ENABLED="$(echo "$OPENGEMINI_HTTP_AUTH_ENABLED" | grep -io 'true' | cat)"
fi

INIT_USERS=$([ ! -z "$AUTH_ENABLED" ] && [ ! -z "$OPENGEMINI_ADMIN_USER" ] && echo 1 || echo)

# Check if an environment variable for where to put meta is set.
# If so, then use that directory, otherwise use the default.
if [ -z "$OPENGEMINI_META_DIR" ]; then
	META_DIR="/var/lib/openGemini/meta"
else
	META_DIR="$OPENGEMINI_META_DIR"
fi

if ( [ ! -z "$INIT_USERS" ] || [ ! -z "$OPENGEMINI_DB" ] || [ "$(ls -A /docker-entrypoint-initdb.d 2> /dev/null)" ] ) && [ ! "$(ls -d "$META_DIR" 2>/dev/null)" ]; then

	INIT_QUERY=""
	CREATE_DB_QUERY="CREATE DATABASE $OPENGEMINI_DB"

	if [ ! -z "$INIT_USERS" ]; then

		if [ -z "$OPENGEMINI_ADMIN_PASSWORD" ]; then
			OPENGEMINI_ADMIN_PASSWORD="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)"
			echo "OPENGEMINI_ADMIN_PASSWORD:$OPENGEMINI_ADMIN_PASSWORD"
		fi

		INIT_QUERY="CREATE USER \"$OPENGEMINI_ADMIN_USER\" WITH PASSWORD '$OPENGEMINI_ADMIN_PASSWORD' WITH ALL PRIVILEGES"
	elif [ ! -z "$OPENGEMINI_DB" ]; then
		INIT_QUERY="$CREATE_DB_QUERY"
	else
		INIT_QUERY="SHOW DATABASES"
	fi

	OPENGEMINI_INIT_PORT="8086"

	OPENGEMINI_HTTP_BIND_ADDRESS=127.0.0.1:$OPENGEMINI_INIT_PORT OPENGEMINI_HTTP_HTTPS_ENABLED=false ts-server "$@" &
	pid="$!"

OPENGEMINI_CMD="ts-cli -host 127.0.0.1 -port $OPENGEMINI_INIT_PORT -execute "

	for i in {30..0}; do
		if $OPENGEMINI_CMD "$INIT_QUERY" &> /dev/null; then
			break
		fi
		echo 'ts-server init process in progress...'
		sleep 1
	done

	if [ "$i" = 0 ]; then
		echo >&2 'ts-server init process failed.'
		exit 1
	fi

	if [ ! -z "$INIT_USERS" ]; then

		OPENGEMINI_CMD="ts-cli -host 127.0.0.1 -port $OPENGEMINI_INIT_PORT -username ${OPENGEMINI_ADMIN_USER} -password ${OPENGEMINI_ADMIN_PASSWORD} -execute "

		if [ ! -z "$OPENGEMINI_DB" ]; then
			$OPENGEMINI_CMD "$CREATE_DB_QUERY"
		fi

		if [ ! -z "$OPENGEMINI_USER" ] && [ -z "$OPENGEMINI_USER_PASSWORD" ]; then
			OPENGEMINI_USER_PASSWORD="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)"
			echo "OPENGEMINI_USER_PASSWORD:$OPENGEMINI_USER_PASSWORD"
		fi

		if [ ! -z "$OPENGEMINI_USER" ]; then
			$OPENGEMINI_CMD "CREATE USER \"$OPENGEMINI_USER\" WITH PASSWORD '$OPENGEMINI_USER_PASSWORD'"

			$OPENGEMINI_CMD "REVOKE ALL PRIVILEGES FROM \"$OPENGEMINI_USER\""

			if [ ! -z "$OPENGEMINI_DB" ]; then
				$OPENGEMINI_CMD "GRANT ALL ON \"$OPENGEMINI_DB\" TO \"$OPENGEMINI_USER\""
			fi
		fi

		if [ ! -z "$OPENGEMINI_WRITE_USER" ] && [ -z "$OPENGEMINI_WRITE_USER_PASSWORD" ]; then
			OPENGEMINI_WRITE_USER_PASSWORD="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)"
			echo "OPENGEMINI_WRITE_USER_PASSWORD:$OPENGEMINI_WRITE_USER_PASSWORD"
		fi

		if [ ! -z "$OPENGEMINI_WRITE_USER" ]; then
			$OPENGEMINI_CMD "CREATE USER \"$OPENGEMINI_WRITE_USER\" WITH PASSWORD '$OPENGEMINI_WRITE_USER_PASSWORD'"
			$OPENGEMINI_CMD "REVOKE ALL PRIVILEGES FROM \"$OPENGEMINI_WRITE_USER\""

			if [ ! -z "$OPENGEMINI_DB" ]; then
				$OPENGEMINI_CMD "GRANT WRITE ON \"$OPENGEMINI_DB\" TO \"$OPENGEMINI_WRITE_USER\""
			fi
		fi

		if [ ! -z "$OPENGEMINI_READ_USER" ] && [ -z "$OPENGEMINI_READ_USER_PASSWORD" ]; then
			OPENGEMINI_READ_USER_PASSWORD="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)"
			echo "OPENGEMINI_READ_USER_PASSWORD:$OPENGEMINI_READ_USER_PASSWORD"
		fi

		if [ ! -z "$OPENGEMINI_READ_USER" ]; then
			$OPENGEMINI_CMD "CREATE USER \"$OPENGEMINI_READ_USER\" WITH PASSWORD '$OPENGEMINI_READ_USER_PASSWORD'"
			$OPENGEMINI_CMD "REVOKE ALL PRIVILEGES FROM \"$OPENGEMINI_READ_USER\""

			if [ ! -z "$OPENGEMINI_DB" ]; then
				$OPENGEMINI_CMD "GRANT READ ON \"$OPENGEMINI_DB\" TO \"$OPENGEMINI_READ_USER\""
			fi
		fi

	fi

	for f in /docker-entrypoint-initdb.d/*; do
		case "$f" in
			*.sh)     echo "$0: running $f"; . "$f" ;;
			*.iql)    echo "$0: running $f"; $OPENGEMINI_CMD "$(cat ""$f"")"; echo ;;
			*)        echo "$0: ignoring $f" ;;
		esac
		echo
	done

	if ! kill -s TERM "$pid" || ! wait "$pid"; then
		echo >&2 'ts-server init process failed. (Could not stop ts-server)'
		exit 1
	fi

fi