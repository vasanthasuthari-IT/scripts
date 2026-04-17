#!/usr/bin/env python3
# =============================================================================
# host_info.py — print hostname, private and public IPs of the current host
# =============================================================================

import socket
import urllib.request

def get_public_ip() -> str:
    try:
        url = "http://169.254.169.254/latest/meta-data/public-ipv4"
        with urllib.request.urlopen(url, timeout=2) as r:
            return r.read().decode()
    except Exception:
        return "n/a (not on AWS or no public IP)"

def get_private_ip() -> str:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]
    finally:
        s.close()

hostname   = socket.getfqdn()
private_ip = get_private_ip()
public_ip  = get_public_ip()

print("=" * 40)
print(f"  Hostname   : {hostname}")
print(f"  Private IP : {private_ip}")
print(f"  Public IP  : {public_ip}")
print("=" * 40)
