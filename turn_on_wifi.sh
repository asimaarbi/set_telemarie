#!/usr/bin/env bash

sudo systemctl enable dhcpcd
sudo systemctl start dhcpcd

echo "done"
