#!/usr/bin/env bash
# =============================================================================
# install_rundeck.sh — run Rundeck via Podman (pre-installed on RHEL 10)
#
# Usage:
#   sudo bash install_rundeck.sh
# =============================================================================
set -euo pipefail

echo "========================================"
echo " Rundeck Setup (Docker/Podman)"
echo " Host: $(hostname)"
echo " Date: $(date)"
echo "========================================"

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "[1/3] Pulling Rundeck image..."
podman pull docker.io/rundeck/rundeck:5.20.0-20260402

echo ""
echo "[2/3] Starting Rundeck container..."
sudo systemctl stop rundeckd 2>/dev/null || true
sudo systemctl disable rundeckd 2>/dev/null || true
podman rm -f rundeck 2>/dev/null || true

podman run -d \
    --name rundeck \
    --restart always \
    -p 4440:4440 \
    -e RUNDECK_GRAILS_URL=http://${PUBLIC_IP}:4440 \
    -e RUNDECK_SERVER_ADDRESS=0.0.0.0 \
    docker.io/rundeck/rundeck:5.20.0-20260402

echo ""
echo "[3/3] Waiting for Rundeck to be ready (up to 90s)..."
for i in $(seq 1 18); do
    if curl -sf http://localhost:4440/api/14/system/info -o /dev/null 2>/dev/null; then
        echo "Rundeck is ready."
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
