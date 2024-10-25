New-AzResourceGroup -Name 104-VNet-Rg -Location uksouth
New-AzResourceGroupDeployment -ResourceGroupName 104-VNet-Rg `
    -TemplateFile .\BasicVNetTemplate.json `
    -TemplateParameterFile .\BasicVNetTemplate.parameters.json
