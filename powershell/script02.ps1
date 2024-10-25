$resourceGroupName="staging-grp"
$location="North Europe"
$networkName="app-network"
$addressPrefix="10.0.0.0/16"

New-AzVirtualNetwork -Name $networkName -ResourceGroupName $resourceGroupName `
-Location $location -AddressPrefix $addressPrefix