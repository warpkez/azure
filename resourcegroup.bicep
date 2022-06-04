// Set the scope
targetScope = 'subscription'

// Name of the resource group
param ResourceGroupName string

// Target region
param ResourceRegion string

// Tags for resources
// Get the current datetime 
param BaseDate string = utcNow('u')

// Sets the time for UTC +10
var DateCreated = dateTimeAdd(BaseDate, 'PT10H')

// Resource tags
// Add any and all resource tags here
var ResourceTags =  {
  DateCreated: DateCreated
}

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: ResourceRegion
  name: ResourceGroupName 
  tags: ResourceTags
}
