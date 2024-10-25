#!/bin/bash
# Usage: bash create-high-availability-vm-with-sets.sh <Resource Group Name>

RgName=$1
RgLocation=$2

date
# Create Resource Group
echo '------------------------------------------'
echo 'Creating a Resource Group for the Project'
az group create \
    --name $RgName \
    --location $RgLocation

# Create a Virtual Network for the VMs
echo '------------------------------------------'
echo 'Creating a Virtual Network for the VMs'
az network vnet create \
    --resource-group $RgName \
    --name bePortalVnet \
    --subnet-name bePortalSubnet 

# Create a Network Security Group
echo '------------------------------------------'
echo 'Creating a Network Security Group'
az network nsg create \
    --resource-group $RgName \
    --name bePortalNSG 

# Add inbound rule on port 80
echo '------------------------------------------'
echo 'Allowing access on port 80'
az network nsg rule create \
    --resource-group $RgName \
    --nsg-name bePortalNSG \
    --name Allow-80-Inbound \
    --priority 110 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --description "Allow inbound on port 80."

# Create the NIC
for i in `seq 1 2`; do
  echo '------------------------------------------'
  echo 'Creating webNic'$i
  az network nic create \
    --resource-group $RgName \
    --name webNic$i \
    --vnet-name bePortalVnet \
    --subnet bePortalSubnet \
    --network-security-group bePortalNSG
done 

# Create an availability set
echo '------------------------------------------'
echo 'Creating an availability set'
az vm availability-set create -n portalAvailabilitySet -g $RgName

# Create 2 VM's from a template
for i in `seq 1 2`; do
    echo '------------------------------------------'
    echo 'Creating webVM'$i
    az vm create \
        --admin-username azureuser \
        --resource-group $RgName \
        --name webVM$i \
        --nics webNic$i \
        --image Ubuntu2204 \
        --availability-set portalAvailabilitySet \
        --generate-ssh-keys \
        --custom-data cloud-init.txt
done

# Done
echo '--------------------------------------------------------'
echo '             VM Setup Script Completed'
echo '--------------------------------------------------------'

date
# Create Load Balancer PublicIP
echo '------------------------------------------'
echo 'Creating a the Load Balancer PublicIP'
az network public-ip create \
    --resource-group $RgName \
    --allocation-method Static \
    --name myPublicIP

# Create Load Balancer
echo '------------------------------------------'
echo 'Creating a the Load Balancer'
az network lb create \
    --resource-group $RgName \
    --name myLoadBalancer \
    --public-ip-address myPublicIP \
    --frontend-ip-name myFrontEndPool \
    --backend-pool-name myBackEndPool

# Create Load Balancer Health Probe
echo '------------------------------------------'
echo 'Creating a the Load Balancer Health Probe'
az network lb probe create \
    --resource-group $RgName \
    --lb-name myLoadBalancer \
    --name myHealthProbe \
    --protocol tcp \
    --port 80

# Create Load Balancer Rule to distribute traffic
echo '------------------------------------------'
echo 'Creating a the Load Balancer Rule'
az network lb rule create \
    --resource-group $RgName \
    --lb-name myLoadBalancer \
    --name myHTTPRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name myFrontEndPool \
    --backend-pool-name myBackEndPool \
    --probe-name myHealthProbe

# Connect VM's to Backend Pool by updtaing their Nic's
echo '------------------------------------------'
echo 'Connecting VMs to Backend Pool'
az network nic ip-config update \
    --resource-group $RgName \
    --nic-name webNic1 \
    --name ipconfig1 \
    --lb-name myLoadBalancer \
    --lb-address-pool myBackendPool

az network nic ip-config update \
    --resource-group $RgName \
    --nic-name webNic2 \
    --name ipconfig1 \
    --lb-name myLoadBalancer \
    --lb-address-pool myBackendPool

# Done
echo '--------------------------------------------------------'
echo '           Load Balancer Setup Script Completed'
echo '--------------------------------------------------------'
echo ''
echo http://$(az network public-ip show \
    --resource-group $RgName \
    --name myPublicIP \
    --query ipAddress \
    --output tsv )
