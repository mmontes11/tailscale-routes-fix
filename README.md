# tailscale-routes-fix

A bash script to override the routing table on Linux once --accept-routes is specified on a network with more than one subnet router (which causes an infinite loop and loss of connectivity on the local IP))

__Inspired by this Ansible role: [ironicbadger/tailscale-routes-fix](https://github.com/ironicbadger/tailscale-routes-fix)__

## Usage

```bash
curl -sfL https://raw.githubusercontent.com/mmontes11/tailscale-routes-fix/main/tailscale-routes-fix.sh | \
  sudo env LAN_SUBNET="10.0.0.0/24" ROUTES_TABLE="main" bash
```

This will create a systemd service to setup the IP rule on boot and therefore fixing the routing table for Tailscale.

## Cleanup

In order to remove the IP rule, you can stop the systemd service:

```bash
sudo systemctl stop tailscale-routes-fix
```

To fully remove the systemd service:

```bash
sudo systemctl disable tailscale-routes-fix
sudo rm /etc/systemd/system/tailscale-routes-fix.service
```