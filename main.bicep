targetScope = 'subscription'

param computeRgName string
param networkRgName string
param location string
param envPrefix string

// NAT Gateway Params and Variables

param natGWname string
param idleTimeoutInMinutes int
param prefixLength int
param publicIPAddressVersion string
param publicIPAllocationMethod string
param sku string

//vNet Params and Vars
param Spoke01Name string
param  Spoke01Network string
param  azureBastionName string = 'AzureBastionSubnet'
var Spoke01CIDR = '${Spoke01Network}0.0/16'
var Spoke01S01CIDR = '${Spoke01Network}0.0/24'
var Spoke01S02CIDR = '${Spoke01Network}5.0/24'
var AzureBastionS01S03 = '${Spoke01Network}50.0/26'
param domainNameLabel string

//NSG Params and Vars
param defaultNsgName string 

//Desktop Params and Vars
@secure()
param adminPassword string

module computeRG 'Modules/resourcegroup.bicep' = {
  scope: subscription()
  name: computeRgName
  params: {
    location: location
    resourceGroupName: computeRgName
  }
}

module networkRG 'Modules/resourcegroup.bicep' = {
  scope: subscription()
  name: networkRgName
  params: {
    location: location
    resourceGroupName: networkRgName
  }
}

module natGw 'Modules/natgatway.bicep' = {
  scope: resourceGroup(networkRG.name)
  name: natGWname

  params: {
    idleTimeoutInMinutes: idleTimeoutInMinutes
    location: location
    natgwname: natGWname
    prefixLength: prefixLength
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
    sku: sku
  }
}

module Spoke01 'Modules/VirtualNetwork.bicep' = {
  name: Spoke01Name
  scope: resourceGroup(networkRG.name)
  params: {
    location: location
    vnetAddress: Spoke01CIDR
    vnetName: Spoke01Name
  }
}

module  azureBastionNsg 'Modules/bastionnsg.bicep' = {
  scope: resourceGroup(networkRG.name)
  name: '${azureBastionName}-NSG'
  params: {
    bastionHostName: azureBastionName
    location: location
  }
  dependsOn: [
    
  ]
}

module defaultNsg 'Modules/defaultnsg.bicep' = {
  scope: resourceGroup(networkRG.name)
  name: defaultNsgName
  params: {
    location: location
    securityGroupName: defaultNsgName
  }
}
module Spoke01S01 'Modules/subnet.bicep' = {
  scope: resourceGroup(networkRG.name)
  name: '${Spoke01Name}-SN01'
  params: {
    addressprefix: Spoke01S01CIDR
    subnetname: '${Spoke01Name}/${Spoke01Name}-SN01'
    natGatewayId: natGw.outputs.natGwId 
    nsgid: defaultNsg.outputs.subnetid
  }
 

}

module Spoke01S02 'Modules/subnet.bicep' = {
  scope: resourceGroup(networkRG.name)
  name: '${Spoke01Name}-SN02'
  params: {
    addressprefix: Spoke01S02CIDR
    subnetname: '${Spoke01Name}/${Spoke01Name}-SN02'
    natGatewayId: natGw.outputs.natGwId
    nsgid: defaultNsg.outputs.subnetid

  }
  dependsOn: [
    Spoke01S01
  ]
}

module AzureBastionSN 'Modules/subnet.bicep' = {
  scope: resourceGroup(networkRG.name)
  name: '${azureBastionName}-SN02'
  params: {
    addressprefix: AzureBastionS01S03
    subnetname: '${Spoke01Name}/${azureBastionName}'
    natGatewayId: natGw.outputs.natGwId
    nsgid: azureBastionNsg.outputs.bastionHostNSGId

  }
  dependsOn: [
    Spoke01S02
    azureBastionNsg
  ]
}

module BastionHost 'Modules/bastionhost.bicep' = {
  scope: resourceGroup(networkRG.name)
  name: azureBastionName
  params: {
    domainNameLabel: domainNameLabel
    location: location
    publicIPAddressName: '${azureBastionName}-Pip'
    subnetid: AzureBastionSN.outputs.subnetid
  }
}

module Desktop1 'Modules/Compute.bicep' = {
  scope: resourceGroup(computeRG.name)
  name: '${envPrefix}${Spoke01Name}-D01'
  params: {
    adminPassword: adminPassword
    imageOffer: 'WindowsServer'
    imageOSsku: '2012-Datacenter'
    imagePublisher: 'MicrosoftWindowsServer'
    imageVersion: 'latest'
    location: location
    sakind: 'StorageV2'
    storageAccountPrefix: 'tst'
    storageskuname: 'Standard_LRS'
    subnetid: Spoke01S01.outputs.subnetid
    vmName: '${Spoke01Name}-D01'
    vmSize: 'Standard_B2ms'
    vNetName: Spoke01.name
    vnetrgname: computeRG.name
  }

  dependsOn: [
    Spoke01S01
  ]
}


