# ac86u-ssh-tunnel

Used to provide ssh tunnel on ASUS RT-AC86U router. It will automatically resolve DNS and tunnel the TCP traffic for specific domains at router level, the LAN devices (PC, smart phone) do not need any additional setup.

## Setup VPS

The VPS needs run SSHD server with identity key file authentication.

SSH into VPS, install socat, then run `socat tcp4-listen:8853,reuseaddr,fork udp:8.8.8.8:53 &`

## Setup router

SSH into AC86U router, dowload the repo into `/jffs/ac86u-ssh-tunnel` folder, then run
```shell
cd /jffs/ac86u-ssh-tunnel
chmod +x setup.sh && ./setup.sh
```
## Config router

Update `/jffs/ac86u-ssh-tunnel/id_rsa` to your own identity key file.

Update `/jffs/ac86u-ssh-tunnel/.env` to your VPS user/host/port and also your original DNS server (used to resolve the domains which will **not** go through tunnel).

Use `/jffs/ac86u-ssh-tunnel/dns/tunnel-domains.txt` to config the site domains to go through ssh tunnel.

## Start

Run `/jffs/ac86u-ssh-tunnel/start.sh` to startup ssh tunnel. It will auto start after reboot.