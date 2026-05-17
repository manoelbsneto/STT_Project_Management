#!/usr/bin/env bash
##############################################################################
# setup_ssh_msi.sh — Run this on the MSI-laptop WSL terminal
# Copies SSH keys to HP, sets up SSH config, verifies bidirectional SSH
##############################################################################
set -euo pipefail

# --- Configuration ---
HP_TAILSCALE_IP="100.117.123.61"
HP_USER="dataops-labs"
HP_HOSTNAME="hp"

MSI_TAILSCALE_IP="100.122.21.119"
MSI_USER="dataops-lab"
MSI_HOSTNAME="msi-laptop"

SSH_CONFIG="$HOME/.ssh/config"

echo ""
echo "========================================"
echo " MSI-laptop SSH Setup Script"
echo "========================================"
echo ""

# Step 1: Ensure SSH key exists on MSI
echo "[1/5] Checking SSH key on MSI..."
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "  Generating SSH key..."
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N '' -C "${MSI_USER}@${MSI_HOSTNAME}"
else
    echo "  SSH key already exists."
fi
echo "  Public key: $(cat "$HOME/.ssh/id_ed25519.pub")"

# Step 2: Test SSH connectivity to HP
echo ""
echo "[2/5] Testing SSH connectivity to HP ($HP_TAILSCALE_IP)..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes "${HP_USER}@${HP_TAILSCALE_IP}" "echo OK" 2>/dev/null; then
    echo "  Key-based auth already working!"
    NEED_COPY=false
else
    echo "  Key-based auth not set up yet. Will copy key..."
    NEED_COPY=true
fi

# Step 3: Copy SSH key to HP
echo ""
echo "[3/5] Copying SSH key to HP..."
if [ "$NEED_COPY" = true ]; then
    echo "  Running ssh-copy-id (you'll be asked for the HP password)..."
    ssh-copy-id -o StrictHostKeyChecking=no "${HP_USER}@${HP_TAILSCALE_IP}"
    echo "  Key copied successfully!"
else
    echo "  Skipped — already authorized."
fi

# Step 4: Create SSH config aliases
echo ""
echo "[4/5] Setting up SSH config aliases..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Backup existing config
if [ -f "$SSH_CONFIG" ]; then
    cp "$SSH_CONFIG" "${SSH_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
fi

# Remove old entries if they exist
if [ -f "$SSH_CONFIG" ]; then
    sed -i '/^# --- Tailscale SSH Hosts ---$/,/^# --- End Tailscale ---$/d' "$SSH_CONFIG"
fi

# Append new config
cat >> "$SSH_CONFIG" << EOF
# --- Tailscale SSH Hosts ---
Host hp
    HostName ${HP_TAILSCALE_IP}
    User ${HP_USER}
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    ServerAliveInterval 30
    ServerAliveCountMax 3

Host msi
    HostName ${MSI_TAILSCALE_IP}
    User ${MSI_USER}
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    ServerAliveInterval 30
    ServerAliveCountMax 3
# --- End Tailscale ---
EOF

chmod 600 "$SSH_CONFIG"
echo "  SSH config updated. You can now use: ssh hp"

# Step 5: Verify bidirectional SSH
echo ""
echo "[5/5] Verifying connections..."
echo ""

echo "  MSI → HP:"
if ssh -o ConnectTimeout=10 hp "echo '    ✓ Connected to \$(hostname) as \$(whoami)'" 2>/dev/null; then
    echo "    ✓ MSI → HP: SUCCESS"
else
    echo "    ✗ MSI → HP: FAILED (check HP's SSH service)"
fi

echo ""
echo "  HP → MSI (checking if HP has MSI's key):"
if ssh -o ConnectTimeout=10 hp "ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes ${MSI_USER}@${MSI_TAILSCALE_IP} 'echo OK'" 2>/dev/null; then
    echo "    ✓ HP → MSI: SUCCESS"
else
    echo "    ⚠ HP → MSI: Not yet configured"
    echo "    → Run on HP: ssh-copy-id ${MSI_USER}@${MSI_TAILSCALE_IP}"
fi

echo ""
echo "========================================"
echo " Setup Complete!"
echo "========================================"
echo ""
echo " Quick commands:"
echo "   ssh hp          — Connect to HP from MSI"
echo "   ssh msi         — Connect to MSI from HP (after HP key copy)"
echo "   scp file.txt hp:~/  — Copy file to HP home"
echo ""
