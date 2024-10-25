$vmName="appvm"
$resourceGroupName="staging-grp"
$diskName="datadisk01"

$vm=Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

$vm | Add-AzVMDataDisk -Name $diskName -DiskSizeInGB 16 -CreateOption Empty -Lun 0

$vm | Update-AzVM