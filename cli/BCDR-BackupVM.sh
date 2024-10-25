#!/bin/bash

# Create a resource group
RGROUP=$(az group create --name vmbackups --location westus2 --output tsv --query name)

# create the NorthwindInternal virtual network and the NorthwindInternal1 subnet.
az network vnet create --resource-group $RGROUP --name NorthwindInternal --address-prefixes 10.0.0.0/16 --subnet-name NorthwindInternal1 --subnet-prefixes 10.0.0.0/24

# Create the NW-APP01 virtual machine
az vm create --resource-group $RGROUP --name NW-APP01 --size Standard_DS1_v2 --public-ip-sku Standard --vnet-name NorthwindInternal --subnet NorthwindInternal1 --image Win2016Datacenter --admin-username admin123 --no-wait --admin-password <password>

# Create the NW-RHEL01 virtual machine
az vm create --resource-group $RGROUP --name NW-RHEL01 --size Standard_DS1_v2 --image RedHat:RHEL:8-gen2:latest --authentication-type ssh --generate-ssh-keys --vnet-name NorthwindInternal --subnet NorthwindInternal1

# create the azure-backup vault
az backup vault create --resource-group vmbackups --location westus2 --name azure-backup

# enable a backup for the NW-APP01 virtual machine
az backup protection enable-for-vm --resource-group vmbackups --vault-name azure-backup --vm NW-APP01 --policy-name EnhancedPolicy

# Monitor the progress of the setup
az backup job list --resource-group vmbackups --vault-name azure-backup --output table

# Do an initial backup of the virtual machine
az backup protection backup-now --resource-group vmbackups --vault-name azure-backup --container-name NW-APP01 --item-name NW-APP01 --retain-until 18-10-2030 --backup-management-type AzureIaasVM

