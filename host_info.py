#!/usr/bin/env python3
# =============================================================================
# host_info.py — print hostname, private and public IPs
#
# Usage:
#   python3 host_info.py                  # info for current host
#   python3 host_info.py myserver.com     # info for a specific hostname
# =============================================================================

import socket
import sys
import urllib.request


def get_public_ip() -> str:
    try:
        with urllib.request.urlopen(
            "http://169.254.169.254/latest/meta-data/public-ipv4", timeout=2
        ) as r:
            return r.read().decode()
    except Exception:
        return "n/a"


def get_private_ip(hostname: str) -> str:
    try:
        return socket.gethostbyname(hostname)
    except socket.gaierror:
        return "n/a (could not resolve)"


def local_private_ip() -> str:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]
    finally:
        s.close()


target = sys.argv[1] if len(sys.argv) > 1 else None

if target:
    hostname   = target
    private_ip = get_private_ip(target)
    public_ip  = "n/a (remote host)"
else:
    hostname   = socket.getfqdn()
    private_ip = local_private_ip()
    public_ip  = get_public_ip()

print("=" * 40)
print(f"  Hostname   : {hostname}")
print(f"  Private IP : {private_ip}")
print(f"  Public IP  : {public_ip}")
print("=" * 40)
