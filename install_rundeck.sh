#!/usr/bin/env bash
# =============================================================================
# install_rundeck.sh — install and configure Rundeck
#
# Safe to re-run (idempotent).
#
# Usage:
#   sudo bash install_rundeck.sh
# =============================================================================
set -euo pipefail

echo "========================================"
echo " Rundeck Setup"
echo " Host: $(hostname)"
echo " Date: $(date)"
echo "========================================"

# -----------------------------------------------------------------------------
# Java 17
# -----------------------------------------------------------------------------
echo ""
echo "[1/6] Installing Java 17..."
sudo dnf install -y java-17-openjdk

# -----------------------------------------------------------------------------
# Rundeck repo
# -----------------------------------------------------------------------------
echo ""
echo "[2/6] Adding Rundeck repo..."
sudo tee /etc/yum.repos.d/rundeck.repo > /dev/null << 'REPO'
[rundeck]
name=Rundeck
baseurl=https://packages.rundeck.com/pagerduty/rundeck/rpm_any/rpm_any/$basearch
enabled=1
gpgcheck=0
REPO

# -----------------------------------------------------------------------------
# Install Rundeck
# -----------------------------------------------------------------------------
echo ""
echo "[3/6] Installing Rundeck..."
sudo dnf install -y rundeck

# -----------------------------------------------------------------------------
# Configure server URL
# -----------------------------------------------------------------------------
echo ""
echo "[4/6] Configuring server URL..."
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo sed -i "s|^grails.serverURL=.*|grails.serverURL=http://${PUBLIC_IP}:4440|" \
    /etc/rundeck/rundeck-config.properties
echo "    Server URL: http://${PUBLIC_IP}:4440"

# -----------------------------------------------------------------------------
# Enable & start
# -----------------------------------------------------------------------------
echo ""
echo "[5/6] Enabling and starting Rundeck..."
sudo systemctl enable rundeckd
sudo systemctl start rundeckd

# -----------------------------------------------------------------------------
# Wait for service
# -----------------------------------------------------------------------------
echo ""
echo "[6/6] Waiting for Rundeck to start (up to 90s)..."
for i in $(seq 1 18); do
    if sudo systemctl is-active --quiet rundeckd; then
        echo "Rundeck is running."
        break
    fi
    echo "  waiting... ($i/18)"
    sleep 5
done

echo ""
echo "========================================"
echo " Rundeck Ready"
echo " URL:      http://${PUBLIC_IP}:4440"
echo " Username: admin"
echo " Password: admin"
echo "========================================"
