#!/bin/bash

rg="test-rg"
vnet="ERP-Servers-Vnet"

# Create Reource Group
az group create \
    --name $rg \
    --location uksouth

# Create VNet and associated Subnets
az network vnet create \
    --resource-group $rg \
    --name $vnet \
    --address-prefixes 10.0.0.0/16 \
    --location uksouth

az network vnet subnet create \
    --resource-group $rg \
    --vnet-name $vnet \
    --name ERP-Applications \
    --address-prefixes 10.0.0.0/24

az network vnet subnet create \
    --resource-group $rg \
    --vnet-name $vnet \
    --name ERP-Databases \
    --address-prefixes 10.0.1.0/24

az network vnet subnet list \
    --resource-group $rg \
    --vnet-name $vnet \
    --output table

# Create NSG
az network nsg create \
    --resource-group $rg \
    --name ERP-Servers-NSG

# Create VM's (Ubuntu)
wget -N https://raw.githubusercontent.com/MicrosoftDocs/mslearn-secure-and-isolate-with-nsg-and-service-endpoints/master/cloud-init.yml && \
az vm create \
    --resource-group $rg \
    --name AppServer \
    --vnet-name $vnet \
    --subnet ERP-Applications \
    --nsg ERP-Servers-NSG \
    --image Ubuntu2204 \
    --size Standard_DS1_v2 \
    --generate-ssh-keys \
    --admin-username azureuser \
    --custom-data cloud-init.yml \
    --no-wait \
    --admin-password <password>

az vm create \
    --resource-group $rg \
    --name DataServer \
    --vnet-name $vnet \
    --subnet ERP-Databases \
    --nsg ERP-Servers-NSG \
    --size Standard_DS1_v2 \
    --image Ubuntu2204 \
    --generate-ssh-keys \
    --admin-username azureuser \
    --custom-data cloud-init.yml \
    --no-wait \
    --admin-password <password>  

  # Confirm VM's are running
  az vm list \
    --resource-group $rg \
    --show-details \
    --query "[*].{Name:name, Provisioned:provisioningState, Power:powerState}" \
    --output table

# List IP address of VM's
az vm list \
    --resource-group $rg \
    --show-details \
    --query "[*].{Name:name, PrivateIP:privateIps, PublicIP:publicIps}" \
    --output table

# Store public IP of VM's for later use
APPSERVERIP="$(az vm list-ip-addresses \
                 --resource-group $rg \
                 --name AppServer \
                 --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
                 --output tsv)"

DATASERVERIP="$(az vm list-ip-addresses \
                 --resource-group $rg \
                 --name DataServer \
                 --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
                 --output tsv)"

# Connect to the VM's (Connection should fail beacuse of default rules)
ssh azureuser@$APPSERVERIP -o ConnectTimeout=5
ssh azureuser@$DATASERVERIP -o ConnectTimeout=5

# Create Security rule for SSH
# create a new inbound security rule to enable SSH access
az network nsg rule create \
    --resource-group $rg \
    --nsg-name ERP-Servers-NSG \
    --name AllowSSHRule \
    --direction Inbound \
    --priority 100 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 22 \
    --access Allow \
    --protocol Tcp \
    --description "Allow Inbound SSH"

# Attempt to connect (Should work now!!)
ssh azureuser@APPSERVERIP -o ConnectionTimeout=5
ssh azureuser@DATASERVERIP -o ConnectionTimeout=5

# create a new inbound security rule to deny HTTP access over port 80
az network nsg rule create \
    --resource-group $rg \
    --nsg-name ERP-Servers-NSG \
    --name httpRule \
    --direction Inbound \
    --priority 150 \
    --source-address-prefixes '10.0.1.4' \
    --source-port-ranges '*' \
    --destination-address-prefixes '10.0.0.4' \
    --destination-port-ranges 80 \
    --access Deny \
    --protocol Tcp \
    --description "Deny from DataServer to AppServer on port 80"

# Test rule

ssh -t azureuser@$APPSERVERIP 'wget http://10.0.1.4; exit; bash'
# (Should return 200 Ok - messge)

ssh -t azureuser@$DATASERVERIP 'wget http://10.0.0.4; exit; bash'
# (Should return - Connection timed out - message)

# -------------------------------------------------

# Create a new ASG
az network asg create \
    --resource-group $rg \
    --name ERP-DB-Servers-ASG

# Associate DB Server with ASG
az network nic ip-config update \
    --resource-group $rg \
    --application-security-groups ERP-DB-Servers-ASG \
    --name ipconfigDataServer \
    --nic-name DataServerVMNic \
    --vnet-name $vnet \
    --subnet ERP-Databases

# Update Http Rule on NSG
az network nsg rule update \
    --resource-group $rg \
    --nsg-name ERP-Servers-NSG \
    --name httpRule \
    --direction Inbound \
    --priority 150 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --source-asgs ERP-DB-Servers-ASG \
    --destination-address-prefixes '10.0.0.4' \
    --destination-port-ranges 80 \
    --access Deny \
    --protocol Tcp \
    --description "Deny from DataServer to AppServer on port 80 using ASG"

# Clean up
az group delete \
    --name test-rg \
    -- yes \
    --no-wait

