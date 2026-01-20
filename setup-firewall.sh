#!/bin/bash
# Firewall Setup for K3s on Raspberry Pi
# Allows: SSH, n8n (32191)
# Blocks: Everything else external

echo "=== Setting up UFW Firewall ==="

# 1. Install UFW if missing
if ! command -v ufw &> /dev/null; then
    echo "Installing ufw..."
    sudo apt-get update && sudo apt-get install -y ufw
fi

# 2. Reset to default state (to clear old rules)
echo "Resetting rules..."
sudo ufw --force reset

# 3. Set Defaults
# Block all incoming by default
sudo ufw default deny incoming
# Allow all outgoing (so the Pi can download updates/images)
sudo ufw default allow outgoing

# 4. Allow Critical External Ports
echo "Allowing SSH and n8n..."
sudo ufw allow ssh              # Port 22
sudo ufw allow 32191/tcp        # n8n NodePort

# 5. Allow K3s/Kubernetes Internal Traffic (CRITICAL)
# K3s needs these to let pods talk to each other
echo "Allowing internal K3s traffic..."
sudo ufw allow from 10.42.0.0/16  # Pod CIDR
sudo ufw allow from 10.43.0.0/16  # Service CIDR
sudo ufw allow in on cni0         # Flannel interface
sudo ufw allow in on flannel.1    # Flannel overlay

# 6. Enable the Firewall
echo "Enabling firewall..."
# 'yes' automatically answers the "Command may disrupt existing ssh connections" prompt
echo "y" | sudo ufw enable

echo ""
echo "=== Firewall Status ==="
sudo ufw status verbose
