#!/bin/sh

# Create chain
iptables -t nat -N SHADOWSOCKS

# Clean rules of chain
iptables -t nat -F SHADOWSOCKS

# VPS IP address
for env in `cat /jffs/ac86u-ssh-tunnel/.env`;
do
  eval "${env}"
done
iptables -t nat -A SHADOWSOCKS -d $VPS -j RETURN

# Ignore LANs IP address
iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN

# Redirect ips in tunnelset set to 12345 port
iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set tunnelset dst -j REDIRECT --to-ports 12345

# Add to PREROUTING chain
iptables -t nat -D PREROUTING -p tcp -j SHADOWSOCKS
iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS
