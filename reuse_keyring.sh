#!/usr/bin/env bash


set -e

file="/etc/DBUS_SESSION_BUS_ADDRESS"

if [ -s "$file" ]; then
    a=$(< /etc/DBUS_SESSION_BUS_ADDRESS)
    if [ -n "$a" ]; then
      export DBUS_SESSION_BUS_ADDRESS=$a
      echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
    fi
fi



