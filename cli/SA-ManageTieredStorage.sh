#!/bin/bash

# Create a dummy/empty file
touch dummy.png

# Set variables
export LOCATION=uksouth
export RESOURCE_GROUP=sa-tiertest-rg
export STORAGE_ACCOUNT_NAME=satiertest$RANDOM
export CONTAINER_NAME=tiertest

# create new storage account
az storage account create \
    --location $LOCATION \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --kind StorageV2 \
    --sku Standard_LRS

# Get storage account key
export AZURE_STORAGE_KEY="$(az storage account keys list -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT_NAME --query [0].value --output tsv)"

# Creata a new container
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $AZURE_STORAGE_KEY

# upload file as a blob
az storage blob upload \
    --file dummy.png \
    --name guitar-model8.png \
    --container-name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME

# List the blobs in the container
az storage blob list \
    --container-name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --output table

# Change blob tier
az storage blob set-tier \
    --name guitar-model8.png \
    --container-name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --tier Cool

# tier : Cool/Archive/Hot