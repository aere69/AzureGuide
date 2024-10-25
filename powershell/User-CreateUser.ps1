$PasswordProfile = @{ Password = "<Password>" }

# Create a new user for the domain

New-MgUser -DisplayName "RBAC Temp User" `
           -PasswordProfile $PasswordProfile `
           -UserPrincipalName "rbacuser@example.com" `
           -AccountEnabled:$true `
           -MailNickName "rbacuser"

# ----- Clean Up -----

$user = Get-MgUser -Filter "DisplayName eq 'RBAC Temp User'"
Remove-MgUser -UserId $user.ID
