#!/bin/sh

# Save PID
PIDFILE=$1
echo $$ > $PIDFILE

# Load env
for env in `cat /jffs/ac86u-ssh-tunnel/.env`;
do
  eval "${env}"
done

# Kill all existing ssh which will make first loop always re-connect
killall -9 ssh 2>/dev/null

while true; do

  ping -c 1 -W 2 10.20.30.1 1>/dev/null

  if [ $? -ne 0 ]; then
    echo "Start ssh tunnel..."

    killall -9 ssh 2>/dev/null
    /opt/bin/ssh -o Tunnel=point-to-point -w 1000:1000 -C -q -N -oStrictHostKeyChecking=no -i /jffs/ac86u-ssh-tunnel/id_rsa -p $PORT $USER@$VPS &

  fi

  sleep 5
done
