#!/bin/bash

export RESOURCEGROUP=learn-storage-replication-rg
export AZURE_STORAGE_ACCOUNT=<storageaccountname>
export LOCATION=westus2

# Create Resource group
az group create --name $RESOURCEGROUP --location $LOCATION

# Create Storage Account
az storage account create --name $AZURE_STORAGE_ACCOUNT --resource-group $RESOURCEGROUP --location $LOCATION --sku Standard_GZRS --encryption-services blob --kind StorageV2

# Get Storage Account Keys
az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT --resource-group $RESOURCEGROUP --output table

export AZURE_STORAGE_KEY="<account-key>"
export BLOB_CONTAINER_NAME=<blob-container-name>

# Create a Blob container
az storage container create --account-key $AZURE_STORAGE_KEY --account-name $AZURE_STORAGE_ACCOUNT --name $BLOB_CONTAINER_NAME

# Create a file
cat > test_file.txt

# Upload the file to the blob
az storage blob upload --container-name $BLOB_CONTAINER_NAME --name test_file --file test_file.txt

# List Blob files
az storage blob list --container-name $BLOB_CONTAINER_NAME --output table
