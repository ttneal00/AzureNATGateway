param computeRgName string
param networkRgName string
param location string

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
var Spoke01CIDR = '${Spoke01Network}0.0/16'
var Spoke01S01CIDR = '${Spoke01Network}0.0/24'
var Spoke01S02CIDR = '${Spoke01Network}5.0/24'

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

module Spoke01S01 'Modules/subnet.bicep' = {
  name: '${Spoke01Name}-SN01'
  params: {
    addressprefix: Spoke01S01CIDR
    subnetname: '${Spoke01Name}/${Spoke01Name}-SN01'
    natGatewayId: natGw.outputs.natGwId 
  }
}

module Spoke01S02 'Modules/subnet.bicep' = {
  name: '${Spoke01Name}-SN01'
  params: {
    addressprefix: Spoke01S02CIDR
    subnetname: '${Spoke01Name}/${Spoke01Name}-SN02'
    natGatewayId: natGw.outputs.natGwId

  }
}


