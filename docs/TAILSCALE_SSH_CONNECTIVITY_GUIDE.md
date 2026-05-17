# Tailscale + SSH Connectivity Guide

**MSI-Laptop ↔ HP-Laptop — Bidirectional Remote Access via WSL2**

| Machine | Hostname | WSL User | Tailscale IP | OS |
|---------|----------|----------|--------------|-----|
| **MSI** | `msi-laptop` | `dataops-lab` | `100.122.21.119` | Ubuntu Noble 24.04 (WSL2) |
| **HP** | `21LAPBRJ401CJ7H` | `dataops-labs` | `100.117.123.61` | Ubuntu Jammy 22.04 (WSL2) |

---

## 1. Service Health Check

Run these checks whenever you suspect connectivity issues.

### 1.1 Tailscale

#### On MSI (WSL terminal)

```bash
# Check if tailscaled is running
sudo systemctl status tailscaled --no-pager

# Check Tailscale network status
tailscale status

# Check your Tailscale IP
tailscale ip -4
```

#### On HP (WSL terminal)

```bash
# HP doesn't have systemd — check with ps
ps aux | grep tailscaled

# Check Tailscale network status
tailscale status

# Check your Tailscale IP
tailscale ip -4
```

#### ✅ Expected Output (both machines)

```
100.122.21.119  msi-laptop       cloud.labs.brazil@  linux  -
100.117.123.61  21lapbrj401cj7h  cloud.labs.brazil@  linux  idle
```

#### ❌ If Tailscale is NOT running

**On MSI:**
```bash
sudo systemctl start tailscaled
sudo tailscale up
```

**On HP:**
```bash
sudo tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=41641 &
sudo tailscale up
```

#### ❌ If Tailscale is NOT installed

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --auth-key=<YOUR_AUTH_KEY>
```

> Get your auth key from: https://login.tailscale.com/admin/settings/keys

---

### 1.2 SSH Server (sshd)

#### On MSI (has systemd)

```bash
# Check SSH status
sudo systemctl status ssh --no-pager

# Expected: "active (running)"
```

**If NOT running:**
```bash
sudo systemctl start ssh
```

**If NOT installed:**
```bash
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

#### On HP (no systemd)

```bash
# Check if sshd process is running
ps aux | grep sshd | grep -v grep

# Expected: "/usr/sbin/sshd" process listed
```

**If NOT running:**
```bash
sudo mkdir -p /run/sshd
sudo /usr/sbin/sshd
```

**If NOT installed:**
```bash
sudo apt install -y openssh-server
sudo mkdir -p /run/sshd
sudo /usr/sbin/sshd
```

---

### 1.3 Quick Health Check (One-Liner)

#### From MSI — check everything:
```bash
echo "=== TAILSCALE ===" && tailscale status && echo "" && echo "=== LOCAL SSH ===" && sudo systemctl is-active ssh && echo "" && echo "=== PING HP ===" && tailscale ping --c 1 100.117.123.61 && echo "" && echo "=== SSH TO HP ===" && ssh -o ConnectTimeout=5 hp 'echo "OK - $(hostname)"'
```

#### From HP — check everything:
```bash
echo "=== TAILSCALE ===" && tailscale status && echo "" && echo "=== LOCAL SSH ===" && ps aux | grep sshd | grep -v grep | head -1 && echo "" && echo "=== PING MSI ===" && tailscale ping --c 1 100.122.21.119 && echo "" && echo "=== SSH TO MSI ===" && ssh -o ConnectTimeout=5 msi 'echo "OK - $(hostname)"'
```

---

## 2. Connecting Between Machines

### 2.1 MSI → HP

```bash
# Interactive SSH session
ssh hp

# Run a single command remotely
ssh hp 'ls -la ~/projects/'

# Copy file TO HP
scp myfile.txt hp:~/

# Copy file FROM HP
scp hp:~/remotefile.txt .

# Copy entire directory TO HP
scp -r ./my-project hp:~/projects/

# Port forwarding (access HP's port 8080 on localhost:8080)
ssh -L 8080:localhost:8080 hp

# Reverse port forwarding (expose MSI's port 3000 on HP)
ssh -R 3000:localhost:3000 hp
```

### 2.2 HP → MSI

```bash
# Interactive SSH session
ssh msi

# Run a single command remotely
ssh msi 'ls -la ~/projects/'

# Copy file TO MSI
scp myfile.txt msi:~/

# Copy file FROM MSI
scp msi:~/remotefile.txt .

# Copy entire directory TO MSI
scp -r ./my-project msi:~/projects/

# Port forwarding (access MSI's port 8080 on localhost:8080)
ssh -L 8080:localhost:8080 msi
```

### 2.3 Using rsync (Recommended for Large Transfers)

