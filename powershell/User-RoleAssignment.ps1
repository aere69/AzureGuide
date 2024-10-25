# Get the ID of the subscription
$subscription = Get-AzSubscription

# Subscription Scope
#$subScope = "/subscriptions/" + $subscription.Id
$subScope = "/subscriptions/$($subscription.SubscriptionId)"

New-AzRoleAssignment -SignInName "rbacuser@example.com" `
                     -RoleDefinitionName "Reader" `
                     -Scope $subScope

New-AzRoleAssignment -SignInName "rbacuser@example.com" `
                     -RoleDefinitionName "Constributor" `
                     -ResourceGroupName "rbac-tutorial-resource-group"

# List access
Get-AzRoleAssignment -SignInName "rbac@example.com" -Scope $subScope
Get-AzRoleAssignment -SignInName "rbac@example.com" -ResourceGroupName "rbac-tutorial-resource-group"


# Remove Access
Remove-AzRoleAssignment -SignInName "rbacuser@example.com" `
                        -RoleDefinitionName "Constributor" `
                        -ResourceGroupName "rbac-tutorial-resource-group"

Remove-AzRoleAssignment -SignInName "rbacuser@example.com" `
                        -RoleDefinitionName "Reader" `
                        -Scope $subScope

# ----- Clean Up -----

# Remove Resouce Group
Remove-AzResourceGroup -Name "rbac-tutorial-resource-group"

