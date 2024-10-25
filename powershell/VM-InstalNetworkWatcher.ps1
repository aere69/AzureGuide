$location = (Get-AzResourceGroup -ResourceGroup $rgName).Location
$vmNames = (Get-AzVM -ResourceGroupName $rgName).Name
foreach ($vmName in $vmNames) {
    Set-AzVMExtension `
        -ResourceGroupName $rgName `
        -Location $location `
        -VMName $vmName `
        -Name 'networkWatcherAgent' `
        -Publisher 'Microsoft.Azure.NetworkWatcher' `
        -Type 'NetworkWatcherAgentWindows' `
        -TypeHandlerVersion '1.4'
}

