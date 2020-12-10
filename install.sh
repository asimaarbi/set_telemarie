#!/usr/bin/env bash

set -e

while ! ping -c 1 -W 1 8.8.8.8; do
  echo "Waiting for 1.2.3.4 - network interface might be down..."
  sleep 1
done
if [[ $(id -u) -ne 0 ]]; then
  echo Must run as root
  exit 1
fi
cp turn_off_wifi.sh turn_on_wifi.sh automate.sh provider.py run_provider.py ~/Desktop
cp email.service /etc/systemd/system/

if ! [[ -d ~/.config/ ]]; then
  mkdir ~/.config/
fi

cp -r autostart ~/.config/autostart/
systemctl enable email.service
systemctl start email.service

rm -r ~/set_telemarie
