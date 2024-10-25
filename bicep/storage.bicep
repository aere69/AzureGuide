resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'myStorage'
  location: 'uksouth'
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}
