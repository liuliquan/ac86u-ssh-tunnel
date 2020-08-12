#!/bin/sh

# Create tun interface
echo "Create tun interface..."
ip tuntap del tun1000 mode tun
ip tuntap add tun1000 mode tun
ip link set tun1000 up
ip link set tun1000 txqueuelen 200
ip addr add 10.20.30.1/24 dev tun1000

ip tuntap del tun2000 mode tun
ip tuntap add tun2000 mode tun
ip link set tun2000 up
ip link set tun2000 txqueuelen 200
ip addr add 10.20.40.1/24 dev tun2000

ip tuntap del tun3000 mode tun
ip tuntap add tun3000 mode tun
ip link set tun3000 up
ip link set tun3000 txqueuelen 200
ip addr add 10.20.50.1/24 dev tun3000

# Flush route cache
ip route flush cache

# Enable ip forward
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.tcp_wmem="4096 1048576 5097152"
sysctl -w net.ipv4.tcp_rmem="4096 1048576 5097152"
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
sysctl -w net.ipv4.tcp_mtu_probing=1

# Setup iptables
echo "Setup iptables..."
iptables -D FORWARD -i tun1000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -i tun1000 -j ACCEPT
iptables -D FORWARD -o tun1000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -o tun1000 -j ACCEPT
iptables -t nat -D POSTROUTING ! -s 10.20.30.1 -j MASQUERADE 2>/dev/null
iptables -t nat -I POSTROUTING ! -s 10.20.30.1 -j MASQUERADE

iptables -D FORWARD -i tun2000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -i tun2000 -j ACCEPT
iptables -D FORWARD -o tun2000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -o tun2000 -j ACCEPT
iptables -t nat -D POSTROUTING ! -s 10.20.40.1 -j MASQUERADE 2>/dev/null
iptables -t nat -I POSTROUTING ! -s 10.20.40.1 -j MASQUERADE

iptables -D FORWARD -i tun3000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -i tun3000 -j ACCEPT
iptables -D FORWARD -o tun3000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -o tun3000 -j ACCEPT
iptables -t nat -D POSTROUTING ! -s 10.20.50.1 -j MASQUERADE 2>/dev/null
iptables -t nat -I POSTROUTING ! -s 10.20.50.1 -j MASQUERADE