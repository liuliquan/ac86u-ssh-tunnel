#!/bin/sh

nvram set jffs2_on=1
nvram set jffs2_enable=1
nvram set jffs2_scripts=1
nvram set jffs2_exec="/jffs/ac86u-ssh-tunnel/router/jffs.autorun"
nvram commit

umount /opt

rm -rf /jffs/opt
mkdir /jffs/opt
mkdir /jffs/opt/bin
mkdir /jffs/opt/doc
mkdir /jffs/opt/etc
mkdir /jffs/opt/include
mkdir /jffs/opt/lib
mkdir /jffs/opt/sbin
mkdir /jffs/opt/scripts
mkdir /jffs/opt/share
mkdir /jffs/opt/tmp
mkdir /jffs/opt/usr
mkdir /jffs/opt/var

cp -f /opt/scripts/* /jffs/opt/scripts

mount -o bind /jffs/opt /opt

wget -O - http://pkg.entware.net/binaries/armv7/installer/entware_install.sh | sh

opkg install openssh-client autossh ipset ipset-dns monit

chmod +x /jffs/ac86u-ssh-tunnel/router/jffs.autorun
find /jffs/ac86u-ssh-tunnel -name "*.sh" -exec chmod +x {} \;

ansi_green="\033[1;32m"
ansi_std="\033[m"

echo -e "$ansi_green Please update /jffs/ac86u-ssh-tunnel/id_rsa to your own rsa private key file $ansi_std"
echo -e "$ansi_green Please update /jffs/ac86u-ssh-tunnel/.env to config your vps user/host/port and original dns $ansi_std"
echo -e "$ansi_green Please update /jffs/ac86u-ssh-tunnel/dns/tunnel-domains.txt to config site domains to go through tunnel $ansi_std"
