#!/bin/sh

echo "Reset iptables..."
iptables -D FORWARD -i tun1000 -j ACCEPT 2>/dev/null
iptables -D FORWARD -o tun1000 -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING ! -s 10.20.30.1 -j MASQUERADE 2>/dev/null

iptables -D FORWARD -i tun2000 -j ACCEPT 2>/dev/null
iptables -D FORWARD -o tun2000 -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING ! -s 10.20.40.1 -j MASQUERADE 2>/dev/null

iptables -D FORWARD -i tun3000 -j ACCEPT 2>/dev/null
iptables -D FORWARD -o tun3000 -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING ! -s 10.20.50.1 -j MASQUERADE 2>/dev/null

echo "Delete tun interface..."
ip tuntap del tun1000 mode tun
ip tuntap del tun2000 mode tun
ip tuntap del tun3000 mode tun

ip route flush cache
