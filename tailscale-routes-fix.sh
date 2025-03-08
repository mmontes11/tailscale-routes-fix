#!/bin/bash

set -eo pipefail

if [[ -z "$LAN_SUBNET" ]]; then
  echo "Error: LAN_SUBNET must be set before running the script."
  echo "Example:"
  echo "  export LAN_SUBNET=10.0.0.0/24"
  exit 1
fi
ROUTES_TABLE=${ROUTES_TABLE:-main}
SERVICE_NAME="tailscale-routes-fix"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "Creating systemd service file..."
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Add custom IP rule at boot for Tailscale
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip rule add to $LAN_SUBNET priority 2500 lookup $ROUTES_TABLE
ExecStop=/sbin/ip rule del to $LAN_SUBNET priority 2500 lookup $ROUTES_TABLE
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling systemd service..."
systemctl enable "$SERVICE_NAME"

echo "Starting systemd service..."
systemctl start "$SERVICE_NAME"

echo "Verifying IP rule..."
ip rule show | grep "$LAN_SUBNET" || echo "Rule not found. Please check manually."

echo "Setup complete!"
