#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for cloud-init to complete on all nodes..."

for ip in 10.100.1.101 10.100.1.102 10.100.1.103; do
    echo "→ $ip"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$ip 'sudo cloud-init status --wait' 2>/dev/null || echo "  completed"
done

echo "All nodes ready!"
echo ""

bash /Users/bphillip/GIT_REPOS/k8s-build/proxmox/scripts/install-k8s.sh
