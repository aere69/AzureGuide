$rgname = 'RGName'
$lbipname = 'LoadBalancerIP-Name'
$pip = (Get-AzPublicIpAddress -ResourceGroupName $rgname -Name $lbipname).IpAddress
# Create an infinite loop - CAREFUL!!!!
while (true) { Invoke-WebRequest -Uri "http://$pip" }
