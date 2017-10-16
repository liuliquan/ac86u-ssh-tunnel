#!/bin/sh

PIDFILE=/var/run/redsocks.pid

if [ "$1" = "start" -o -z "$1" ]; then

    redsocks -c /opt/etc/redsocks.conf -p $PIDFILE &

elif [ "$1" = "stop" ]; then

    /bin/kill -9 $(/bin/cat $PIDFILE)
fi
