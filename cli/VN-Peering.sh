#!/bin/bash

# Define parameters
rgName='az104-peering-RG'
location1='northeurope'
location2='westeurope'
userName='azureuser'
userPassword='Th3@zur3Us3r!'

# Create Resource Group
az group create \
    --name $rgName \
    --location $location1

# Create VNets
az network vnet create \
    --resource-group $rgName \
    --name SalesVnet \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name Apps \
    --subnet-prefixes 10.1.1.0/24 \
    --location $location1

az network vnet create \
    --resource-group $rgName \
    --name MarketingVnet \
    --address-prefixes 10.2.0.0/16 \
    --subnet-name Apps \
    --subnet-prefixes 10.2.1.0/24 \
    --location $location1

az network vnet create \
    --resource-group $rgName \
    --name ResearchVnet \
    --address-prefixes 10.3.0.0/16 \
    --subnet-name Data \
    --subnet-prefixes 10.3.1.0/24 \
    --location $location2

# Confirm configuration
az network vnet list \
    --query "[?contains(provisioningState, 'Succeeded')]" \
    --output table

# Create VM
az vm create \
    --resource-group $rgName \
    --name SavlesVM \
    --location $location1 \
    --vnet-name SalesVnet \
    --subnet Apps \
    --image Ubuntu2204 \
    --admin-username $userName \
    --admin-password $userPassword \
    --no-wait

az vm create \
    --resource-group $rgName \
    --name MarketingVM \
    --location $location1 \
    --vnet-name MarketingVnet \
    --subnet Apps \
    --image Ubuntu2204 \
    --admin-username $userName \
    --admin-password $userPassword \
    --no-wait

az vm create \
    --resource-group $rgName \
    --name ResearchVM \
    --location $location2 \
    --vnet-name ResearchVnet \
    --subnet Data \
    --image Ubuntu2204 \
    --admin-username $userName \
    --admin-password $userPassword \
    --no-wait

# Confirm Vm's are running
watch -d -n 5 "az vm list \
    --resource-group $rgName \
    --show-details \
    --query '[*].{Name:name, ProvisioningState:provisioningState, PowerState:powerState}' \
    --output table"

# Configure Peering

# SalesVnet to MarketingVnet
az network vnet peering create \
    --resource-group $rgName \
    --name SalesVnet-to-MarketingVnet \
    --vnet-name SalesVnet \
    --remote-vnet MarketingVnet \
    --allow-vnet-access

az network vnet peering create \
    --resource-group $rgName \
    --name MarketingVnet-to-SalesVnet \
    --vnet-name MarketingVnet \
    --remote-vnet SalesVnet \
    --allow-vnet-access

# Check peering status between Sales and Marketing
az network vnet peering list \
    --resource-group $rgName \
    --vnet-name SalesVnet \
    --query "[].{Name:name, Resource:resourceGroup, PeeringState:peeringState, AllowVnetAccess:allowVirtualNetworkAccess}" \
    --output table

az network vnet peering list \
    --resource-group $rgName \
    --vnet-name MarketingVnet \
    --query "[].{Name:name, Resource:resourceGroup, PeeringState:peeringState, AllowVnetAccess:allowVirtualNetworkAccess}" \
    --output table

# Create a peering connection between Marketing and Research
az network vnet peering create \
    --resource-group $rgName \
    --name MarketingVnet-to-ResearchVnet \
    --vnet-name MarketingVnet \
    --remote-vnet ResearchVnet \
    --allow-vnet-access

az network vnet peering create \
    --resource-group $rgName \
    --name ResearchVnet-to-MarketingVnet \
    --vnet-name ResearchVnet \
    --remote-vnet MarketingVnet \
    --allow-vnet-access

# Check peering status between Sales and Marketing
az network vnet peering list \
    --resource-group $rgName \
    --vnet-name ResearchVnet \
    --query "[].{Name:name, Resource:resourceGroup, PeeringState:peeringState, AllowVnetAccess:allowVirtualNetworkAccess}" \
    --output table

az network vnet peering list \
    --resource-group $rgName \
    --vnet-name MarketingVnet \
    --query "[].{Name:name, Resource:resourceGroup, PeeringState:peeringState, AllowVnetAccess:allowVirtualNetworkAccess}" \
    --output table

# -----------------------------------

# check effective routes

az network nic show-effective-route-table \
    --resource-group $rgName \
    --name SalesVMVMNic \
    --output table

az network nic show-effective-route-table \
    --resource-group $rgName \
    --name ResearchVMVMNic \
    --output table

az network nic show-effective-route-table \
    --resource-group $rgName \
    --name MarketingVMVMNic \
    --output table

# -------------------------

# List VM IP address
az vm list \
    --resource-group $rgName \
    --query "[*].{Name:name, PrivateIP:privateIps, PublicIP:publicIps}" \
    --output table

# Connect to VM via public ip
ssh -o StrictHostKeyChecking=no azureuser@<SalesVM public IP>
# Connect to VM via private ip
ssh -o StrictHostKeyChecking=no azureuser@<MarketingVM private IP>
ssh -o StrictHostKeyChecking=no azureuser@<ResearchVM private IP>
