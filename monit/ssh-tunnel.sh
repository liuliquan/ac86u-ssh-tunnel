#!/bin/sh

for env in `cat /jffs/ac86u-ssh-tunnel/.env`;
do
  eval "${env}"
done

PIDFILE=/var/run/ssh-tunnel.pid

export AUTOSSH_PIDFILE=$PIDFILE
export AUTOSSH_GATETIME="0"
export AUTOSSH_PATH="/opt/bin/ssh"

if [ "$1" = "start" ]; then

    autossh -f -M 0 -o Tunnel=point-to-point -w 1000:1000 -C -q -N -oStrictHostKeyChecking=no -i /jffs/ac86u-ssh-tunnel/id_rsa -p $PORT $USER@$VPS

elif [ "$1" = "stop" ]; then
    /bin/kill $(/bin/cat $PIDFILE)
fi
