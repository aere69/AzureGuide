# List Resources for current context

$resources = @()
$subscription = Get-AzSubscription
$subscriptionName = $subscription.Name
$subscriptionId = $subscription.SubscriptionId
Get-AzResource | ForEach-Object {
    $resources += [PSCustomObject]@{
        SubscriptionName  = $subscriptionName
        SubscriptionId    = $subscriptionId
        ResourceGroupName = $_.ResourceGroupName
        ResourceName      = $_.ResourceName
        ResourceType      = $_.ResourceType
        Location          = $_.Location
    }
}
$resources | Select-Object ResourceGroupName, ResourceName, ResourceType, Location
#$resources | Export-csv .\resources.csv
