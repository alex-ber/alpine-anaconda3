#!/usr/bin/env bash

set -e

echo $DBUS_SESSION_BUS_ADDRESS > /etc/DBUS_SESSION_BUS_ADDRESS

killall -q -9 "$(whoami)" gnome-keyring-daemon || echo ''

#based on https://unix.stackexchange.com/a/602935
eval $(echo -n "$" \
           | gnome-keyring-daemon --unlock \
           | sed -e 's/^/export /')

sleep 5s
echo '' >&2


$@

#keyring set https://upload.pypi.org/legacy your-username
