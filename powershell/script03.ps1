$resourceGroupName="staging-grp"
$networkName="app-network"

$VirtualNetwork = Get-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName

Write-Host $VirtualNetwork.Location
Write-Host $VirtualNetwork.AddressSpace.AddressPrefixes