$resourceGroupName="staging-grp"
$networkName="app-network"
$subnetName="SubnetA"
$subnetAddressPrefix="10.0.0.0/24"
$addressPrefix="10.0.0.0/16"
$location="North Europe"

$subnet=New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix

New-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName `
-Location $location -AddressPrefix $addressPrefix -Subnet $subnet