#!/bin/bash

rg="Test-rg"
vnet="ERP-Servers"
appSubNet="ERP-Applications-Subnet"
dbSubNet="ERP-Databases-Subnet"
nsg="ERP-Servers-NSG"
asg="ERP-DB-Servers-ASG"

# Create Resource Group
az group create \
    --name $rg \
    --location uksouth

# Create Vnet and Subnets
az network vnet create \
    --resource-group $rg \
    --name $vnet \
    --Address-Prefixes 10.0.0.0/16 \
    --location uksouth

az network vnet subnet create \
    --resource-group $rg \
    --vnet-name $vnet \
    --name $appSubNet \
    --address-prefixes 10.0.0.0/24 

az network vnet subnet create \
    --rsource-group $rg \
    --vnet-name $vnet \
    --name $dbSubNet \
    --address-prefixes 10.0.1.0/24

az network vnet sbunet list \
    --resource-group $rg \
    --vnet-name $vnet \
    --output table

# Create a NSG
az network nsg create \
    --resource-group $rg \
    --name $nsg

# Create VM's (Ubuntu)
wget -N https://raw.githubusercontent.com/MicrosoftDocs/mslearn-secure-and-isolate-with-nsg-and-service-endpoints/master/cloud-init.yml && \
az vm create \
    --resource-group $rg \
    --name AppServer \
    --vnet-name $vnet \
    --subnet $appSubNet \
    --nsg $nsg \
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
    --subnet $dbSubNet \
    --nsg $nsg \
    --size Standard_DS1_v2 \
    --image Ubuntu2204 \
    --generate-ssh-keys \
    --admin-username azureuser \
    --custom-data cloud-init.yml \
    --no-wait \
    --admin-password <password>  

# Confirm VM's are created
az vm list \
    --resource-group $rg \
    --show-details \
    --query "[*].{Name:name, Provisioned:provisioningStatus, Power:powerState}" \
    --output table

az vm list \
    --rsource-group $rg \
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

# Create NSG Rules to allow SSH access 
az network nsg rule create \
    --resource-group $rg \
    --nssg-name $nsg \
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

# Create ASG
az network asg create \
    --resource-group $rg \
    --name $asg

# Create Http Rule on NSG using ASG
az network nsg rule create \
    --resource-group $rg \
    --nsg-name $nsg \
    --name httpRule \
    --direction Inbound \
    --priority 110 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --source-asgs $asg \
    --destination-address-prefixes '10.0.0.4' \
    --destination-port-ranges 80 \
    --access Deny \
    --protocol Tcp \
    --description "Deny http to AppServer port 80 using ASG"

# Associate DB Server with ASG
az network nic ip-config update \
    --resource-group $rg \
    --application-security-groups $asg \
    --name ipconfigDataServer \
    --nic-name DataServerVMNic \
    --vnet-name $vnet \
    --subnet $dbSubNet

 # Test rule
ssh -t azureuser@$APPSERVERIP 'wget http://10.0.1.4; exit; bash'
# (Should return 200 Ok - messge)

ssh -t azureuser@$DATASERVERIP 'wget http://10.0.0.4; exit; bash'
# (Should return - Connection timed out - message)
   
# Create an outbound rule to allow access to Storage
az network nsg rule create \
    --resource-group $rg \
    --nsg-name $nsg \
    --name Allow-Storage \
    --priority 190 \
    --direction Outbound \
    --source-address-prefixes "VirtualNetwork" \
    --source-port-ranges '*' \
    --destination-address-prefixess "Storage" \
    --source-port-ranges '*' \
    --access Allow \
    --protocol '*' \
    --description "Allow access to Azure Storage"

# Create an outbound rule to deny all internet access
az network nsg rule create \
    --resource-group $rg \
    --nsg-name $nsg \
    --name Deny_Internet \
    --direction Outbound \
    --source-address-prefixes "VirtualNetwork" \
    --source-port-ranges '*' \
    --destination-address-prefixes "Internet" \
    --destination-port-ranges '*' \
    --access Deny \
    --protocol Tcp \
    --description "Deny access to Internet from Vnet"

# Configure Storage Account and File Share
STORAGEACCT=$(az storage account create \
                --resource-group $rg \
                --name engineeringdocs$RANDOM \
                --sku Standard_LRS \
                --query "name" | tr -d '"')
STORAGEKEY=$(az storage account keys list \
                --resource-group $rg \
                --account-name $STORAGEACCT \
                --query "[0].value" | tr -d '"')

az storage share create \
    --account-name $STORAGEACCT \
    --account-key $STORAGEKEY \
    --name "erp-data-share"

# configure the storage account to be accessible only from database servers 
# by assigning the storage endpoint to the Databases subnet.
# ------------
# assign the Microsoft.Storage endpoint to the subnet
az network vnet subnet update \
    --resource-group $rg \
    --vnet-name $vnet \
    --name $dbSubNet \
    --service-enpoints Microsoft.Storage

# deny all access.
# After network access is denied, the storage account isn't accessible from any network.
az storage account update \
    --resource-group $rg \
    --name $STORAGEACCT \
    --default-action Deny

# To restrict access to the storage account.
# By default, storage accounts are open to accept all traffic. 
# You want only traffic from the Databases subnet to be able to access the storage.
az storage account network-rule add \
    --resource-group $rg \
    --account-name $STORAGEACCT \
    --vnet-name $vnet \
    --subnet $dbSubNet

# Test access to storage resources
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
                    
# attempt to mount the Azure file share
ssh -t azureuser@$APPSERVERIP \
    "mkdir azureshare; \
    sudo mount -t cifs //$STORAGEACCT.file.core.windows.net/erp-data-share azureshare \
    -o vers=3.0,username=$STORAGEACCT,password=$STORAGEKEY,dir_mode=0777,file_mode=0777,sec=ntlmssp; findmnt \
    -t cifs; exit; bash"

ssh -t azureuser@$DATASERVERIP \
    "mkdir azureshare; \
    sudo mount -t cifs //$STORAGEACCT.file.core.windows.net/erp-data-share azureshare \
    -o vers=3.0,username=$STORAGEACCT,password=$STORAGEKEY,dir_mode=0777,file_mode=0777,sec=ntlmssp;findmnt \
    -t cifs; exit; bash"

