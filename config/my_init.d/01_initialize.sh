#!/bin/bash

HOSTNAME=$(hostname)
FILE_KEY="/app/data/certificates/$HOSTNAME.key"
FILE_CRT="/app/data/certificates/$HOSTNAME.crt"

mkdir -p /app/htdocs
mkdir -p /app/data/certificates
mkdir -p /app/data/logs
mkdir -p /app/config

if [ -d /app/config ]
then
	files=($(find /app/config -type f))

	for source in "${files[@]}"
	do
		pattern="\.DS_Store"
		target=${source/\/app\/config/etc\/apache2}

		if [[ ! $target =~ $pattern ]]; then
			if [[ -f $target ]]; then
				echo "    Removing \"$target\"" && rm -rf $target
			fi

			echo "    Linking \"$source\" to \"$target\"" && mkdir -p $(dirname "${target}") && ln -s $source $target
		fi
	done
fi

if [ ! -f $FILE_KEY ]
then
	openssl req -x509 -nodes -days 36500 -newkey rsa:8192 -keyout $FILE_KEY -out $FILE_CRT -subj "/C=DE/ST=None/L=None/O=None/OU=None/CN=$HOSTNAME"
fi

a2ensite -q 000-default.conf > /dev/null 2>&1