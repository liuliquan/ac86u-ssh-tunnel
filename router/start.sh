#!/bin/sh

# Wait router startup
echo "Check router status..."
while [ -z "`pidof lpd`" -o -z "`pidof disk_monitor`" -o -z "`pidof miniupnpd`" -o -z "`pidof mcpd`" -o -z "`nvram get success_start_service`" -o "`nvram get success_start_service`" != "1" ]; do
        sleep 5;
    done

# Load kernel modules
if [ -z "`lsmod | grep -w ip_set`" ]; then
    echo "Load ip_set module..."
    insmod /jffs/ac86u-ssh-tunnel/ko/ip_set.ko
fi
if [ -z "`lsmod | grep -w ip_set_hash_ip`" ]; then
    echo "Load ip_set_hash_ip module..."
    insmod /jffs/ac86u-ssh-tunnel/ko/ip_set_hash_ip.ko
fi
if [ -z "`lsmod | grep -w xt_set`" ]; then
    echo "Load xt_set module..."
    insmod /jffs/ac86u-ssh-tunnel/ko/xt_set.ko
fi

# Chmod config files
echo "Chmod config files..."
chmod 600 /jffs/ac86u-ssh-tunnel/monit/monitrc
cp -f /jffs/ac86u-ssh-tunnel/monit/monitrc /opt/etc/monitrc
chmod 600 /jffs/ac86u-ssh-tunnel/id_rsa

# Create 'tunnelset' ipset
if [ -z "`ipset list | grep -w 'Name: tunnelset'`" ]; then
    echo "Create ipset..."
    ipset create tunnelset hash:ip
fi
if [ -z "`ipset list tunnelset | grep -w 8.8.8.8`" ]; then
    echo "Initialize ipset..."
    ipset add tunnelset 8.8.8.8
fi

# Create tun interface
echo "Create tun interface..."
modprobe tun
ip tuntap del tun1000 mode tun
ip tuntap add tun1000 mode tun
ip link set tun1000 up
ip link set tun1000 txqueuelen 200
ip addr add 10.20.30.2/32 dev tun1000
ip route add 10.20.30.0/24 dev tun1000

# Start services
echo "Start services..."
monit -c /opt/etc/monitrc
sleep 5
monit monitor all
