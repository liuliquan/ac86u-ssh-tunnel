#!/bin/sh

PIDFILE=/var/run/ipset-dns.pid

if [ "$1" = "start" -o -z "$1" ]; then

    ipset-dns tunnelset '' 53000 8.8.8.8 
    echo `ps | grep 'ipset-dns tunnelset' | grep -v 'grep' | awk '{print $1}'` > $PIDFILE

elif [ "$1" = "stop" ]; then

    /bin/kill -9 $(/bin/cat $PIDFILE)
fi
