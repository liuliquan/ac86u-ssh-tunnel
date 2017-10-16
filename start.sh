#!/bin/sh

# Load kernel modules
insmod /jffs/ac86u-ssh-tunnel/ko/ip_set.ko
insmod /jffs/ac86u-ssh-tunnel/ko/ip_set_hash_ip.ko
insmod /jffs/ac86u-ssh-tunnel/ko/xt_set.ko

# Wait router startup
while [ -z "`pidof ntp`" ]; do
        sleep 3;
    done

# Create 'tunnelset' ipset
ipset create tunnelset hash:ip

# Start services
monit -c /opt/etc/monitrc
monit monitor all

# Wait router startup
while [ -z "`pidof lpd`" ]; do
        sleep 5;
    done

# Config iptables
sh -x /jffs/ac86u-ssh-tunnel/iptables/iptables.sh

# Config dnsmasq
sh -x /jffs/ac86u-ssh-tunnel/dns/dnsmasq.sh
