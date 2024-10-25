# Connect to azure
Connect-AzAccount

# Create resource group
New-AzResourceGroup -Name my-rg -Location 'UK South'

# Create a VM - Basic
New-AzVM -Name azvm01 -ResourceGroupName my-rg -Location 'UK South'

New-AZVM `
    -ResourceGroupName "my-rg" `
    -Name "vmName" `
    -Location "UK South" `
    -VirtualNetworkName "myVmVnet" `
    -SubnetName "myVmSubnet" `
    -SecurityGroupName "myVmNSG" `
    -PublicIpAddressName "myVmPublicIP"

# Get VM information
Get-AzVM -Name "azvm01" -Status | Format-Table -AutoSize

# Install IIS on VM
Invoke-AzVMRunCommand -ResourceGroupName 'my-rg' -VMName 'azvm01' -CommandId 'RunPowerSellScript' -ScriptString 'Install-WindowsFeature -Name Web-Server -IncludeManagementTools'

Stop-AzVM -Name 'azvm01' -ResourceGroupName 'my-rg'
Start-AzVM -Name 'azvm01' -ResourceGroupName 'my-rg'
Restart-AzVM -Name 'azvm01' -ResourceGroupName 'my-rg'

# Delete VM
Remove-AzVM -Name 'azvm01' -ResourceGroupName 'my-rg'

# Clean Up
Remove-AzResourceGroup -Name 'my-rg'


