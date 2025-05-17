#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2025 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later
#
# This script is installs and configures lxc on a host to run the tests for MailAD
#
# Goals:
#   - install lxc and dnsmasq on the host [debian/ubuntu]
#   - configure the lxc network
#   - add the hosts to the lxc network

# install packages
apt-get update
apt-get install -y lxc lxc-templates bridge-utils dnsmasq-base dnsmasq-utils

# configure lxc
cat > /etc/lxc/default.conf << EOF
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.apparmor.profile = generated
lxc.apparmor.allow_nesting = 1
EOF

# configure the network interfaces
cat > /etc/default/lxc-net << EOF
USE_LXC_BRIDGE="true"
# use custom dns
LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
LXC_DHCP_RANGE="10.0.3.1,10.0.3.254"
EOF

# configure dnsmasq
cat > /etc/lxc/dnsmasq.conf << EOF
interface=lxcbr0
dhcp-range=10.0.3.1,10.0.3.254,24h
EOF

# add the hosts to the lxc network
cat > /etc/lxc/dnsmasq.conf << EOF
# defaults
domain=mailad.cu
# reservations
dhcp-host=dc,10.0.3.10
dhcp-host=mail,10.0.3.11
dhcp-host=test,10.0.3.12
EOF

# restart services
systemctl enable lxc lxc-net
systemctl start lxc lxc-net
