#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for VMs to fully boot..."

for i in {1..60}; do
    echo -n "Attempt $i/60: "
    all_ready=true
    
    for ip in 10.100.1.101 10.100.1.102 10.100.1.103; do
        if ! ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR ubuntu@$ip 'exit' 2>/dev/null; then
            all_ready=false
        fi
    done
    
    if $all_ready; then
        echo "✓ All VMs ready!"
        exit 0
    else
        echo "waiting..."
        sleep 5
    fi
done

echo "✗ Timeout waiting for VMs"
exit 1
