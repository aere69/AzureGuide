# Create a connection with Azure
Connect-AzAccount

# Create a resource group
$rg =@{
    ResourceGroupName = "test-rg"
    Location = "uksouth"
}
New-AzResourceGroup @rg

# Create a virtual network
$vnet = @{
    ResourceGroupName = "test-rg"
    Location = "uksouth"
    Name = "vnet-1"
    AddressPrefix = "10.0.0.0/16"
}
$virtualNetwork = New-AzVirtualNetwork @vnet

# Create a subnet configuration (will create default nsg-1)
$subnet = @{
    Name = "subnet-1"
    VirtualNetwork = $virtualNetwork
    AddressPrefix = "10.0.0.0/24"
}
Add-AzVirtualNetworkSubnetConfig @subnet

$virtualNetwork | Set-AzVirtualNetwork

# Create application security group
$web = @{
    ResourceGroupName = "test-rg"
    Location = "uksouth"
    Name = "asg-web"
}
$webAsg = New-AzApplicationSecurityGroup @web

$mgmt = @{
    ResourceGroupName = "test-rg"
    Location = "uksouth"
    Name = "asg-mgmt"
}
$mgmtAsg = New-AzApplicationSecurityGroup @mgmt

# Create a NSG
$nsgParams = @{
    ResourceGroupName ="test-rg"
    Location = "uksouth"
    Name = "nsg-1"
}
$nsg = New-AzNetworkSecurityGroup @nsgParams

# ----------------------------------------------------
# Associate NSG to Subnet
## Retrieve the Vnet
$vnet = Get-AzVirtualNetwork -Name "vnet-1" -ResourceGroupName "test-rg"

## Update the subnet config to associate the NSG
$subnetConfigParams = @{
    VirtualNetwork =  $vnet
    Name = "subnet-1"
    AddressPrefix = $vnet.Subnets[0].AddressPrefix
    NetworkSecurityGroup = Get-AzNetworkSecurityGroup -Name "nsg-1" -ResourceGroupName "test-rg"
}
Set-AzVirtualNetworkSubnetConfig @subnetConfigParams

## Update the Virtual Network with the subnet config
$vnet | Set-AzVirtualNetwork

# ----------------------------------------

# Create Security Rules
## Allows traffic inbound from the internet to the asg-web application security group 
## over ports 80 and 443
$webAsgParams = @{
    Name = "asg-web"
    ResourceGroupName = "test-rg"
}
$webAsg = Get-AzApplicationSecurityGroup @webAsgParams

$webRuleParams = @{
    Name = "Allow-Web-All"
    Access = "Allow"
    Protocol = "Tcp"
    Direction = "Inbound"
    Priority = 100
    SourceAddressPrefix = "Internet"
    SourcePortRange = "*"
    DestinationApplicationSecurityGroupId = $webAsg.Id
    DestinationPortRange = 80,443
}
$webRule = New-AzNetworkSecurityRuleConfig @webRuleParams

## Allows traffic inbound from the internet to the asg-mgmt application security group 
## over port 3389
$mgmtAsgParams = @{
    Name = "asg-mgmt"
    ResourceGroupName = "test-rg"
}
$mgmtAsg = Get-AzApplicationSecurityGroup @mgmtAsgParams

$mgmtRuleParams = @{
    Name = "Allow-RDP-All"
    Access = "Allow"
    Protocol = "Tcp"
    Direction = "Inbound"
    Priority = 110
    SourceAddressPrefix = "Internet"
    SourcePortRange = "*"
    DestinationApplicationSecurityGroupId = $mgmtAsg.id
    DestinationPortRange = 3389
}
$mgmtRule = New-AzNetworkSecurityRuleConfig @mgmtRuleParams

# ------------------------------------------

# Add the new rules to the the NSG
## Retrieve the NSG
$nsg = Get-AzNetworkSecurityGroup -Name "nsg-1" -ResourceGroupName "test-rg"

## Add the new asg Rules to the NSG
$nsg.SecurityRules += $webRule
$nsg.SecurityRules += $mgmtRule

## Update the NSG with the new rules
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $sng

# --------------------------------------

# Create VM's to test

## Retrieve the Vnet
$vnetParams = @{
    Name = "vnet-1"
    ResourceGroupName = "test-rg"
}
$vnet = Get-AzVirtualNetwork @vnetParams

## Creat PublicIP for each VM
$publicIPWebParams = @{
    AllocationMethod = "Static"
    ResourceGroupName = "test-rg"
    Location = "uksouth"
    Name = "public-IP-Web-vm"
}
$publicIPWeb = New-AzPublicIpAddress @publicIPWebParams

