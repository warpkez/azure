// Global parameters
// Is this a new or an existing Virtual Network and Subnet
// The default is 'new' for a new deployment, otherwise 'existing' should be
// passed otherwise the deployment will fail if the Virtual Network
// and the Subnet have already been defined with the same Suffix
@allowed([
  'new'
  'existing'
])
@description('New or existing Virtual Network and Subnet')
param New_VNet string

@allowed([
  'new'
  'existing'
])
@description('New or existing Virtual Network and Subnet')
param New_Subnet string

// Uses the resource group's location to set the location for all resources
param Location string = resourceGroup().location

// Suffix for resources
param Suffix string = resourceGroup().name
// 'HomeLab'

// Tags for resources
// Get the current datetime 
param BaseDate string = utcNow('u')

// Sets the time for UTC +10
var DateCreated = dateTimeAdd(BaseDate, 'PT10H')

// Resource tags
// Add any and all resource tags here
var ResourceTags =  {
  DateCreated: DateCreated
  ResourceFunction: Suffix
}

// Virtual Network
// Virtual network name
param vNetNameBase string = 'vNet01'
var vNetName = toLower('${vNetNameBase}-${Suffix}')

// Address space for the virtual network
param NetworkAddressSpace string = '10.0.0.0/16'

//  Subnet section
// Virtual subnet name
param SubnetNameBase string = 'Subnet01'
var SubnetName = toLower('${SubnetNameBase}-${Suffix}')

// Virtual network address space
param SubnetAddressSpace string = '10.0.0.0/24'

// Virtual network will be associated with the resource group
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = if (toLower(New_VNet) == 'new') {
  //resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
    name: vNetName
    location: Location
    tags: ResourceTags
    properties: {
      addressSpace: {
        addressPrefixes: [
         NetworkAddressSpace 
        ]
      }
    }
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
