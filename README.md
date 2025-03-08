# tailscale-routes-fix
A bash script to override the routing table on Linux once --accept-routes is specified on a network with more than one subnet router (which causes an infinite loop and loss of connectivity on the local IP))