$publicIPMgmtParams = @{
    AllocationMethod = "Static"
    ResourceGroupName = "test-rg"
    Location = "uskouth"
    Name = "public-IP-Mgmt-vm"
}
$publicIPMgmt = New-AzPublicIpAddress @publicIPMgmtParams

## Create two NIC for each VM and assign corresponding the public IP
$webNicParams = @{
    Location = "uksouth"
    Name = "vm-web-nic"
    ResourceGroupName = "test-rg"
    SubnetId = $virtualNetwork.Subnets[0].Id
    PublicIpAddressId = $publicIPWeb.Id
}
$webNic = New-AzNetworkInterface @webNicParams

$mgmtNicParams = @{
    Location = "uksouth"
    Name = "vm-mgmt-nic"
    ResourceGroupName = "test-rg"
    SubnetId = $virtualNetwork.Subnets[0].Id
    PublicIpAddressId = $publicIPMgmt.id
}
$mgmtNic = New-AzNetworkInterface @mgmtNicParams

## Create a new VM using VMConfiguration

## Create user object
$cred = Get-Credential -Message "Enter username and password for the VM."

$webVMConfigParams = @{
    VMName = "vm-web"
    VMSize = "Standard_DS1_V2"
}

$vmOSParams = @{
    ComputerName = "vm-web"
    Credential = $cred
}

$vmImageParams = @{
    PublisherName = "MicrosoftWindowsServer"
    Offer = "WindowsServer"
    Skus = "2022-Datacenter"
    Version = "latest"
}

$webVmConfig = New-AzVMConfig @webVMConfigParams | Set-AzVMOperatingSystem -windows @vmOSParams | Set-AzVMSourceImage @vmImageParams | Add-AzVMNetworkInterface -Id $webNic.Id

$webVmParams = @{
    ResourceGroupName = "test-rg"
    Location = "uksouth"
    VM = $webVmConfig
}

New-AzVM @webVmParams -AsJob

## Create user object
$cred = Get-Credential -Message "Enter username and password for the VM."

$mgmtVMConfigParams = @{
    VMName = "vm-mgmt"
    VMSize = "Standard_DS1_V2"
}

$vmOSParams = @{
    ComputerName = "vm-mgmt"
    Credential = $cred
}

$vmImageParams = @{
    PublisherName = "MicrosoftWindowsServer"
    Offer = "WindowsServer"
    Skus = "2022-Datacenter"
    Version = "latest"
}

$mgmtVmConfig = New-AzVMConfig @mgmtVMConfigParams | Set-AzVMOperatingSystem -windows @vmOSParams | Set-AzVMSourceImage @vmImageParams | Add-AzVMNetworkInterface -Id $mgmtNic.Id

$mgmtVmParams = @{
    ResourceGroupName = "test-rg"
    Location = "uksouth"
    VM = $mgmtVmConfig
}

New-AzVM @mgmtVmParams -AsJob

# -------------------------------------------------------

# Associate NIC to ASG

$params1 = @{
    Name = "vm-web-nic"
    ResourceGroupName = "test-rg"
}
$nic = Get-AzNetworkInterface @params1

$params2 = @{
    Name = "asg-web"
    ResourceGroupName = "test-rg"
}
$asg = Get-AzApplicationSecurityGroup @params2

$nic.IpConfigurations[0].ApplicationSecurityGroups = @($asg)

$params3 = @{
    NetworkInterface = $nic
}
Set-AzNetworkInterface @params3

$params1 = @{
    Name = "vm-mgmt-nic"
    ResourceGroupName = "test-rg"
}
$nic = Get-AzNetworkInterface @params1

$params2 = @{
    Name = "asg-mgmt"
    ResourceGroupName = "test-rg"
}
$asg = Get-AzApplicationSecurityGroup @params2

$nic.IpConfigurations[0].ApplicationSecurityGroups = @($asg)

$params3 = @{
    NetworkInterface = $nic
}
Set-AzNetworkInterface @params3

# ---------------------------------------------

# Test traffic

$params = @{
    Name = "public-ip-vm-mgmt"
    ResourceGroupName = "test-rg"
}
$publcIp = Get-AzPublicIpAddress @params | Select IpAddress

# Create remote desktop to vm-mgmt
mtsc /v:$publcIp

# From vm-mgmt connect to vm-web
mtsc /v:vm-web

# ----------------------------

# Install IIS on vm-web
Install-WindowsFeature -name Web-Server -IncludeManagementTools

$params = @{
    Name = "public-ip-web-vm"
    ResourceGroupName = "test-rg"
}
Get-AzPublicIpAddress @params | Select IpAddress

# Browse to the default page
http://<public-ip>

# ------------------------------------------

# Clean Up

$params = @{
    Name = "test-rg"
    Force = true
}
Remove-AzResourceGroup @params
