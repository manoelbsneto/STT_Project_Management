##############################################################################
# setup_ssh_hp.ps1 — Run this on the HP machine (Windows PowerShell as Admin)
# Sets up WSL systemd + SSH server + SSH keys for Tailscale connectivity
##############################################################################

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " HP WSL SSH Setup Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Configure wsl.conf to enable systemd
Write-Host "[1/6] Enabling systemd in WSL..." -ForegroundColor Yellow
wsl -u root bash -c @"
if grep -q 'systemd=true' /etc/wsl.conf 2>/dev/null; then
    echo 'systemd already enabled in wsl.conf'
else
    cat > /etc/wsl.conf << 'EOF'
[boot]
systemd=true

[user]
default=dataops-labs
EOF
    echo 'wsl.conf updated with systemd=true'
fi
"@

# Step 2: Install openssh-server (before restart, so it's ready)
Write-Host "`n[2/6] Installing openssh-server..." -ForegroundColor Yellow
wsl -u root bash -c "apt-get install -y openssh-server 2>&1 | tail -3"

# Step 3: Restart WSL to activate systemd
Write-Host "`n[3/6] Restarting WSL to activate systemd..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 3
Write-Host "WSL shutdown complete. Restarting..." -ForegroundColor Gray

# Step 4: Verify systemd is running and enable SSH
Write-Host "`n[4/6] Enabling SSH service via systemd..." -ForegroundColor Yellow
wsl -u root bash -c @"
echo 'PID 1 is:' `$(ps -p 1 -o comm=)
systemctl enable --now ssh 2>&1
systemctl status ssh --no-pager 2>&1 | head -8
"@

# Step 5: Generate SSH keys for the HP user
Write-Host "`n[5/6] Generating SSH keys for dataops-labs..." -ForegroundColor Yellow
wsl bash -c @"
if [ -f ~/.ssh/id_ed25519 ]; then
    echo 'SSH key already exists'
    cat ~/.ssh/id_ed25519.pub
else
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -C 'dataops-labs@hp-laptop'
    echo 'Key generated:'
    cat ~/.ssh/id_ed25519.pub
fi
"@

# Step 6: Configure SSH to allow password auth temporarily (for ssh-copy-id)
Write-Host "`n[6/6] Ensuring SSH allows password auth for key copy..." -ForegroundColor Yellow
wsl -u root bash -c @"
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
echo 'SSH configured and restarted'
"@

# Final status
Write-Host "`n========================================" -ForegroundColor Green
Write-Host " HP Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nTailscale IP: " -NoNewline
wsl bash -c "tailscale ip -4 2>/dev/null || echo 'Run: sudo tailscale up'"
Write-Host "SSH Status:   " -NoNewline
wsl -u root bash -c "systemctl is-active ssh"
Write-Host "`nNow run setup_ssh_msi.sh on the MSI-laptop WSL terminal.`n" -ForegroundColor Cyan
