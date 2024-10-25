$resourceGroupName="staging-grp"
$location="North Europe"
$publicIPAddressName="app-ip"

New-AzPublicIpAddress -Name $publicIPAddressName -ResourceGroupName $resourceGroupName `
-Location $location -AllocationMethod Static