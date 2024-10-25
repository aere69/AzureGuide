#!/bin/bash

az network vnet create \
    --resource-group "test-rg" \
    --name CoreServicesVnet \
    --address-prefixes 10.20.0.0/16 \
    --location westus

az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name CoreServicesVnet \
    --name GatewaySubnet \
    --address-prefixes 10.20.0.0/27
az network vnet subnet create \
    --resource-group "tesst-rg" \
    --vnet-name CoreServicesVnet \
    --name SharedServicesSubnet \
    --address-prefixes 10.20.10.0/24
az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name CoreServicesVnet \
    --name DatabaseSubnet \
    --address-prefixes 10.20.20.0/24
az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name CoreServicesVnet \
    --name PublicWebServicesSubnet \
    --address-prefixe 10.20.30.0/24

# Check list of resources created
az network vnet subnet list \
    --resource-group "test-rg" \
    --vnet-name CoreServicesVnet \
    --output table

# ----------------------------------

az network vnet create \
    --resource-group "test-rg" \
    --name ManufacturingVnet \
    --address-prefixes 10.30.0.0/16 \
    --location northeurope

az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name ManufacuringVnet \
    --name ManufacturingSystemSubnet \
    --address-prefixes 10.30.10.0/24
az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name ManufacturingVnet \
    --name SensorSubnet1 \
    --address-prefixes 10.30.20.0/24
az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name ManufacturingVnet \
    --name SensorSubnet2 \
    --address-prefixes 10.30.21.0/24
az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name ManufacturingVnet \
    --name SensorSubnet3 \
    --address-prefixes 10.30.22.0/24

az network vnet subnet list \
    --resource-group "test-rg" \
    --vnet-name ManufacturingVnet \
    --output table

# ----------------------------------------------

az network vnet create \
    --resource-group "test-rg" \
    --name ResearchVnet \
    --address-prefixes 10.40.40.0/24 \
    --location westindia

az network vnet subnet create \
    --resource-group "test-rg" \
    --vnet-name ResearchVnet \
    --name ResearchSystemSubnet \
    --address-prefix 10.40.40.0/24

az network vnet subnet list \
    --resource-group "test-rg" \
    --vnet-name ResearchVnet \
    --outuput table
