$templateFile = "./BasicWinVMTemplate.json"
$parameterFile="./BasicWinVMTemplate.parameters.json"

New-AzResourceGroup `
  -Name 104-App-RG `
  -Location "UK South"  
New-AzResourceGroupDeployment `
  -Name DevEnvironment `
  -ResourceGroupName 104-App-RG `
  -TemplateFile $templateFile `
  -TemplateParameterFile $parameterFile