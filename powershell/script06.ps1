$resourceGroupName="staging-grp"
$networkName="app-network"
$subnetName="SubnetA"
$networkInterfaceName="app-interface"

$VirtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

$subnet=Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VirtualNetwork -Name $subnetName

New-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $resourceGroupName `
-Location $location -SubnetId $subnet.Id -IpConfigurationName "IpConfig"