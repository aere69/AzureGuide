# Azure PowerShell and CLI Commands

There is a predictable name system for commands that makes them easier to guess.

[PowerShell Module Reference](https://learn.microsoft.com/en-us/powershell/module/?view=azps-12.0.0)

- Get-AZ**service-name**
- New-AZ**service-name**
- Remove-AZ**service-name**

where **service-name** could be VM, keyVault, VirtualNetwork, VirtualNetworkSubnetConfig, ...

[CLI Commands](https://learn.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest)

- az **service-name** list
- az **service-name** create
- az **service-name** delete

where **service-name** could be vm, keyvault, network vnet, network vnet subnet, ...

## AZ Modules on PowerShell 7

### Install

- Run as admin

```ps
Install-Module -Name Az -AllowClobber -Repository PSGallery -Force
```

### Update

- Run as admin

```ps
Update-Module -Name Az -AllowClobber -Repository PSGallery
```

## Commands

```ps
# Connect local instance to Azure
Connect-AzAccount

# List subscriptions
Get-AzSubscription

# Change to another subsription
Set-AzContext -Subscription "id"

# Get list of installed modules
Get-InstalledModule -Name Az -AllVersions | Select-Object -Property Name, Version

# list of all VM 
Get-AzVM

# Lista all WebApps
Get-AzWebapp

# List and export to CSV
Get-AzWebApp | Select-Object Name, Location | ConvertTo-CSV -NoTypeInformation
```
