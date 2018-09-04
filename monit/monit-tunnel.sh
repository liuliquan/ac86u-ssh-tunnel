#!/bin/sh

PIDFILE=/var/run/monit-tunnel.pid

if [ "$1" = "start" -o -z "$1" ]; then

    /jffs/ac86u-ssh-tunnel/monit/tunnel.sh $PIDFILE &

elif [ "$1" = "stop" ]; then

    /bin/kill -9 $(/bin/cat $PIDFILE)
fi
