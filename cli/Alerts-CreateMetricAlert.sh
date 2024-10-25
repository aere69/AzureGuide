#!/bin/bash

# Create a script to install and run stress on cpu
cat <<EOF > cloud-init.txt
#cloud-config
package_upgrade: true
packages:
- stress
runcmd:
- sudo stress --cpu 1
EOF

# Setup ubuntu VM and run cloud-init.tx
az vm create \
    --resource-group "[sandbox resource group name]" \
    --name vm1 \
    --location eastUS \
    --image Ubuntu2204 \
    --custom-data cloud-init.txt \
    --generate-ssh-keys

# Get VM resource ID
VMID=$(az vm show \
        --resource-group "[sandbox resource group name]" \
        --name vm1 \
        --query id \
        --output tsv)

# Create a new metric for VM CP > 80%
az monitor metrics alert create \
    --name "Cpu80PercentAlert" \
    --resource-group "[sandbox resource group name]" \
    --scopes $VMID \
    --condition "max percentage CPU > 80" \
    --description "Virtual machine is running at or greater than 80% CPU utilization" \
    --evaluation-frequency 1m \
    --window-size 1m \
    --severity 3

