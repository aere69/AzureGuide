# Get list of Azure Subscriptions
Get-AzSubscription

Get-AzSubscription | ForEach-Object { 
    Set-AzContext -SubscriptionId $_.SubscriptionId 
    Get-AzResource | Select-Object Name, ResourceGroupName, Location, Type }