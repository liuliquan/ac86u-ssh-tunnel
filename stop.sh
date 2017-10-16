#!/bin/sh

for env in `cat /jffs/ac86u-ssh-tunnel/.env`;
do
  eval "${env}"
done

monit stop all

iptables -t nat -D PREROUTING -p tcp -j SHADOWSOCKS

echo "server=$ORIGINAL_DNS" > /tmp/resolv.dnsmasq
/sbin/service restart_dnsmasq
