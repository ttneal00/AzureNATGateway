param securityGroupName string
param location string


resource subnet 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: securityGroupName
  location: location
  properties: {
    securityRules: [
      
    ]
  }
}

output subnetid string = subnet.id
