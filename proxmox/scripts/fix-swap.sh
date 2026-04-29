#!/usr/bin/env bash
# Fix swap on all nodes

MASTER_IP="${1:-10.100.1.101}"
WORKER1_IP="${2:-10.100.1.102}"
WORKER2_IP="${3:-10.100.1.103}"

FIX_SWAP='
sudo swapoff -a
sudo sed -i "/swap/d" /etc/fstab
if [ -f /swap.img ]; then
  sudo rm -f /swap.img
fi
sudo systemctl restart kubelet
'

echo "Fixing swap on all nodes..."

for ip in $MASTER_IP $WORKER1_IP $WORKER2_IP; do
  echo "→ Fixing $ip..."
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR ubuntu@$ip "$FIX_SWAP" &
done

wait
echo "✓ All nodes fixed. Waiting for cluster to stabilize..."
sleep 20

echo ""
echo "Cluster status:"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR ubuntu@$MASTER_IP "kubectl get nodes -o wide"
