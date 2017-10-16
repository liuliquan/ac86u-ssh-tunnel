#!/bin/sh

for env in `cat /jffs/ac86u-ssh-tunnel/.env`;
do
  eval "${env}"
done

PIDFILE=/var/run/socks5-tunnel.pid

export AUTOSSH_PIDFILE=$PIDFILE
export AUTOSSH_GATETIME="0"
export AUTOSSH_PATH="/opt/bin/ssh"

if [ "$1" = "start" ]; then

    autossh -f -M 0 -D 0.0.0.0:1081 -C -q -N -oStrictHostKeyChecking=no -i /jffs/ac86u-ssh-tunnel/id_rsa -p $PORT $USER@$VPS

elif [ "$1" = "stop" ]; then
    /bin/kill $(/bin/cat $PIDFILE)
fi