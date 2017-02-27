#!/bin/bash
set -e
set -u

echo "Running init scripts..."

if [ "$(ls /config/init/)" ]; then
  for init in /config/init/*.sh; do
    . $init
  done
fi
