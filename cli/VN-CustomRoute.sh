#!/bin/bash

# Parameters
rgName='customRoute-RG'
location='uksouth'

# Create a resource group
az group create --name $rgName --location $location

# create vnet
az network vnet create \
--resource-group $rgName \
--name vnet \
--address-prefixes 10.0.0.0/16

az network vnet subnet create \
--resource-group $rgName \
--vnet-name vnet \
--name publicsubnet \
--address-prefixes 10.0.0.0/24

az network vnet subnet create \
--resource-group $rgName \
--vnet-name vnet \
--name privatesubnet \
--address-prefixes 10.0.1.0/24

az network vnet subnet create \
--resource-group $rgName \
--vnet-name vnet \
--name dmzsubnet \
--address-prefixes 10.0.2.0/24

# Show subnets 
az network vnet subnet list \
--resource-group $rgName \
--vnet-name vnet \
--output table

# ----------------------------

# Create a route table and custom route
az network route-table create \
--resource-group $rgName \
--name publictable \
--disable-bgp-route-propagation false

az network route-table route create \
--resource-group $rgName \
--route-table-name publictable \
--name productionsubnet \
--address-prefix 10.0.1.0/24 \
--next-hop-type VirtualAppliance \
--next-hop-ip-address 10.0.2.4

# Associate route table with subnet
az network vnet subnet update \
--resource-group $rgName \
--vnet-name vnet \
--name publicsubnet \
--route-table publictable

# ----------------------------------------

# Create a VM in dmxsubnet
az vm create \
--resource-group $rgName \
--name nva \
--vnet-name vnet \
--subnet dmzsubnet \
--image Ubuntu2204 \
--admin-username azureuser \
--admin-password 'Th3@zur3Us3r!'

# Enable IP forwarding on the Nic
NICID=$(az vm nic list --resource-group $rgName --vm-name nva --query "[].{id:id}" --output tsv)
echo $NICID

NICNAME=$(az vm nic show --resource-group $rgName --vm-name nva --nic $NICID --query "{name:name}" --output tsv)
echo $NICNAME

az network nic update \
--name $NICNAME \
--resource-group $rgName \
--ip-forwarding true

# Enable IP Forwarding in the Appliace
## Get public IP addresses of the NVA
NVAIP="$(az vm list-ip-addresses --resource-group $rgName --name nva --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" --output tsv)"
echo $NVAIP
## Enable IP Forwarding in the NVA
ssh -t -o StrictHostKeyChecking=no azureuser@$NVAIP 'sudo sysctl -w net.ipv4.ip_forward=1; exit;'

# --------------------------------------
# create a file named cloud-init.txt
# --------------------------------------

#cloud-config
package_upgrade: true
packages:
   - inetutils-traceroute
# ---------------------------------------

# Create public and private VM
az vm create \
--resource-group $rgName \
--name public \
--vnet-name vnet \
--subnet publicsubnet \
--image Ubuntu2204 \
--admin-username azureuser \
--no-wait \
--custom-data cloud-init.txt \
--admin-password 'Th3@zur3Us3r!'

az vm create \
--resource-group $rgName \
--name private \
--vnet-name vnet \
--subnet privatesubnet \
--image Ubuntu2204 \
--admin-username azureuser \
--no-wait \
--custom-data cloud-init.txt \
--admin-password 'Th3@zur3Us3r!'

# Check the VM's are running
watch -d -n 5 "az vm list \
    --resource-group $rgName \
    --show-details \
    --query '[*].{Name:name, ProvisioningState:provisioningState, PowerState:powerState}' \
    --output table"


# ---------------------------------------------

# Get public IP's of the VM's
PUBLICIP="$(az vm list-ip-addresses --resource-group $rgName --name public --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" --output tsv)"
echo $PUBLICIP

PRIVATEIP="$(az vm list-ip-addresses --resource-group $rgName --name private --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" --output tsv)"
echo $PRIVATEIP

# Traceroute from public to private
ssh -t -o StrictHostKeyChecking=no azureuser@$PUBLICIP 'traceroute private --type=icmp; exit'

# Traceroute from private to public
ssh -t -o StrictHostKeyChecking=no azureuser@$PRIVATEIP 'traceroute public --type=icmp; exit'
