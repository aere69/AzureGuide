$vmName="appvm"
$vmSize="Standard_DS2_v2"
$location="North Europe"

$vmConfig=New-AzVMConfig -Name $vmName -VMSize $vmSize
$Credential=Get-Credential

Set-AzVMOperatingSystem -VM $vmConfig -Credential $Credential -Windows -ComputerName $vmName

Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest"

$networkInterfaceName="app-interface"
$networkInterface=Get-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $resourceGroupName

$vm=Add-AzVMNetworkInterface -VM $vmConfig -Id $networkInterface.Id

New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm