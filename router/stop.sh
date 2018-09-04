#!/bin/sh

for env in `cat /jffs/ac86u-ssh-tunnel/.env`;
do
  eval "${env}"
done

# Stop all services
echo "Stop services..."
monit stop all
sleep 2
killall -9 dnsmasq.sh 2</dev/null
killall -9 route.sh 2</dev/null
killall -9 autossh 2</dev/null
killall -9 ssh 2</dev/null
killall -9 ipset-dns 2</dev/null
killall -9 monit 2</dev/null
rm /root/.monit.*

# Clean iptable roles
echo "Reset iptables..."
iptables -D FORWARD -i tun1000 -j ACCEPT 2>/dev/null
iptables -D FORWARD -o tun1000 -j ACCEPT 2>/dev/null
iptables -t mangle -D PREROUTING -m set --match-set tunnelset dst -j MARK --set-mark 1000 2>/dev/null
iptables -t mangle -D OUTPUT -m set --match-set tunnelset dst -j MARK --set-mark 1000 2>/dev/null
iptables -t nat -D POSTROUTING -o tun1000 -j SNAT --to-source 10.20.30.2 2>/dev/null

# Delete tun interface
echo "Delete tun interface..."
ip tuntap del tun1000 mode tun
ip route flush table 1000
ip rule del table 1000

# Flush route cache
ip route flush cache

echo "Reset dnsmasq..."
echo "server=$ORIGINAL_DNS" > /tmp/resolv.dnsmasq
/sbin/service restart_dnsmasq
