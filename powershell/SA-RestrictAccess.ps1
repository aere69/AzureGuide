$RGName = "test-rg"
$Location = "uksouth"

# Create Resource Group
$RG = @{
    ResourceGroupName = $RGName
    Location = $Location
}
New-AzResourceGroup @RG

# Create a Virtual Network
$VNet = @{
    ResourceGroupName = $RGName
    Location = $Location
    Name = "Vnet-1"
    AddressPrefix ="10.0.0.0/16"
}
$VirtualNetwork = New-AzVirtualNetwork @VNet

#Create a SubNet Configuration
$subpub = @{
    Name = "subnet-public"
    AddressPrefix = "10.0.0.0/24"
    VirtualNetwork = $VirtualNetwork
}
$PublicSubNetConfig = Add-AzVirtualNetworkSubnetConfig @subpub

# Create SubNet in VNet
$VirtualNetwork | Set-AzVirtualNetwork

#Create a SubNet Configuration
$subpriv = @{
    Name = "subnet-private"
    AddressPrefix = "10.0.2.0/24"
    VirtualNetwork = $VirtualNetwork
    ServiceEndpoint = "Microsoft.Storage"
}
$PrivateSubNetConfig = Add-AzVirtualNetworkSubnetConfig @subpriv

# Create the SubNet in VNet
$VirtualNetwork | Set-AzVirtualNetwork

# ----- Deploy Bastion -----
# Create Bastion SubNet

$subbastion = @{
    Name = "AzureBastionSubnet"
    AddressPrefix = "10.0.1.0/26"
    VirtualNetwork = $VirtualNetwork
}
$BastionSubNetConfig = Add-AzVirtualNetworkSubnetConfig @subbastion

# Create the SubNet in VNet
$VirtualNetwork | Set-AzVirtualNetwork

# Create a Public IP for Bastion.
# The Bastion host uses the public IP to access SSH and RDP over port 443
$bastionPublicIP = @{
    ResourceGroupName = $RGName
    Name = 'bastion-public-ip'
    Location = $Location
    AllocationMethod = 'Static'
    Sku = 'Standard'
    Zone = 1,2,3
}
New-AzPublicIpAddress @bastionPublicIP

# Create a Bastion Host
$bastion = @{
    Name = 'bastion'
    ResourceGroupName = $RGName
    PublicIpAddressRgName = $RGName
    PublicIpAddressName = $bastionPublicIP.Name
    VirtualNetworkRgName = $RGName
    VirtualNetworkName = $VNet.Name
    Sku = 'Basic'
}
New-AzBastion @bastion -AsJob

# ---------------------------------

# Create Network Security Group
$nsgpriv = @{
    ResourceGroupName = $RGName
    Location = $Location
    Name = 'nsg-private'
}
$nsg = New-AzNetworkSecurityGroup @nsgpriv

# Create outbound network security rules
$r1 = @{
    Name = "Allow-Storage-All"
    Access = "Allow"
    DestinationAddressPrefix = "Storage"
    DestinationPortRange = "*"
    Direction = "Outbound"
    Priority = 100
    Protocol = "*"
    SourceAddressPrefix = "VirtualNetwork"
    SourcePortRange = "*"
}

$rule1 = New-AzNetworkSecurityRuleConfig @r1

$r2 = @{
    Name = "Deny-Internet-All"
    Access = "Deny"
    DestinationAddressPrefix = "Internet"
    DestinationPortRange = "*"
    Direction = "Outbound"
    Priority = 110
    Protocol = "*"
    SourceAddressPrefix = "VirtualNetwork"
    SourcePortRange = "*"
}
$rule2 = New-AzNetworkSecurityRuleConfig @r2

# Retrieve the existing network security group
$nsgpriv = @{
    ResourceGroupName = $RGName
    Name = 'nsg-private'
}
$nsg = Get-AzNetworkSecurityGroup @nsgpriv

# Add the new rules to the security group
$nsg.SecurityRules += $rule1
$nsg.SecurityRules += $rule2

# Update the network security group with the new rules
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

# Associate Network Security Group to Subnet Private
$subnet = @{
    VirtualNetwork = $VirtualNetwork
    Name = "subnet-private"
    AddressPrefix = "10.0.2.0/24"
    ServiceEndpoint = "Microsoft.Storage"
    NetworkSecurityGroup = $nsg
}
Set-AzVirtualNetworkSubnetConfig @subnet

$virtualNetwork | Set-AzVirtualNetwork

# -------------------------------------------

# ----- Restrict Access to a Resource -----

# Create a Storage Account
$storageAcctName = '<replace-with-your-unique-storage-account-name>'

$storage = @{
    Location = $Location
    Name = $storageAcctName
    ResourceGroupName = $RGName
    SkuName = 'Standard_LRS'
    Kind = 'StorageV2'
}
New-AzStorageAccount @storage

# Get access key for the storage account
$storagekey = @{
    ResourceGroupName = $RGName
    AccountName       = $storageAcctName
  }
  $storageAcctKey = (Get-AzStorageAccountKey @storagekey).Value[0]

# Create a Context for the New Storage Account
# The context encapsulates the storage account name and account key:
$storagecontext = @{
    StorageAccountName = $storageAcctName
    StorageAccountKey = $storageAcctKey
}
$storageContext = New-AzStorageContext @storagecontext

# Create a fileShare in the Storage Account
$fs = @{
    Name = "file-share"
    Context = $storageContext
}
$share = New-AzStorageShare @fs

# -------------------------------------------------

# Restrict network access to a subnet

$storagerule = @{
    ResourceGroupName = $RGName
    Name = $storageAcctName
    DefaultAction = "Deny"
}
Update-AzStorageAccountNetworkRuleSet @storagerule

$subnetpriv = @{
    ResourceGroupName = $RGName
    Name = $VNet.name
}
$privateSubnet = Get-AzVirtualNetwork @subnetpriv | Get-AzVirtualNetworkSubnetConfig -Name "subnet-private"

$storagenetrule = @{
    ResourceGroupName = $RGName
    Name = $storageAcctName
    VirtualNetworkResourceId = $privateSubnet.Id
}
Add-AzStorageAccountNetworkRule @storagenetrule

# -------------------------------------------------------

# ----- Deploy VM to SubNets -----
$vm1 = @{
    ResourceGroupName = $RGName
    Location = $Location
    VirtualNetworkName = $VNet.Name
    SubnetName = "subnet-public"
    Name = "vm-public"
    PublicIpAddressName  = $null
}
New-AzVm @vm1

$vm2 = @{
    ResourceGroupName = $RGName
    Location = $Location
    VirtualNetworkName = $VNet.Name
    SubnetName = "subnet-private"
    Name = "vm-private"
    PublicIpAddressName = $null
}
New-AzVm @vm2

# -----------------------------------------------

# ----- CleanUp -----
$cleanup = @{
    Name  = "test-rg"
}
Remove-AzResourceGroup @cleanup -Force

