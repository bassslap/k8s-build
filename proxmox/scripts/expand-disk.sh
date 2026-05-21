#!/usr/bin/env bash
# Expand disk partition, LVM PV, LV, and filesystem
# Run this script on Ubuntu VMs if the disk was resized but not expanded

set -euo pipefail

echo "=== Disk Expansion Script ==="
echo "Current disk layout:"
lsblk
echo ""
df -h
echo ""

# Install cloud-guest-utils if not present
if ! command -v growpart &> /dev/null; then
    echo "Installing cloud-guest-utils..."
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cloud-guest-utils
fi

# Expand partition 3 on /dev/sda
echo "Expanding partition /dev/sda3..."
sudo growpart /dev/sda 3 || echo "Partition already at maximum size or growpart not needed"

# Resize physical volume
echo "Resizing physical volume..."
sudo pvresize /dev/sda3

# Extend logical volume to use all free space
echo "Extending logical volume..."
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# Resize the filesystem
echo "Resizing filesystem..."
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

echo ""
echo "=== Disk expansion complete ==="
echo "New disk layout:"
lsblk
echo ""
df -h
