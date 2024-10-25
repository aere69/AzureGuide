# Connect to Azure
Connect-AzAccount

# Create a resource group
$rg = @{
    Name = 'test-rg'
    Location = 'uksouth'
}
New-AzResourceGroup @rg

# Create a Virtual Network
$vnet = @{
    Name = 'vnet-1'
    ResourceGroupName = 'test-rg'
    Location = 'uksouth'
    AddressPrefix = '10.0.0.0/16'
}
$virtualNetwork = New-AzVirtualNetwork @vnet

# Create a subnet to add to the vnet
$subnet = @{
    Name = 'subnet-1'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.0.0.0/24'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet

# Associate the subnet to the vnet
$virtualNetwork | Set-AzVirtualNetwork

# Configure Bastion Subnet
$subnet = @{
    Name = 'AureBastionSubnet'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.0.1.0/26'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet

# Associate the bastion subnet to the vnet
$virtualNetwork | Set-AzVirtualNetwork

# Create a Public IP address for Bastion
$ip = @{
    ResourceGroupName = 'test-rg'
    Name = 'bastion-public-ip'
    Location = 'uksouth'
    AllocationMethod = 'Static'
    Sku = 'Standard'
    Zone = 1,2,3
}
New-AzPublicIpAddress @ip

# Create a new Bastion host
$bastion = @{
    Name = 'bastion'
    ResourceGroupName = 'test-rg'
    PublicIpAddressRgName = 'test-rg'
    PublicIpAddressName = 'bastion-public-ip'
    VirtualNetworkRgName = 'test-rg'
    VirtualNetworkName = 'vnet-1'
    Sku = 'Basic'
}
New-AzBastion @bastion

# ---------------------------------

# Create VM's for testing

# Set the administrator and password for the VM. ##
$cred = Get-Credential

## Place the virtual network into a variable. ##
$vnet = Get-AzVirtualNetwork `
    -Name 'vnet-1' `
    -ResourceGroupName 'test-rg'

# Create a NIC for the VM
$nic = @{
    Name = 'nic-1'
    ResourceGroupName = 'test-rg'
    Location = 'uksouth'
    Subnet = $vnet.Subnets[0]
}
$nicVM = New-AzNetworkInterface @nic

## Create a VM configuration
$vmsz = @{
    VMName = 'vm-1'
    VMSize = 'Standard_DS1_V2'
}
$vmos = @{
    ComputerName = 'vm-1'
    Credential = $cred
}
$vmimage = @{
    PublisherImage = 'Canonical'
    Offer = '0001-com-ubuntu-server-jammy'
    Skus = '22_04-lts-gen2'
    Version = 'latest'
}
$vmConfig = New-AzVMConfig @vmsz `
    | Set-AzVMOperatingSystem @vmos -Linux `
    | Set-AzVMSourceImage @vmimage `
    | Add-AzVMNetworkInterface -Id $nicVM.Id

# Create the VM
$vm = @{
    ResourceGroupName = 'test-rg'
    Location = 'uksouth'
    VM = $vmConfig
}
New-AzVM @vm

## ---- Create 2nd VM

## Create a network interface for the VM. ##
$nic = @{
    Name = "nic-2"
    ResourceGroupName = 'test-rg'
    Location = 'uksouth'
    Subnet = $vnet.Subnets[0]
}
$nicVM = New-AzNetworkInterface @nic

## Create a virtual machine configuration. ##
$vmsz = @{
    VMName = "vm-2"
    VMSize = 'Standard_DS1_v2'  
}
$vmos = @{
    ComputerName = "vm-2"
    Credential = $cred
}

$vmConfig = New-AzVMConfig @vmsz `
    | Set-AzVMOperatingSystem @vmos -Linux `
    | Set-AzVMSourceImage @vmimage `
    | Add-AzVMNetworkInterface -Id $nicVM.Id

## Create the VM. ##
$vm = @{
    ResourceGroupName = 'test-rg'
    Location = 'eastus2'
    VM = $vmConfig
}
New-AzVM @vm -AsJob # Create the VM in the Backround!!!

# ---------------------------
# Connect to the VM's using Bastion from the portal
# Once connected run:
# From VM1 : ping -c 4 vm-2
# From VM2 : ping -c 4 vm-1