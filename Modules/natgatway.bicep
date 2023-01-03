param natgwname string
param location string
param idleTimeoutInMinutes int
@minValue(28)
@maxValue(31)
param prefixLength int
@allowed( [
  'Standard'
  'Basic'
])
param sku string

@allowed( [
  'IPv4'
  'Ipv6'
])
param publicIPAddressVersion string

@allowed( [
  'Static'
  'Dyanamic'
])
param publicIPAllocationMethod string

resource publicipprefix 'Microsoft.Network/publicIPPrefixes@2021-05-01' = {
  name: '${natgwname}-prefix'
  location: location
  sku: {
    name:  'Standard'
  }
  properties: {
    prefixLength: prefixLength
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${natgwname}-Pip'
  location: location
  sku: { 
    name: sku
  }
  properties: {
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod 
  }

}

resource natgw 'Microsoft.Network/natGateways@2022-07-01' = {
  name: natgwname
   properties: {
    idleTimeoutInMinutes: idleTimeoutInMinutes
    publicIpAddresses: [
      {
         id: publicip.id
      }

    ]
    publicIpPrefixes: [
      {
        id:publicipprefix.id
      }
    ]
   }
}


output natGwId string = natgw.id
