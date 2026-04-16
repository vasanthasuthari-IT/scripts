#!/usr/bin/env bash
# =============================================================================
# initial_setup.sh — baseline package setup for all VMs
#
# Installs common utilities needed before any app-specific provisioning.
# Safe to re-run (dnf is idempotent).
#
# Usage:
#   sudo bash initial_setup.sh
# =============================================================================
set -euo pipefail

echo "========================================"
echo " Initial VM Setup"
echo " Host: $(hostname)"
echo " Date: $(date)"
echo "========================================"

# -----------------------------------------------------------------------------
# System update
# -----------------------------------------------------------------------------
echo ""
echo "[1/4] Updating system packages..."
sudo dnf update -y

# -----------------------------------------------------------------------------
# Core utilities
# -----------------------------------------------------------------------------
echo ""
echo "[2/4] Installing core utilities..."
sudo dnf install -y \
    wget \
    curl \
    vim \
    git \
    unzip \
    tree \
    net-tools \
    bind-utils \
    telnet \
    lsof \
    tcpdump \
    nc \
    jq

# -----------------------------------------------------------------------------
# System tuning
# -----------------------------------------------------------------------------
echo ""
echo "[3/4] Applying system settings..."

# Increase open file limits
sudo tee /etc/security/limits.d/99-custom.conf > /dev/null << 'EOF'
* soft nofile 65536
* hard nofile 65536
EOF

# Persist hostname resolution improvements
sudo tee /etc/sysctl.d/99-custom.conf > /dev/null << 'EOF'
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 10
EOF
sudo sysctl --system > /dev/null

# -----------------------------------------------------------------------------
# Verify
# -----------------------------------------------------------------------------
echo ""
echo "[4/4] Verifying installed tools..."
for tool in wget curl vim git unzip tree htop netstat dig telnet lsof jq; do
    if command -v "$tool" &>/dev/null; then
        echo "  OK  $tool"
    else
        echo "  MISSING  $tool"
    fi
done

echo ""
echo "========================================"
echo " Setup complete on $(hostname)"
echo "========================================"
