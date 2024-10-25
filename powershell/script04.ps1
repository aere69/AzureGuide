$resourceGroupName="staging-grp"
$networkName="app-network"
$subnetName="SubnetA"
$subnetAddressPrefix="10.0.0.0/24"

$VirtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $VirtualNetwork `
-AddressPrefix $subnetAddressPrefix

$VirtualNetwork | Set-AzVirtualNetwork