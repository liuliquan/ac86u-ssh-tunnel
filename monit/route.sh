#!/bin/sh

# Save PID
PIDFILE=$1
echo $$ > $PIDFILE

# Delete the rule which will make first loop always re-config
iptables -D FORWARD -i tun1000 -j ACCEPT 2>/dev/null

while true; do
  iptables -C FORWARD -i tun1000 -j ACCEPT 2>/dev/null

  if [ $? -ne 0 ]; then

    # Create route table to go through tun
    echo "Create route table..."
    ip route flush table 1000
    ip route add table 1000 default via 10.20.30.1
    ip rule del table 1000 2>/dev/null
    ip rule add fwmark 1000 table 1000 priority 1000

    # Flush route cache
    ip route flush cache

    # Loose rp filter for tun interface
    echo 2 > /proc/sys/net/ipv4/conf/tun1000/rp_filter
    echo "4096 87380 16291456" > /proc/sys/net/ipv4/tcp_rmem
    echo "4096 87380 16291456" > /proc/sys/net/ipv4/tcp_wmem

    # Mark tunnelset ips so it will go through tun
    echo "Config iptables..."
    iptables -D FORWARD -i tun1000 -j ACCEPT 2>/dev/null
    iptables -I FORWARD -i tun1000 -j ACCEPT
    iptables -D FORWARD -o tun1000 -j ACCEPT 2>/dev/null
    iptables -I FORWARD -o tun1000 -j ACCEPT
    iptables -t mangle -D PREROUTING -m set --match-set tunnelset dst -j MARK --set-mark 1000 2>/dev/null
    iptables -t mangle -I PREROUTING -m set --match-set tunnelset dst -j MARK --set-mark 1000
    iptables -t mangle -D OUTPUT -m set --match-set tunnelset dst -j MARK --set-mark 1000 2>/dev/null
    iptables -t mangle -I OUTPUT -m set --match-set tunnelset dst -j MARK --set-mark 1000
    iptables -t nat -D POSTROUTING -o tun1000 -j SNAT --to-source 10.20.30.2 2>/dev/null
    iptables -t nat -I POSTROUTING -o tun1000 -j SNAT --to-source 10.20.30.2

  fi

  sleep 5
done
