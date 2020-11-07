#!/usr/bin/env bash

#https://medium.com/@Aenon/bash-location-of-current-script-76db7fd2e388
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


set -e

if pidof "dbus-daemon" >/dev/null ; then
  if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    source $DIR/reuse_keyring.sh

    if ! pidof "gnome-keyring-daemon" >/dev/null ; then
      source $DIR/rest_keyring.sh
    fi
  fi
else
  if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    echo "Env variable \$DBUS_SESSION_BUS_ADDRESS is found, but there is no dbus-daemon process. \
\$DBUS_SESSION_BUS_ADDRESS will be reset." 1>&2;
  fi

  echo 'going to call dbus-run-session'

  param=$@

  if [ -z "$param" ];  then
     param="bash"
  fi

  #see https://keyring.readthedocs.io/en/latest/#using-keyring-on-headless-linux-systems
  dbus-run-session $DIR/rest_keyring.sh "$param"
fi
