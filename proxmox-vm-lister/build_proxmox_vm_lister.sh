#!/bin/bash

# Step 1: Change directory to /opt/
echo "Changing directory to /opt/..."
cd /opt/ || { echo "Failed to change directory to /opt/"; exit 1; }

# Step 2: Build the Go program
echo "Building proxmox-vm-lister.go..."
go build -o proxmox-vm-lister proxmox-vm-lister.go || { echo "Build failed"; exit 1; }

# Step 3: Make the binary executable
echo "Making proxmox-vm-lister executable..."
chmod +x /opt/proxmox-vm-lister || { echo "Failed to make binary executable"; exit 1; }

echo "Script completed successfully!"
