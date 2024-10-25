#!/bin/bash

# vm command creates a virtual machine
# Subcommands: create | deallocate | delete | list | open-port | restart
#              show | start | stop | update

# 1) create a linux virtual machine
az vm create \
    --resource-group "LinuxVm-RG" \
    --location uksouth \
    --name SampleLinuxVM \
    --image Ubuntu2204 \
    --admin-username azureuser \
    --generate-ssh-keys \
    --verbose

# 2) connect to the VM via ssh
# ssh keys are created and stored in local .ssh folder.
# if there is a key name id_rsa in the folder then that 
# key is used to generate the new one.
ssh azureuser@<public-ip-address>

# 2) create a linux virtual machine specifying a size
az vm create \
    --resource-group "LinuxVm-RG" \
    --location uksouth \
    --name SampleLinuxVM \
    --image Ubuntu2204 \
    --admin-username azureuser \
    --generate-ssh-keys \
    --verbose \
    --size "Standard_DS2_V2"

# 3) Resize the VM after creation
# Check resize options for the VM
az vm list-vm-resize-options \
    --resource-group "LinuxVm-RG" \
    --name SampleLinuxVM \
    --output table

# if the new size is not available in the current cluste
# but is available in the region then we have to 
# deallocate the vm first
az vm deallocate \
    --resource-group "LinuxVm-RG" \
    --name SampleLinuxVM \
    --no-wait

az vm resize \
    --resource-group "LinuxVm-RG" \
    --name SampleLinuxVM \
    --size Standard_DS2s_V3

# 4) List all running vm's
# in the susbscription
az vm list
# in the resource-group
az vm list --resource-group "LinuxVM-RG"

# 5) Get VM IP Addresses
az vm list-ip-addresses --name SampleLinuxVM --output table

# 6) Get VM Details
az vm show \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM 

# 7) Filter VM Details
# Get Admin UserName
az vm show \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --query "osProfile.adminUsername"
# Get VM assigned Size
az vm show \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --query hardwareProfile.vmSize
# Get VM's IDs for network interfaces
az vm show \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --query "networkProfile.networkInterfaces[].id" \
    --output tsv

# 8) Stop VM
az vm stop \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM

# Ping the public IP using ssh
ssh azureuser@<public-ip-address> 
# Ping via vm get-instance-view
az vm get-instance-view \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" \
    --output tsv

# 9) Start a VM
az vm start \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \

# Ping via vm get-instance-view
az vm get-instance-view \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" \
    --output tsv

# 10) Restart a VM
az vm restart \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --no-wait # return immediately without waiting for the VM to restart

# 11) Install software on the VM
# Get the VM IP addresses
az vm list-ip-addresses \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --output table
# Open an SSH connection to the VM
ssh azureuser@<public-ip-address> 
# Login and run - install nginx
sudo apt-get -y update && sudo apt-get -y install nginx
exit
# retreive the default page from linu webserver
curl -m 80 <PublicIPAddress> # Will fail - the port is not open
# open port 80
az vm open-port \
    --resource-group "LinuxVM-RG" \
    --name SampleLinuxVM \
    --port 80
# retreive the default page from linu webserver
curl -m 80 <PublicIPAddress> 

# -------------------------------------------

# list of available azure vm images
az vm image list --output table

# Filter the list results
az vm image list --sku Wordpress --output table --all
az vm image list --publisher Microsoft --output table --all
az vm image list --location uksouth --output table

# List vm sizes
az vm list-sizes --location uksouth --output table
