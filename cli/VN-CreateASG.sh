#!/bin/bash

# creates a resource group in the westus2

az group create \
    --name test-rg \
    --location westus2

# creates a virtual named vnet-1

az network vnet create \
    --name vnet-1 \
    --resource-group test-rg \
    --address-prefixes 10.0.0.0/16

#  adds a subnet named subnet-1 to the virtual network and associates the nsg-1 network security group to it

az network vnet subnet create \
    --vnet-name vnet-1 \
    --resource-group test-rg \
    --name subnet-1 \
    --address-prefix 10.0.0.0/24

# Create an application security group

az network asg create \
    --resource-group test-rg \
    --name asg-web \
    --location westus2

az network asg create \
    --resource-group test-rg \
    --name asg-mgmt \
    --location westus2

# creates a network security group named nsg-1

# Create a network security group
az network nsg create \
    --resource-group test-rg \
    --name nsg-1

# associate the network security group with the subnet
 az network vnet subnet update \
    --resource-group test-rg \
    --vnet-name vnet-1 \
    --name subnet-1 \
    --network-security-group nsg-1

# creates a rule that allows traffic inbound from the internet to the 
# asg-web application security group over ports 80 and 443
az network nsg rule create \
    --resource-group test-rg \
    --nsg-name nsg-1 \
    --name Allow-Web-All \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --priority 100 \
    --source-address-prefix Internet \
    --source-port-range "*" \
    --destination-asgs "asg-web" \
    --destination-port-range 80 443

# creates a rule that allows traffic inbound from the Internet to the 
# asg-mgmt application security group over port 22
az network nsg rule create \
    --resource-group test-rg \
    --nsg-name nsg-1 \
    --name Allow-SSH-All \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --priority 110 \
    --source-address-prefix Internet \
    --source-port-range "*" \
    --destination-asgs "asg-mgmt" \
    --destination-port-range 22

# Create two VMs in the virtual network
az vm create \
    --resource-group test-rg \
    --name vm-web \
    --image Ubuntu2204 \
    --vnet-name vnet-1 \
    --subnet subnet-1 \
    --nsg "" \
    --admin-username azureuser \
    --authentication-type password \
    --assign-identity

az vm create \
    --resource-group test-rg \
    --name vm-mgmt \
    --image Ubuntu2204 \
    --vnet-name vnet-1 \
    --subnet subnet-1 \
    --nsg "" \
    --admin-username azureuser \
    --generate-ssh-keys \
    --assign-identity

# associate the network interface with the application security group.

# Retrieve the network interface name associated with the virtual machine
nic_name=$(az vm show --resource-group test-rg --name vm-web --query 'networkProfile.networkInterfaces[0].id' -o tsv | xargs basename)

# Associate the application security group with the network interface
az network nic ip-config update \
    --name ipconfigvm-web \
    --nic-name $nic_name \
    --resource-group test-rg \
    --application-security-groups asg-web

# Retrieve the network interface name associated with the virtual machine
nic_name=$(az vm show --resource-group test-rg --name vm-mgmt --query 'networkProfile.networkInterfaces[0].id' -o tsv | xargs basename)

# Associate the application security group with the network interface
az network nic ip-config update \
    --name ipconfigvm-mgmt \
    --nic-name $nic_name \
    --resource-group test-rg \
    --application-security-groups asg-mgmt

# Test the connection

export IP_ADDRESS=$(az vm show --show-details --resource-group test-rg --name vm-mgmt --query publicIps --output tsv)
ssh -o StrictHostKeyChecking=no azureuser@$IP_ADDRESS

# From mgmt connecto to web
ssh -o StrictHostKeyChecking=no azureuser@vm-web

# install the nginx web server on the vm-web VM
# Update package source
sudo apt-get -y update

# Install NGINX
sudo apt-get -y install nginx

# Exit from vm-web
# Retreive nginx welcome screent from vm-mgmt
curl vm-web

# Exit out of vm-mgmt
# Check web connection to vm-web
curl <vm-web-public-ip>

# Clean up
az group delete \
    --name test-rg \
    -- yes \
    --no-wait


