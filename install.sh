#!/usr/bin/env bash

set -e

while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for 1.2.3.4 - network interface might be down..."
    sleep 1
done
wget
if [[ $(id -u) -ne 0 ]]; then
    echo Must run as root
    exit 1
fi
cp turn_off_wifi.sh ~/Desktop