#!/usr/bin/env bash

set -e

#https://medium.com/@Aenon/bash-location-of-current-script-76db7fd2e388
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#see https://keyring.readthedocs.io/en/latest/#using-keyring-on-headless-linux-systems
dbus-run-session $DIR/rest_keyring.sh "$@"
