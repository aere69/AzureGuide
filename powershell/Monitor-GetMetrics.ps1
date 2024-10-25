$resourceId = "<resource-ID>"
$dimFilter = [String](New-AzMetricFilter -Dimension ApiName -Operator eq -Value "GetBlob" 3> $null)
Get-AzMetric -ResourceId $resourceId -MetricName Transactions -TimeGrain 01:00:00 -MetricFilter $dimFilter -AggregationType "Total"