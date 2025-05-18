#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2025 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later
#
# This script must be run inside the host that runs the lxc server

# IPv4 Forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# IPv4 Masquerading
sudo iptables -t nat -A POSTROUTING -s 10.0.3.0/24 ! -d 10.0.3.0/24 -j MASQUERADE

# Get the external interface
EXTIF=$(ip route | grep default | awk '{print $5}')

# Apply FWD rules 
sudo iptables -A FORWARD -i lxcbr0 -o $EXTIF -j ACCEPT
sudo iptables -A FORWARD -i $EXTIF -o lxcbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
