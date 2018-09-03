#!/bin/sh

# Save PID
PIDFILE=/var/run/ssh-dnsmasq.pid
echo $$ > $PIDFILE

# Load env
for env in `cat /jffs/ac86u-ssh-tunnel/.env`;
do
  eval "${env}"
done

# Restore resolv.dnsmasq which will make first loop always re-config
echo "server=$ORIGINAL_DNS" > /tmp/resolv.dnsmasq

while true; do

  if [ -z "`grep -m1 "127.0.0.1#53000" /tmp/resolv.dnsmasq`" ]; then
    echo "Config dnsmasq..."

    echo "server=127.0.0.1" > /jffs/opt/etc/resolv.conf
    ln -sf /jffs/opt/etc/resolv.conf /etc/resolv.conf

    echo "server=$ORIGINAL_DNS" > /tmp/resolv.conf

    touch /tmp/resolv.dnsmasq.tmp
    echo "server=$ORIGINAL_DNS" > /tmp/resolv.dnsmasq.tmp

    for domain in `cat /jffs/ac86u-ssh-tunnel/dns/tunnel-domains.txt`;
    do
      echo "server=/$domain/127.0.0.1#53000" >> /tmp/resolv.dnsmasq.tmp
    done
    mv -f /tmp/resolv.dnsmasq.tmp /tmp/resolv.dnsmasq

    /sbin/service restart_dnsmasq
  fi

  sleep 5
done
