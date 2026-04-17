#!/usr/bin/env python3
# =============================================================================
# show_inventory.py — pretty-print ansible-inventory --list output
#
# Usage:
#   ansible-inventory -i inventory/aws_ec2.yml --list | python3 tools/show_inventory.py
# =============================================================================

import sys
import json

inv = json.load(sys.stdin)

total = 0
for group, data in sorted(inv.items()):
    if not group.startswith("vm_"):
        continue
    if not isinstance(data, dict):
        continue
    hosts = data.get("hosts", [])
    if not hosts:
        continue
    print(f"\n[{group}] — {len(hosts)} instance(s)")
    for h in hosts:
        print(f"  {h}")
    total += len(hosts)

print(f"\nTotal: {total} instance(s)")