```bash
# Sync a folder from MSI to HP
rsync -avz --progress ./project/ hp:~/project/

# Sync a folder from HP to MSI
rsync -avz --progress hp:~/project/ ./project/

# Dry run (preview what would be copied)
rsync -avzn ./project/ hp:~/project/
```

---

## 3. SSH Configuration Reference

### MSI SSH Config (`~/.ssh/config`)

```
Host hp
    HostName 100.117.123.61
    User dataops-labs
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    ServerAliveInterval 30

Host msi
    HostName 100.122.21.119
    User dataops-lab
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    ServerAliveInterval 30
```

### HP SSH Config (`~/.ssh/config`)

```
Host msi
    HostName 100.122.21.119
    User dataops-lab
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    ServerAliveInterval 30

Host hp
    HostName 100.117.123.61
    User dataops-labs
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    ServerAliveInterval 30
```

---

## 4. Auto-Start on WSL Boot

### MSI (Already configured ✅)

MSI has `systemd=true` in `/etc/wsl.conf`. Both `tailscaled` and `ssh` services are enabled and start automatically.

### HP (Manual Start Required ⚠️)

HP's WSL does not have systemd enabled. Services must be started manually after each WSL restart.

#### Option A: Enable systemd (Recommended)

Run from **HP's Windows PowerShell**:
```powershell
wsl -u root bash -c "cat > /etc/wsl.conf << 'EOF'
[boot]
systemd=true

[user]
default=dataops-labs
EOF"

# Restart WSL
wsl --shutdown
```

Then open WSL again and enable services:
```bash
sudo systemctl enable --now ssh
sudo systemctl enable --now tailscaled
```

After this, both services auto-start on every WSL boot.

#### Option B: Startup script (If systemd can't be enabled)

Create `/home/dataops-labs/start-services.sh`:
```bash
#!/bin/bash
sudo mkdir -p /run/sshd
sudo /usr/sbin/sshd
sudo tailscaled --state=/var/lib/tailscale/tailscaled.state \
  --socket=/run/tailscale/tailscaled.sock --port=41641 &
sleep 2
sudo tailscale up
echo "Services started: sshd + tailscale"
```

```bash
chmod +x ~/start-services.sh
```

Run it every time you open WSL:
```bash
~/start-services.sh
```

Or add to your `.bashrc` for auto-start:
```bash
echo '[ -z "$(pgrep sshd)" ] && ~/start-services.sh' >> ~/.bashrc
```

---

## 5. Troubleshooting

### "Connection refused" on SSH

```bash
# Service isn't running. Start it:
# MSI:
sudo systemctl start ssh
# HP:
sudo mkdir -p /run/sshd && sudo /usr/sbin/sshd
```

### "Permission denied (publickey)"

```bash
# Keys aren't set up. Re-copy:
# From MSI:
ssh-copy-id dataops-labs@100.117.123.61
# From HP:
ssh-copy-id dataops-lab@100.122.21.119
```

### "No route to host" or timeout

```bash
# Tailscale isn't connected. Check:
tailscale status

# If offline, re-authenticate:
sudo tailscale up
```

### "Host key verification failed"

```bash
# Remove stale host key:
ssh-keygen -R 100.117.123.61  # for HP
ssh-keygen -R 100.122.21.119  # for MSI
```

### WSL shut down unexpectedly

WSL auto-shuts down after ~8 seconds of inactivity. To prevent this:

```powershell
# In Windows, create %USERPROFILE%\.wslconfig:
[wsl2]
vmIdleTimeout=-1
```

Or keep a process running (e.g., `tmux` or `screen` session).

### Tailscale direct connection vs relay

```bash
# Check if connection is direct or relayed
tailscale ping 100.117.123.61

# If "via DERP" — connection works but is relayed through Tailscale servers
# If "direct" — optimal peer-to-peer connection
# Both work fine; direct is just faster
```

---

## 6. Network Diagram

```
┌─────────────────────────┐         Tailscale          ┌─────────────────────────┐
│       MSI-LAPTOP        │        VPN Tunnel           │      HP-LAPTOP          │
│                         │◄───────────────────────────►│                         │
│  Windows 11             │                             │  Windows 11             │
│  └─ WSL2 (Ubuntu 24.04) │                             │  └─ WSL2 (Ubuntu 22.04) │
│     ├─ tailscaled ✅     │                             │     ├─ tailscaled ✅     │
│     ├─ sshd ✅           │                             │     ├─ sshd ✅           │
│     ├─ User: dataops-lab │                             │     ├─ User: dataops-labs│
│     └─ IP: 100.122.21.119│                            │     └─ IP: 100.117.123.61│
│                         │    ssh hp ──────────────►   │                         │
│                         │   ◄──────────────── ssh msi │                         │
└─────────────────────────┘                             └─────────────────────────┘
```

---

*Last updated: 2026-05-08 | Author: Automated setup via Antigravity*
