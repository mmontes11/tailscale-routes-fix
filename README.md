# tailscale-routes-fix

A bash script to override the routing table on Linux once --accept-routes is specified on a network with more than one subnet router (which causes an infinite loop and loss of connectivity on the local IP))

__Inspired by this Ansible role: [ironicbadger/tailscale-routes-fix](https://github.com/ironicbadger/tailscale-routes-fix)__

More information about this issue can be found in the [Tailscale documentation](https://tailscale.com/kb/1023/troubleshooting#lan-traffic-prioritization-with-overlapping-subnet-routes).

## Usage

```bash
curl -sfL https://raw.githubusercontent.com/mmontes11/tailscale-routes-fix/main/tailscale-routes-fix.sh | \
  sudo env LAN_SUBNET="10.0.0.0/24" ROUTES_TABLE="main" bash
```

This will create a systemd service to setup the IP rule on boot and therefore fixing the routing table for Tailscale:

```bash
sudo systemctl status tailscale-routes-fix
* tailscale-routes-fix.service - Add custom IP rule at boot for Tailscale
     Loaded: loaded (/etc/systemd/system/tailscale-routes-fix.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sat 2025-03-08 21:02:04 CET; 30s ago
    Process: 12285 ExecStart=/sbin/ip rule add to 10.0.0.0/24 priority 2500 lookup main (code=exited, sta>
   Main PID: 12285 (code=exited, status=0/SUCCESS)
        CPU: 10ms

Mar 08 21:02:04 gateway systemd[1]: Starting Add custom IP rule at boot for Tailscale...
Mar 08 21:02:04 gateway systemd[1]: Finished Add custom IP rule at boot for Tailscale.

ip rule
0:      from all lookup local
2500:   from all to 10.0.0.0/24 lookup main
5210:   from all fwmark 0x80000/0xff0000 lookup main
5230:   from all fwmark 0x80000/0xff0000 lookup default
5250:   from all fwmark 0x80000/0xff0000 unreachable
5270:   from all lookup 52
32766:  from all lookup main
32767:  from all lookup default
```

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