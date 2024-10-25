#!/bin/bash

# Variables
resourceGroup="aere69-vnet-RG"
location="uksouth"
vmName1="myWindowsVM1"
vmName2="myWindowsVM2"
image="Win2022DatacenterAzureEditionCore"
adminUsername="azureuser"
adminPassword="Th3@zur3Us3r!"

# Create Resource Group
az group create \
    --name $resourceGroup \
    --location $location

# Create a Vnet
az network vnet create \
    --name vnet1 \
    --resource-group $resourceGroup \
    --address-prefixes 10.1.0.0/16

# Create Subnet
az network vnet subnet create \
    --resource-group $resourceGroup \
    --vnet-name vnet1 \
    --name default \
    --address-prefixes 10.1.0.0/24

# Check subnet created
az network vnet subnet list \
    --resource-group $resourceGroup \
    --vnet-name vnet1 \
    --output table

# Create VM's open inbound RDP
# Create a virtual machine
az vm create \
  --resource-group $resourceGroup \
  --name $vmName1 \
  --image $image \
  --vnet-name vnet1 \
  --subnet default \
  --admin-username $adminUsername \
  --admin-password $adminPassword \
  --public-ip-sku Standard

# Open port 3389 to allow RDP traffic
az vm open-port --port 3389 --resource-group $resourceGroup --name $vmName1

# Create a virtual machine
az vm create \
  --resource-group $resourceGroup \
  --name $vmName2 \
  --image $image \
  --vnet-name vnet1 \
  --subnet default \
  --admin-username $adminUsername \
  --admin-password $adminPassword \
  --public-ip-sku Standard

# Open port 3389 to allow RDP traffic
az vm open-port --port 3389 --resource-group $resourceGroup --name $vmName2
