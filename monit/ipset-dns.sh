#!/bin/sh

export LD_LIBRARY_PATH=/opt/lib

PIDFILE=/var/run/ipset-dns.pid

if [ "$1" = "start" -o -z "$1" ]; then

    /jffs/ac86u-ssh-tunnel/dns/ipset-dns tunnelset '' 53000 8.8.8.8 53
    echo `ps | grep 'ipset-dns tunnelset' | grep -v 'grep' | awk '{print $1}'` > $PIDFILE

elif [ "$1" = "stop" ]; then

    /bin/kill -9 $(/bin/cat $PIDFILE)
fi
