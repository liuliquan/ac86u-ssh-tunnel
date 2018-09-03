#!/bin/sh

PIDFILE=/var/run/ssh-route.pid

if [ "$1" = "start" -o -z "$1" ]; then

    /jffs/ac86u-ssh-tunnel/router/route.sh &

elif [ "$1" = "stop" ]; then

    /bin/kill -9 $(/bin/cat $PIDFILE)
fi
