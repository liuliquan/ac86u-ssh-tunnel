#!/bin/sh

PIDFILE=/var/run/ssh-dnsmasq.pid

if [ "$1" = "start" -o -z "$1" ]; then

    /jffs/ac86u-ssh-tunnel/dns/dnsmasq.sh &

elif [ "$1" = "stop" ]; then

    /bin/kill -9 $(/bin/cat $PIDFILE)
fi
