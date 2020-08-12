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

# Create route table to go through tun
echo "Create route table..."
ip route flush table 1000
ip route add table 1000 default via 10.20.30.1
ip rule del table 1000 2>/dev/null
ip rule add fwmark 1000 table 1000 priority 1000

# Flush route cache
ip route flush cache

# Loose rp filter for tun interface
echo 2 > /proc/sys/net/ipv4/conf/tun1000/rp_filter
echo "4096 87380 16291456" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 87380 16291456" > /proc/sys/net/ipv4/tcp_wmem

# Mark tunnelset ips so it will go through tun
echo "Config iptables..."
iptables -D INPUT -i tun1000 -s 10.20.30.1 -j ACCEPT 2>/dev/null
iptables -I INPUT -i tun1000 -s 10.20.30.1 -j ACCEPT
iptables -D FORWARD -i tun1000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -i tun1000 -j ACCEPT
iptables -D FORWARD -o tun1000 -j ACCEPT 2>/dev/null
iptables -I FORWARD -o tun1000 -j ACCEPT
iptables -t mangle -D PREROUTING -m set --match-set tunnelset dst -j MARK --set-mark 1000 2>/dev/null
iptables -t mangle -I PREROUTING -m set --match-set tunnelset dst -j MARK --set-mark 1000
iptables -t mangle -D OUTPUT -m set --match-set tunnelset dst -j MARK --set-mark 1000 2>/dev/null
iptables -t mangle -I OUTPUT -m set --match-set tunnelset dst -j MARK --set-mark 1000
iptables -t nat -D POSTROUTING -o tun1000 ! -s 10.20.30.2 -j SNAT --to-source 10.20.30.2 2>/dev/null
iptables -t nat -I POSTROUTING -o tun1000 ! -s 10.20.30.2 -j SNAT --to-source 10.20.30.2

source /jffs/ac86u-ssh-tunnel/.env

echo "Config dnsmasq..."
echo "server=127.0.0.1" > /jffs/opt/etc/resolv.conf
ln -sf /jffs/opt/etc/resolv.conf /etc/resolv.conf

echo "server=$ORIGINAL_DNS" > /tmp/resolv.conf

touch /tmp/resolv.dnsmasq.tmp
echo "server=$ORIGINAL_DNS" > /tmp/resolv.dnsmasq.tmp

for domain in `cat /jffs/ac86u-ssh-tunnel/dns/tunnel-domains.txt`;
do                          
    echo "server=/$domain/127.0.0.1#53000" >> /tmp/resolv.dnsmasq.tmp
done
mv -f /tmp/resolv.dnsmasq.tmp /tmp/resolv.dnsmasq

/sbin/service restart_dnsmasq

killall -9 ipset-dns 2>/dev/null                                           
/jffs/ac86u-ssh-tunnel/dns/ipset-dns tunnelset '' 53000 8.8.8.8

echo "Start ssh tunnel..."
chmod 600 /jffs/ac86u-ssh-tunnel/id_rsa
killall -9 ssh 2>/dev/null
/opt/bin/ssh -o Tunnel=point-to-point -w 1000:1000 -C -q -N -oStrictHostKeyChecking=no -i /jffs/ac86u-ssh-tunnel/id_rsa -p $PORT $USER@$VPS &
