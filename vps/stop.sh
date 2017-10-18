#!/bin/sh

echo "Reset iptables..."
iptables -D FORWARD -i tun1000 -j ACCEPT 2>/dev/null
iptables -D FORWARD -o tun1000 -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -s 10.20.30.0/24 -j MASQUERADE 2>/dev/null

echo "Delete tun interface..."
ip tuntap del tun1000 mode tun
ip route flush cache
