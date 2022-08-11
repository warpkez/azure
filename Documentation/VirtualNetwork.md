#### Creating a virtual network and subnet

##### Background

Virtual networks are required by most resources with Azure whether they be virtual machines, or resources that require private endpoints for security.

Where a `param` is defined, this can also be supplied via the command line or by using an Azure Resource Management (ARM) template parameter file.

##### References

- [Bicep documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep)
- [Virtual Network quickstart example](https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-bicep?toc=%2Fazure%2Fazure-resource-manager%2Fbicep%2Ftoc.json&tabs=CLI)
- [Azure CLI Installation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure CLI Command Reference](https://docs.microsoft.com/en-us/cli/azure/)

##### Defining variables and required configuration options

Setting the location of the resource to that of the Resource Group's own location.

```
param Location string = resourceGroup().location
```

Define a descriptive suffix for the virtual network and subnet.

```
param Suffix string = resourceGroup().name
```

For reporting, billing, or just to note when the resource was created define the creation date and time.  In this instance it is adjusted to Eastern Australia without DLS.

```
param BaseDate string = utcNow('u')
var DateCreated = dateTimeAdd(BaseDate, 'PT10H')
```

It is recommended practice to add tags to created resource.  This creates the tag to specify when the resource was created, and for what resource or designated function.
```
var ResourceTags =  {
  DateCreated: DateCreated
  ResourceFunction: Suffix
}
```

To provide the name for the virtual network
```
param vNetNameBase string = 'vNet01'
var vNetName = toLower('${vNetNameBase}-${Suffix}')
```

Azure virtual networks require an address space to be defined.  This is the pool from which we can create the subnet(s).  For example, defining the address space as 10.0.0.0/16 allows for subnets to occupy the ranges of 10.0.0.0 to 10.0.255.0.

```
param NetworkAddressSpace string = '10.0.0.0/16'
```

As with the network address space, the next step is to define the subnet and its corresponding address space.

```
param SubnetNameBase string = 'Subnet01'
var SubnetName = toLower('${SubnetNameBase}-${Suffix}')

param SubnetAddressSpace string = '10.0.0.0/24'
```

##### Finalising the configuration

Using the variables and parameters previously, now it is possible to create the resources.

```
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
    name: SubnetName
    parent: vnet
    properties: {
      addressPrefix: SubnetAddressSpace
    } 
  }
```

##### Bringing it altogether

Ensuring that the BICEP modules are installed and up to date.
```
> az install bicep
```

or

```
> az upgrade bicep
```

From the command line:
```
> az deployment group create --resource-group my-Resource-Group --template-file vnet.bicep --name Descriptive_name
```

As an example:
```
> az deployment group create --resource-group rg_Staging --template-file vnet.bicep --name staging-vnet -o table
Please provide string value for 'New_Or_Existing_VNet' (? for help): 
 [1] new
 [2] existing
Please enter a choice [Default choice(1)]:
Name          State      Timestamp                         Mode         ResourceGroup
------------  ---------  --------------------------------  -----------  ---------------
staging-vnet  Succeeded  2022-08-01T00:59:50.837576+00:00  Incremental  rg_Staging
```

Whilst it has not been included in the article, my own script has a section requesting if this is a new or an existing resource.

To facilitate this add in the parameters section:
```
@allowed([
  'new'
  'existing'
])
@description('New or existing Virtual Network and Subnet')
param New_Or_Existing_VNet string
```

Then replace the resource statements with:
```
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = if (toLower(New_Or_Existing_VNet) == 'new')
```
and
```
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (toLower(New_Or_Existing_VNet) == 'new')
```
These are not necessary, but can be used to only create new whilst extending existing resources.

The validation process will begin, and any errors will be displayed.  The script will only be processed upon a successful validation thus there will be no orphaned resources that need to be cleaned up.

Upon successful completion, feedback will be provided via a JSON output detailing specific information regarding the resources created.

To verify creation of the virtual network, log into the portal and navigate to the resource group, or
```
> az network vnet list --resource-group my-Resource-Group -o table
```

For example:
```
> az network vnet list --resource-group rg_Staging -o table

Name               ResourceGroup    Location       NumSubnets    Prefixes     DnsServers    DDOSProtection
-----------------  ---------------  -------------  ------------  -----------  ------------  ----------------
vnet01-rg_staging  rg_Staging       australiaeast  1             10.0.0.0/16                False

> az network vnet subnet list --resource-group rg_Staging --vnet-name vnet01-rg_staging -o table

AddressPrefix    Name                 PrivateEndpointNetworkPolicies    PrivateLinkServiceNetworkPolicies    ProvisioningState    ResourceGroup
---------------  -------------------  --------------------------------  -----------------------------------  -------------------  ---------------
10.0.0.0/24      subnet01-rg_staging  Disabled                          Enabled                              Succeeded            rg_Staging
```