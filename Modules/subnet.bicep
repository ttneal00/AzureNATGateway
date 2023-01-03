param subnetname string 
param addressprefix string
param natGatewayId string
param nsgid string

// var vnetparent = 'Microsoft.Network/virtualNetworks/subnets${vnetname}'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: subnetname
  properties:{
    addressPrefix: addressprefix
    natGateway: {
      id: natGatewayId
    }
    networkSecurityGroup: {
      id: nsgid
    }
  }

}


output subnetid string = subnet.id
