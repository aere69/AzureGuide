@description('Please specify a location')
param location string

var networkName='appNetwork'
//var location='uksouth'
var networkAddressPrefix='10.0.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: networkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkAddressPrefix
      ]
    }
    subnets: [for i in range(1,3): {
        name: 'Subnet-${i}'
        properties: {
          addressPrefix: cidrSubnet(networkAddressPrefix,24,i)
        }
      }
    ]
  }
}
