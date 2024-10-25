#!/bin/bash

# Connect to Azure
az login

# check Azure Version and libraries and upgrade
az version
az upgrade

# Create a resource group
az group create \
    --name test-rg \
    --location uksouth

# Create a Virtual Network and Subnet
az network vnet create \
    --name vnet-1 \
    --resource-group test-rg \
    --address-prefix 10.0.0.0/16 \
    --subnet-name subnet-1 \
    --subnet-prefixes 10.0.0.0/24

# Display the details of the newly created VNet
az network vnet show \
    --resource-group test-rg \
    --name vnet-1

# ----- Deploy Bastion -----
# Create a Bastion subnet
az network vnet subnet create \
    --name AzureBastionSubnet \
    --resource-group test-rg \
    --vnet-name vnet-1 \
    --subnet-prefix 10.0.1.0/26

# Create a PublicIP address for Bastion
az network public-ip create \
    --resource-group test-rg \
    --name bstion-public-ip \
    --sku Standard \
    --location uksouth \
    --zone 1,2,3

# Create the Bastion host
az network bastion create \
    --name bastion \
    --public-ip-address bastion-public-ip \
    --resource-group test-rg \
    --vnet-name vnet-1 \
    --location uksouth

# -----------------------------

# Create VM's for testing

az vm create \
    --resource-group test-rg \
    --admin-username azureuser \
    --authentication-type password \
    --name vm-1 \
    --image Ubuntu2204 \
    --public-ip-address ""

az vm create \
    --resource-group test-rg \
    --admin-username azureuser \
    --authentication-type password \
    --name vm-2 \
    --image Ubuntu2204 \
    --public-ip-address "" \
    --no-wait       # Create  the VM in the backgroud


# ---------------------------------
# Use the portal to connect to the VM's using bastion
# Run the following command on the VM's to test.
# From vm-1 : ping -c 4 vm-2
# From vm-2 : ping -c 4 vm-1