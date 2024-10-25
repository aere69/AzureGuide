# ----- User -----
# Get user principal name or object ID
Get-AzADUser -StartsWith "userName"
(Get-AzADUser -DisplayName "userName").Id

# ----- Group -----
Get-AzADGroup -SearchString "groupName"
(Get-AzADGroup -DisplayName "groupName").Id

# ----- Service Principal -----
Get-AzADServicePrincipal -SearchString "principalName"
(Get-AzADServicePrincipal -DisplayName "principalName").Id

# ------------------------------------------

# ---- Select appropriate Role

# List roles
Get-AzRoleDefinition | Format-Table -Property Name, IsCustom, Id

# List role details
Get-AzRoleDefinition -Name "roleName"

# --------------------------------------------

# ------ Identifi Scope
Get-AzSubscription
Get-AzManagementGroup
Get-AzResourceGroup

# ------------------------------

# ----- Assign a Role

# Resource Scope
New-AzRoleAssignment -ObjectId "objectId" `
                     -RoleDefinitionName "roleName" `
                      -Scope /subscriptions/<subscriptionId>/resourcegroups/<resourceGroupName>/providers/<providerName>/<resourceType>/<resourceSubType>/<resourceName>

New-AzRoleAssignment -ObjectId "objectId" `
                     -RoleDefinitionId "roleId"
                     -ResourceName "resourceName"
                     -ResourceType "resourceType"
                     -ResourceGroupName "resourceGroupName"

# Resource Group Soope
New-AzRoleAssignment -SignInName <emailOrUserprincipalname> -RoleDefinitionName <roleName> -ResourceGroupName <resourceGroupName>

New-AzRoleAssignment -ObjectId <objectId> -RoleDefinitionName <roleName> -ResourceGroupName <resourceGroupName>

# Subscription Scope
New-AzRoleAssignment -SignInName <emailOrUserprincipalname> -RoleDefinitionName <roleName> -Scope /subscriptions/<subscriptionId>

New-AzRoleAssignment -ObjectId <objectId> -RoleDefinitionName <roleName> -Scope /subscriptions/<subscriptionId>

# Management Group Scope
New-AzRoleAssignment -SignInName <emailOrUserprincipalname> -RoleDefinitionName <roleName> -Scope /providers/Microsoft.Management/managementGroups/<groupName>

New-AzRoleAssignment -ObjectId <objectId> -RoleDefinitionName <roleName> -Scope /providers/Microsoft.Management/managementGroups/<groupName>

# --------------------------------------------

# List Role Assignments
Get-AzRoleAssignment
Get-AzRoleAssignment -Scope /subscriptions/<subscription_id>
Get-AzRoleAssignment -SignInName <email_or_userprincipalname>
Get-AzRoleAssignment -SignInName <email_or_userprincipalname> -ExpandPrincipalGroups
Get-AzRoleAssignment -ResourceGroupName <resource_group_name>
Get-AzRoleAssignment -Scope /providers/Microsoft.Management/managementGroups/<group_id>
Get-AzRoleAssignment -Scope "/subscriptions/<subscription_id>/resourcegroups/<resource_group_name>/providers/<provider_name>/<resource_type>/<resource>"
Get-AzRoleAssignment -IncludeClassicAdministrators

# List role assignments for a managed identity
Get-AzADServicePrincipal -DisplayNameBeginsWith "<name> or <vmname>"
Get-AzRoleAssignment -ObjectId "object.Id"
