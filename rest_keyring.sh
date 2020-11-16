#!/usr/bin/env bash

set -e

#https://medium.com/@Aenon/bash-location-of-current-script-76db7fd2e388
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo $DBUS_SESSION_BUS_ADDRESS > /etc/DBUS_SESSION_BUS_ADDRESS

killall -q -9 "$(whoami)" gnome-keyring-daemon || echo ''

#based on https://unix.stackexchange.com/a/602935
eval $(echo -n "$" \
           | gnome-keyring-daemon --unlock \
           | sed -e 's/^/export /')

echo '' >&2


file="$DIR/enter_init.sh"
if [ -s "$file" ]; then
  echo "enter_init.sh is found, going to use it."
  source $file
fi

$@

#keyring set https://upload.pypi.org/legacy your-username
