// Global parameters
// Is this a new or an existing Virtual Network and Subnet
// The default is 'new' for a new deployment, otherwise 'existing' should be
// passed otherwise the deployment will fail if the Virtual Network
// and the Subnet have already been defined with the same Suffix
@allowed([
  'new'
  'existing'
])
@description('New Subnet?')
param New_Subnet string

// Suffix for resources
param Suffix string = resourceGroup().name

// Virtual Network
// Virtual network name
param vNetNameBase string = 'vNet01'
var vNetName = toLower('${vNetNameBase}-${Suffix}')

//  Subnet section
// Virtual subnet name
param SubnetNameBase string = 'Subnet01'
var SubnetName = toLower('${SubnetNameBase}-${Suffix}')

// Virtual network address space
param SubnetAddressSpace string = '10.0.0.0/24'

// Virtual network will be associated with the resource group
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
//resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNetName  
}
  
// Subnet will be associated with the resource group
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (toLower(New_Subnet) == 'new') {
//resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: SubnetName
  parent: vnet
  properties: {
    addressPrefix: SubnetAddressSpace
  } 
}
