# Ge a list of region locations
Get-AzLocation | select Location

# Select location near
$location = "uksouth"

# Create a new resource group
New-AzResourceGroup -Name "RBAC-Test_RG" `
                    -Location $location

                    