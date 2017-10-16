#!/bin/sh

PIDFILE=/var/run/socat.pid

if [ "$1" = "start" -o -z "$1" ]; then

    socat -t5 -T5 udp4-recvfrom:53001,reuseaddr,fork tcp:127.0.0.1:8853  </dev/null &
    echo $! >$PIDFILE

elif [ "$1" = "stop" ]; then

    /bin/kill -9 $(/bin/cat $PIDFILE)
fi
