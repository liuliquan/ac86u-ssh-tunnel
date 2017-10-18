# ac86u-ssh-tunnel

Used to provide ssh tunnel on ASUS RT-AC86U router. A layer-3 TUN interface will be setup on both VPS and router, which will be used to tunnel the DNS resolve and TCP/UDP traffic for specific domains. The LAN devices behind router (Home PC, smart phone) do not need any additional setup.

## Setup VPS

The VPS needs run OpenSSH server V4.3+ with identity key file authentication. It also needs set `PermitTunnel` to `yes` in `/etc/ssh/sshd_config` config file:

```
PermitTunnel yes
```

Then restart OpenSSH server, e.g if it's installed as systemd service:
```shell
sudo systemctl restart sshd.service
```

Then run following commands to install tunnel service:
```shell
sudo git clone https://github.com/liuliquan/ac86u-ssh-tunnel.git /ac86u-ssh-tunnel
sudo cp /ac86u-ssh-tunnel/vps/ac86u-ssh-tunnel.service /etc/systemd/system/
sudo systemctl enable ac86u-ssh-tunnel.service
sudo systemctl start ac86u-ssh-tunnel.service
```

If you don't use systemd service, you may simply run:
```shell
sudo /ac86u-ssh-tunnel/vps/start.sh
```

## Setup router

SSH into AC86U router, dowload the repo into `/jffs/ac86u-ssh-tunnel` folder, then run
```shell
cd /jffs/ac86u-ssh-tunnel
chmod +x setup-router.sh && ./setup-router.sh
```
## Config router

Update `/jffs/ac86u-ssh-tunnel/id_rsa` to your own identity key file.

Update `/jffs/ac86u-ssh-tunnel/.env` to your VPS user/host/port and also your original DNS server (used to resolve the domains which will **not** go through tunnel).

Use `/jffs/ac86u-ssh-tunnel/dns/tunnel-domains.txt` to config the site domains to go through ssh tunnel.

## Start tunnel

Run `/jffs/ac86u-ssh-tunnel/start.sh` to startup tunnel. It will auto start after router reboot.